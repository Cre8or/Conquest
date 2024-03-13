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





// Define some macros
#define MACRO_GM_UNIT_MINDAMAGETHRESHOLD 0.005
#define MACRO_GM_UNIT_INDIRECTDAMAGE_MAXRDISTOFFSET 2
#define MACRO_GM_UNIT_INDIRECTDAMAGE_MAXREFERENCEDAMAGE 10
#define MACRO_GM_UNIT_WORLDDAMAGE_IMMUNEDURATION 2





// Workaround for return values (see https://community.bistudio.com/wiki/exitWith)
_this call {

	if (GVAR(missionState) < MACRO_ENUM_MISSION_LIVE) exitWith {0};

	// Passed by the engine
	params [
		"_unit",
		"",
		"_damageProcessed",
		"_source",
		"_ammoType",
		"",
		"_instigator",
		"_hitPoint",
		"_isDirect"
	];
	_hitPoint = toLower _hitPoint;

	// Filter out head-damage events triggering one frame ahead of time (no idea what's causing this)
	if (_damageProcessed <= 0 or {_hitPoint == "hithead" and {isNull _instigator}}) exitWith {0};

	// Filter out special hit points
	if (_hitPoint == "incapacitated" or {_hitPoint select [0, 4] == "ace_"}) exitWith {0};

	// Filter out indirect damage to anything other than the body
	if (!_isDirect and {_ammoType != ""} and {_hitPoint != ""}) exitWith {0};

	// Don't handle damage if the unit is unconscious/dead
	if !([_unit] call FUNC(unit_isAlive)) exitWith {0};

	private _newDamage = 0;
	private _isPhysicsDamage = false;
	private _damageEnum = MACRO_ENUM_DAMAGE_UNKNOWN;
	private _unitInVehicle = (_unit != vehicle _unit);

	// World damage
	if (isNull _instigator and {_ammoType == ""}) then {

		_isPhysicsDamage = true;
		private _time = time;

		// Filter physics damage inside vehicles
		if (!_unitInVehicle and {_time > _unit getVariable [QGVAR(worldDamage_immuneTime), 0]}) then {

			// If the source was a friendly, grant the unit a short immunity against physics damage (in case they're being tossed around as a ragdoll)
			if (
				!isNull _source
				and {_source != _unit}
				and {_source getVariable [QGVAR(side), sideEmpty] == _unit getVariable [QGVAR(side), sideEmpty]}
			) then {
				_unit setVariable [QGVAR(worldDamage_immuneTime), _time + MACRO_GM_UNIT_WORLDDAMAGE_IMMUNEDURATION, false];

			// Otherwise, the physics damage is valid
			} else {
				_damageEnum = MACRO_ENUM_DAMAGE_PHYSICS;

				// Attribute the damage to the correct unit (e.g. the vehicle driver)
				if (isNull _instigator) then {
					_instigator = _source;
				};
				if (_source isKindOf "Man") then {
					_source = vehicle _source;
				};

				// Fall-damage
				if (isNull _source or {_source == _unit}) then {
					private _maxSafeFallDist = 3; // in meters
					private _fallVel = abs ((velocity vehicle _unit) # 2);

					_newDamage = MACRO_GM_UNIT_DAMAGEMUL_FALLDAMAGE * 0.05 * (0 max (_fallVel - sqrt (2 * 9.81 * _maxSafeFallDist))) ^ 2; // Lethal at around 6 meters
				} else {
					// Sanity-check: vehicle collisions may only happen if the vehicle is within 20 meters of the unit (roughly)
					if (_source distanceSqr _unit < 400) then {
						_newDamage = MACRO_GM_UNIT_DAMAGEMUL_ROADKILL * 0.1 * (vectorMagnitudeSqr (velocity vehicle _instigator vectorDiff velocity vehicle _unit)); // 1 damage at ~7 m/s (25 km/h)
					};
				};
			};
		};

	} else {

		private _config         = configFile >> "CfgAmmo" >> _ammoType;
		private _explosive      = getNumber (_config >> "explosive");
		private _damageDirect   = getNumber (_config >> "hit");
		private _damageIndirect = getNumber (_config >> "indirectHit");

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
				private _distMultiplier = 100 * _damageProcessed / _damageIndirect;
				private _distOffset = (MACRO_GM_UNIT_INDIRECTDAMAGE_MAXREFERENCEDAMAGE ^ 2 - _damageIndirect max 0) * MACRO_GM_UNIT_INDIRECTDAMAGE_MAXRDISTOFFSET / MACRO_GM_UNIT_INDIRECTDAMAGE_MAXREFERENCEDAMAGE ^ 2;

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
			private _ratioProcessedToRaw = 2; // Lower values lean damage towards arcade-y settings (more flat damage, less variation)

			switch (_hitPoint) do {
				// Head
				case "hithead";
				case "hitface":		{_damageMul = 0.15}; // Headshot multiplier is applied at a later stage (ontop of this value)

				// Torso
				case "hitneck"; // Extends too far down to be registered as "head"
				case "hitchest";
				case "hitdiaphragm";
				case "hitabdomen";
				case "hitpelvis";
				case "hitbody":		{_damageMul = 0.1};

				// Legs
				case "hitleftleg";
				case "hitrightleg";
				case "hitlegs":		{_damageMul = 0.06};

				// Arms
				case "hitleftarm";
				case "hitrightarm";
				case "hitarms":		{_damageMul = 0.04};

				// Hands
				case "hithands":	{_damageMul = 0.025};
			};

			// Store the largest raw damage, and the selection it occured on
			if (_damageProcessed > (_unit getVariable [QGVAR(damage_storedProcessed), 0])) then {
				_unit setVariable [QGVAR(damage_storedHitPoint), _hitPoint, false];
				_unit setVariable [QGVAR(damage_storedProcessed), _damageProcessed, false];
			};

			_newDamage = MACRO_GM_UNIT_DAMAGEMUL_BULLET * _damageMul * (_damageProcessed * _ratioProcessedToRaw + _damageDirect) / (_ratioProcessedToRaw + 1);
		};
	};

	// Only keep the highest damage event in this frame
	if (_newDamage > (_unit getVariable [QGVAR(damage_stored), 0]) and {_newDamage > MACRO_GM_UNIT_MINDAMAGETHRESHOLD}) then {
		GVAR(gm_sys_monitorUnitDamage_update) = true;

		_unit setVariable [QGVAR(damage_stored), _newDamage, false];
		_unit setVariable [QGVAR(damage_enum), _damageEnum, false];
		_unit setVariable [QGVAR(damage_source), _source, false];
		_unit setVariable [QGVAR(damage_instigator), _instigator, false];
		_unit setVariable [QGVAR(damage_ammoType), _ammoType, false];

/*
		if (!GVAR(gm_sys_monitorUnitDamage_update)) then {
			systemChat format ["(%1) damage :%2", diag_frameNo, _newDamage];

			private _fnc_padStr = {
				params ["_val", "_length"];
				private _str = [str _val, _val] select (_val isEqualType "");
				private _pad = "";

				for "_i" from 1 to _length - count _str do {
					_pad = _pad + " ";
				};

				_pad + _str;
			};

			systemChat str cre_debug;

			diag_log format ["%1: %2 / %3 / %4 / %5 / %6",
				diag_frameNo,
				[_hitPoint, 14] call _fnc_padStr,
				[(round (10 * _damageProcessed * 100)) / 10, 8] call _fnc_padStr,
				[_damageIndirect, 4] call _fnc_padStr,
				[(round (1000 * cre_debug)) / 1000, 8] call _fnc_padStr,
				[(round (_newDamage * 1000)) / 10, 8] call _fnc_padStr
			];
		};
*/
	};
/*
	// DEBUG
	systemChat format ["(%1) damage :%2", diag_frameNo, _newDamage];

	private _fnc_padStr = {
		params ["_val", "_length"];
		private _str = [str _val, _val] select (_val isEqualType "");
		private _pad = "";

		for "_i" from 1 to _length - count _str do {
			_pad = _pad + " ";
		};

		_pad + _str;
	};

	systemChat str _distMultiplier;

	diag_log format ["%1: %2 / %3 / %4 / %5 / %6",
		diag_frameNo,
		[_hitPoint, 14] call _fnc_padStr,
		[(round (10 * _damageProcessed * 100)) / 10, 8] call _fnc_padStr,
		[_damageIndirect, 4] call _fnc_padStr,
		[(round (1000 * _distMultiplier)) / 1000, 8] call _fnc_padStr,
		[(round (_newDamage * 1000)) / 10, 8] call _fnc_padStr
	];
*/
	0;
};
