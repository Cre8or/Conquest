/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LA][GE]
		Called whenever a local vehicle's "HandleDamage" EH is executed.
	Arguments:
		(see https://community.bistudio.com/wiki/Arma_3:_Event_Handlers#HandleDamage)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"





// Workaround for return values (see https://community.bistudio.com/wiki/exitWith)
_this call {

	if (GVAR(missionState) < MACRO_ENUM_MISSION_LIVE) exitWith {0};

	// Passed by the engine
	params [
		"_veh",
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

	if (_hitPoint == "") exitWith {};

	// Allow vehicle destruction when health has reached 0
	private _health = _veh getVariable [QGVAR(health), 1];
	if (_health <= 0) exitWith {1};

	private _side       = _veh getVariable [QGVAR(side), sideEmpty];
	private _damageEnum = MACRO_ENUM_DAMAGE_UNKNOWN;





	// World damage
	if (_ammoType == "" or {isNull _source and {isNull _instigator}}) then {
		_damageEnum = MACRO_ENUM_DAMAGE_PHYSICS;

	} else {
		private _damageData = [_ammoType] call FUNC(proj_getDamageData);
		_damageData params ["", "", "_explosive"];

		if (_isDirect) then {

			// Non-explosive indirect hits (e.g. minigun splash damage) are discarded (skill issue)
			if (_explosive > 0.5) then {
				_damageEnum = MACRO_ENUM_DAMAGE_EXPLOSIVE;

				// Mines/explosives don't have a source, but an instigator
				if (isNull _instigator and {_source isKindOf "Man"}) then {
					_instigator = _source;
				};
			};

		} else {
			_damageEnum = MACRO_ENUM_DAMAGE_BULLET;
		};
	};

	// Ensure hitPoint damage does not exceed a predefined maximum for vital parts
	private _maxDamage = (switch (_hitPoint) do {

		// Vitals
		case ""; // Overall damage
		case "hithull";
		case "hitfuel";
		case "hitengine";
		case "hitengine1";
		case "hitengine2";
		case "hitengine3": {0.899};

		// Left wheels
		case "hitlfwheel";
		case "hitlf2wheel";
		case "hitlmwheel";
		case "hitlbwheel";

		// Right wheels
		case "hitrfwheel";
		case "hitrf2wheel";
		case "hitrmwheel";
		case "hitrbwheel": {0.89};

		// Tracks:
		case "hitltrack";
		case "hitrtrack": {0.899};

		default {999}; // Anything above 1 works
	});

	private _totalDamage = (_veh getHitPointDamage _hitPoint) + _damageProcessed min _maxDamage;
	//diag_log format ["(%1) %2: %3", diag_frameNo, _hitPoint, _damageProcessed];

	// Keep track of the highest damage event in this frame (for data tracking)
	if (_damageProcessed > (_veh getVariable [QGVAR(damage_stored), 0])) then {
		GVAR(gm_sys_monitorEntityDamage_update) = true;

		_veh setVariable [QGVAR(damage_stored), _damageProcessed, false];
		_veh setVariable [QGVAR(damage_enum), _damageEnum, false];
		_veh setVariable [QGVAR(damage_source), _source, false];
		_veh setVariable [QGVAR(damage_instigator), _instigator, false];
		_veh setVariable [QGVAR(damage_ammoType), _ammoType, false];
	};

	// TODO: Offload vehicle destruction into gm_processVehicleDamage.
	// Currently, vehicles are invincible because their vital hitpoints are capped at 89.9% damage.
	// For destruction to work, we need to calculate the theoretical total damage (with uncapped hitpoint
	// damage) and use it to determine the overall health.
	//
	// Maybe use a hashmap to keep track of the uncapped hitpoint damage, and feed that into
	// veh_calculateHealth?



	_totalDamage;
};
