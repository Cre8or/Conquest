/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LA][GE]
		Called whenever a local unit's "HandleDamage" EH is executed.
		Handles the damage the unit receives from various sources, and filters out specific sources
		(e.g. friendly vehicle impacts/physics damage).
	Arguments:
		(see https://community.bistudio.com/wiki/Arma_3:_Event_Handlers#HandleDamage)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"





#define MACRO_GM_UNIT_MINDAMAGETHRESHOLD 0.005
#define MACRO_GM_UNIT_INDIRECTDAMAGE_MAXDISTOFFSET 2
#define MACRO_GM_UNIT_INDIRECTDAMAGE_MAXREFERENCEDAMAGE 10
#define MACRO_GM_UNIT_WORLDDAMAGE_IMMUNEDURATION 2
#define MACRO_GM_UNIT_DAMAGERATIO_PROCESSEDTORAW 1 // Lower values lean damage towards arcade-y settings (more flat damage, less variation), higher numbers lean damage towards vanilla Arma 3 handling
#define MACRO_GM_UNIT_RAWDAMAGE_EXPONENT 0.6 // Higher numbers make the raw damage curve more exponential (bigger calibers do far more damage than smaller ones), lower numbers flatten the curve (bigger calibers do similar damage to smaller ones)
#define MACRO_GM_UNIT_RAWDAMAGE_BASEAMOUNT 12 // Reference value for base damage that will be remapped to y=1 for the exponential curve





// Workaround for return values (see https://community.bistudio.com/wiki/exitWith)
_this call {

	if (GVAR(missionState) < MACRO_ENUM_MISSION_LIVE) exitWith {0};

	// Passed by the engine
	params [
		"_unit",
		"",
		"_damageProcessed",
		"_source",
		"_ammoType", // _projectile
		"",
		"_instigator",
		"_hitPoint",
		"_isDirect",
		"_context"
	];
	_hitPoint = toLower _hitPoint;

	// Filter out fake head hits
	if (_damageProcessed <= 0 or {_context == 3}) exitWith {0};

	// Filter out special hit points
	if (_hitPoint == "incapacitated" or {_hitPoint select [0, 4] == "ace_"}) exitWith {0};

	// Allow killing units through zeus
	if (_context == 0 and {isNull _source} and {isNull _instigator} and {_damageProcessed == 1}) exitWith {
		GVAR(gm_sys_monitorEntityDamage_update) = true;

		_unit setVariable [QGVAR(gm_sys_monitorEntityDamage_isHit), true, false];
		_unit setVariable [QGVAR(damage_stored), -1, false];
		_unit setVariable [QGVAR(damage_enum), MACRO_ENUM_DAMAGE_CURATOR, false];

		0
	};

	// Filter out indirect damage to anything other than the body
	if (!_isDirect and {_ammoType != ""} and {_hitPoint != ""}) exitWith {0};

	// Don't handle damage if the unit is unconscious/dead
	if !([_unit] call FUNC(unit_isAlive)) exitWith {
		_unit getHitPointDamage _hitPoint;
	};

	private _side                = _unit getVariable [QGVAR(side), sideEmpty];
	private _damageEnum          = MACRO_ENUM_DAMAGE_UNKNOWN;
	private _unitInVehicle       = (_unit != vehicle _unit);
	private _isPhysicsDamage     = false;
	private _newDamage           = 0;
	private _damageProcessedReal = _damageProcessed;





	// World damage
	if ((_ammoType == "" and {isNull _instigator}) or {isNull _source and {isNull _instigator}}) then {

		_isPhysicsDamage = true;
		private _time = time;

		// Filter physics damage inside vehicles
		if (!_unitInVehicle and {_time > _unit getVariable [QGVAR(worldDamage_immuneTime), 0]}) then {

			// If the source is a vehicle, fetch the driver
			private _driver = _source;
			if (_driver isKindOf "Man") then {
				_source = vehicle _driver;
			} else {
				_driver = currentPilot _source;

				// Fallback for vehicles other than aircraft
				if (isNull _driver) then {
					_driver = driver _source;
				};
			};

			// If the source was a friendly, grant the unit a short immunity against physics damage (in case they're being tossed around as a ragdoll)
			if (
				!isNull _driver
				and {_driver != _unit}
				and {_driver getVariable [QGVAR(side), sideEmpty] == _side}
			) then {
				_unit setVariable [QGVAR(worldDamage_immuneTime), _time + MACRO_GM_UNIT_WORLDDAMAGE_IMMUNEDURATION, false];

			// Otherwise, the physics damage is valid
			} else {
				_damageEnum = MACRO_ENUM_DAMAGE_PHYSICS;

				// Attribute the damage to the correct unit (e.g. the vehicle driver)
				if (isNull _instigator) then {
					_instigator = _driver;
				};

				// Fall-damage
				if (isNull _source or {_source == _unit}) then {
					private _fallVel = abs ((velocity vehicle _unit) # 2);
					private _health  = 0.05 + 0.95 * (_unit getVariable [QGVAR(health), 1]); // Scale fall damage with unit health

					_instigator = _unit; // Force self-inflicted damage
					_newDamage  = _health * MACRO_GM_UNIT_DAMAGEMUL_FALLDAMAGE * 0.07 * (0 max (_fallVel - sqrt (2 * 9.81 * MACRO_UNIT_HEALTH_FALLDAMAGEHEIGHT))) ^ 2; // Lethal at around 6 meters
				} else {
					// Sanity-check: vehicle collisions may only happen if the vehicle is within 20 meters of the unit (roughly)
					if (_source distanceSqr _unit < 400) then {
						_newDamage = MACRO_GM_UNIT_DAMAGEMUL_ROADKILL * 0.1 * (vectorMagnitudeSqr (velocity vehicle _instigator vectorDiff velocity vehicle _unit)); // 1 damage at ~7 m/s (25 km/h)
					};
				};
			};
		};

	} else {
		private _damageData = [_ammoType] call FUNC(proj_getDamageData);
		_damageData params ["_damageDirect", "_damageIndirect", "_explosive"];

		if (!_isDirect) then {

			// Non-explosive indirect hits (e.g. minigun splash damage) are discarded (skill issue)
			if (_explosive > 0.5) then {
				_damageEnum = MACRO_ENUM_DAMAGE_EXPLOSIVE;

				// Mines/explosives don't have a source, but an instigator
				if (isNull _instigator and {_source isKindOf "Man"}) then {
					_instigator = _source;
				};

				private _damageMul = MACRO_GM_UNIT_DAMAGEMUL_EXPLOSIVE * 0.15;
				private _damageIndirectCalc = sqrt _damageIndirect;
				private _distMultiplier = 100 * _damageProcessed / _damageIndirect; // Normalise with indirect damage
				private _distOffset = (MACRO_GM_UNIT_INDIRECTDAMAGE_MAXREFERENCEDAMAGE ^ 2 - _damageIndirect max 0) * MACRO_GM_UNIT_INDIRECTDAMAGE_MAXDISTOFFSET / MACRO_GM_UNIT_INDIRECTDAMAGE_MAXREFERENCEDAMAGE ^ 2;

				if (_unitInVehicle) then {
					if (getNumber (configFile >> "CfgVehicles" >> typeOf vehicle _unit >> "crewVulnerable") > 0) then {
						_newDamage = _damageMul * _damageIndirectCalc * (_distMultiplier - _distOffset);
					};
				} else {
					_newDamage = _damageMul * _damageIndirectCalc * (_distMultiplier - _distOffset);
				};
			};

		} else {
			_damageEnum = MACRO_ENUM_DAMAGE_BULLET;
			private _damageMul = 0;

			switch (_hitPoint) do {
				// Head
				case "hithead";
				case "hitface":		{_damageMul = 0.1}; // Headshot multiplier is applied at a later stage (ontop of this value)

				// Torso
				case "hitneck"; // Extends too far down to be registered as "head"
				case "hitchest";
				case "hitdiaphragm";
				case "hitabdomen";
				case "hitpelvis";
				case "hitbody":		{_damageMul = 0.05};

				// Legs
				case "hitleftleg";
				case "hitrightleg";
				case "hitlegs":		{_damageMul = 0.04};

				// Arms
				case "hitleftarm";
				case "hitrightarm";
				case "hitarms":		{_damageMul = 0.03};

				// Hands
				case "hithands":	{_damageMul = 0.02};
			};

			// Revert the processed damage into the real damage by accounting for the total armour value of the affected hitpoint
			if (_hitPoint != "") then {
				private _role        = _unit getVariable [QGVAR(role), MACRO_ENUM_ROLE_INVALID];
				private _armourCache = missionNamespace getVariable [format [QGVAR(armourCache_%1_%2), _side, _role], createHashMap];
				private _armour      = 1 max (_armourCache getOrDefault [_hitPoint, 0]);
				_damageProcessedReal = _damageProcessed * _armour; // Undo the armour damage negation by multiplying

				// Store the largest raw damage, and the selection it occured on
				private _prevDamageProcessedReal = _unit getVariable [QGVAR(damage_storedProcessed), 0];
				if (
					_damageProcessedReal > _prevDamageProcessedReal
					or {_damageProcessedReal > 0.999 * _prevDamageProcessedReal and {_hitPoint in ["hithead", "hitface"]}} // Upgrade to headshot (usually happens on hitneck anyway)
				) then {
					_unit setVariable [QGVAR(damage_storedProcessed), _damageProcessedReal, false];
					_unit setVariable [QGVAR(damage_storedHitPoint), _hitPoint, false];
				};
			};

			// Factor in faction-defined damage balancing
			_ammoType = toLower _ammoType;
			private _instigatorSide       = _instigator getVariable [QGVAR(side), sideEmpty];
			private _instigatorMuzzleLUT  = _instigator getVariable [QGVAR(muzzleLUT), createHashMap];
			private _muzzleDamageMulCache = missionNamespace getVariable [format [QGVAR(muzzleDamageMulCache_%1), _instigatorSide], createHashMap];
			private _muzzle               = _instigatorMuzzleLUT getOrDefault [_ammoType, ""];
			private _muzzleDamageMul      = _muzzleDamageMulCache getOrDefault [_muzzle, 1];

			_damageDirect    = _damageDirect * _muzzleDamageMul;
			_damageProcessed = _damageProcessed * _muzzleDamageMul;

			// Remap the raw damage by exponent
			_damageDirect = MACRO_GM_UNIT_RAWDAMAGE_BASEAMOUNT * ((_muzzleDamageMul * _damageDirect / MACRO_GM_UNIT_RAWDAMAGE_BASEAMOUNT) ^ MACRO_GM_UNIT_RAWDAMAGE_EXPONENT);
			_newDamage    = MACRO_GM_UNIT_DAMAGEMUL_BULLET * _damageMul * (_damageProcessed * MACRO_GM_UNIT_DAMAGERATIO_PROCESSEDTORAW + _damageDirect) / (MACRO_GM_UNIT_DAMAGERATIO_PROCESSEDTORAW + 1);
		};
	};

	// Only keep the highest damage event in this frame
	if (_newDamage > (_unit getVariable [QGVAR(damage_stored), 0]) and {_newDamage > MACRO_GM_UNIT_MINDAMAGETHRESHOLD}) then {
		GVAR(gm_sys_monitorEntityDamage_update) = true;

		// Flag the vehicle as having received damage (interfaces with gm_sys_monitorEntityDamage)
		_unit setVariable [QGVAR(gm_sys_monitorEntityDamage_isHit), true, false];

		_unit setVariable [QGVAR(damage_stored), _newDamage, false];
		_unit setVariable [QGVAR(damage_enum), _damageEnum, false];
		_unit setVariable [QGVAR(damage_source), _source, false];
		_unit setVariable [QGVAR(damage_instigator), _instigator, false];
		_unit setVariable [QGVAR(damage_ammoType), _ammoType, false];

		//diag_log format ["[CONQUEST] Highest damage: %1 (%2) - %3 / %4 / %5", _newDamage, _damageEnum, _source, _instigator, _ammoType];
	};
/*
	// DEBUG
	//systemChat format ["(%1) damage :%2", diag_frameNo, _newDamage];
	private _fnc_padStr = {
		params ["_val", "_length"];
		private _str = [str _val, _val] select (_val isEqualType "");
		private _pad = "";

		for "_i" from 1 to _length - count _str do {
			_pad = _pad + " ";
		};

		_pad + _str;
	};

	diag_log format ["%1: %2 / %3 / %4 / %5 / %6",
		diag_frameNo,
		[_hitPoint, 14] call _fnc_padStr,
		[(round (1000 * _damageProcessed)) / 1000, 8] call _fnc_padStr,
		[(round (1000 * _damageProcessedReal)) / 1000, 8] call _fnc_padStr,
		//[_damageIndirect, 4] call _fnc_padStr,
		"-",
		[(round (_newDamage * 1000)) / 10, 8] call _fnc_padStr
	];
*/
	0;
};
