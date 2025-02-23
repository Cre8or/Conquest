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
		"_newRawTotalDamage",
		"_source",
		"_ammoType", // _projectile
		"",
		"_instigator",
		"_hitPoint",
		"_isDirect",
		"_context"
	];
	_hitPoint = toLower _hitPoint;




	// Allow vehicle destruction when health has reached 0
	private _health = _veh getVariable [QGVAR(health), 1];
	if (_health <= 0) exitWith {1};

	// Cache the overall damage at the start of the event
	if (_context == 0) exitWith {

		// Edge case: killing vehicles through Zeus
		if (isNull _source and {isNull _instigator} and {_newRawTotalDamage >= 1}) then {
			GVAR(gm_sys_monitorEntityDamage_update) = true;
			_veh setVariable [QGVAR(gm_sys_monitorEntityDamage_isHit), true, false];
			_veh setVariable [QGVAR(damage_enum), MACRO_ENUM_DAMAGE_CURATOR, false];
			//diag_log "Killing vehicle through zeus";
			0;

		} else {
			// TODO: Consider the vehicle health multiplier here
			private _damage     = (_newRawTotalDamage - damage _veh) max 0;
			private _prevDamage = _veh getVariable [QGVAR(damage_overall), 0];

			if (_damage > _prevDamage) then {
				//diag_log format ["  (%1) Caching overall damage: %2", diag_frameNo, _damage];
				_veh setVariable [QGVAR(damage_overall), _damage, false];
			};

			_newRawTotalDamage min MACRO_VEHICLE_HEALTH_MAXHITPOINTDAMAGE;
		};
	};



	private _side            = _veh getVariable [QGVAR(side), sideEmpty];
	private _damageEnum      = MACRO_ENUM_DAMAGE_UNKNOWN;
	private _damageMul       = 1;
	private _prevTotalDamage = _veh getHitPointDamage _hitPoint;
	private _damage          = _newRawTotalDamage - _prevTotalDamage;

	// Filter out minuscule damage increments
	if (_damage < 0.0001) exitWith {
		//diag_log format ["  Skipping low damage (%1): %2", _hitPoint, _damage];
		_prevTotalDamage
	};



	// World damage
	if (_ammoType == "" or {isNull _source and {isNull _instigator}}) then {
		_damageMul  = MACRO_GM_VEH_DAMAGEMUL_PHYSICS;
		_damageEnum = MACRO_ENUM_DAMAGE_PHYSICS;

	} else {
		private _damageData = [_ammoType] call FUNC(proj_getDamageData);
		_damageData params ["_damageDirect", "_damageIndirect", "_explosive"];

		// Explosive damage
		if (_explosive > 0.5) then {
			_damageMul  = MACRO_GM_VEH_DAMAGEMUL_EXPLOSIVE;
			_damageEnum = MACRO_ENUM_DAMAGE_EXPLOSIVE;

		// Bullet damage
		} else {
			_damageMul  = MACRO_GM_VEH_DAMAGEMUL_BULLET;
			_damageEnum = MACRO_ENUM_DAMAGE_BULLET;
		};
	};
	private _damageAdjusted = _damage * _damageMul;
	private _forceMaxDamage = false; // Currently only used for the main rotor

	// Ensure hitPoint damage does not exceed a predefined maximum for vital parts
	private _maxTotalDamage = (switch (_hitPoint) do {

		// Vitals
		case "hithull";
		case "hitfuel";
		case "hitengine";
		case "hitengine1";
		case "hitengine2";
		case "hitengine3": {MACRO_VEHICLE_HEALTH_MAXHITPOINTDAMAGE};

		// Main rotor
		case "hithrotor": {
			if (
				_veh animationPhase "rotorimpacthide" >= 0.5 // Rotor is already destroyed
				or {_hitPoint == "hithrotor" and {_context == 2} and {_isDirect} and {_ammoType == ""}} // Rotor is about to be destroyed
			) then {
				_forceMaxDamage = true;
				1;
			} else {
				MACRO_VEHICLE_HEALTH_MAXHITPOINTDAMAGE;
			};
		};

		// Wheels
		case "hitlfwheel";
		case "hitlf2wheel";
		case "hitlmwheel";
		case "hitlbwheel";
		case "hitrfwheel";
		case "hitrf2wheel";
		case "hitrmwheel";
		case "hitrbwheel": {MACRO_VEHICLE_HEALTH_MAXHITPOINTDAMAGE};

		// Tracks:
		case "hitltrack";
		case "hitrtrack": {MACRO_VEHICLE_HEALTH_MAXHITPOINTDAMAGE};

		// Invincible
		case "hitavionics";
		case "hitwinch";
		case "hittransmission";
		case "hitmissiles": {0};

		default {999}; // Anything above 1 works
	});

	// Determine the total damage that the hitpoint should receive (this is our output of the HandleDamage event)
	private "_newCalcTotalDamage";
	if (_forceMaxDamage) then {
		_newCalcTotalDamage = _maxTotalDamage;
	} else {
		_newCalcTotalDamage = (_prevTotalDamage + _damageAdjusted) min _maxTotalDamage;
	};

	// Keep track of the highest damage event in this frame (for data tracking)
	if (_damageAdjusted > (_veh getVariable [QGVAR(damage_stored), 0])) then {
		_veh setVariable [QGVAR(damage_stored),     _damageAdjusted, false];
		_veh setVariable [QGVAR(damage_enum),       _damageEnum, false];
		_veh setVariable [QGVAR(damage_source),     _source, false];
		_veh setVariable [QGVAR(damage_instigator), _instigator, false];
		_veh setVariable [QGVAR(damage_ammoType),   _ammoType, false];
	};

	// Handle overall damage contribution
	private _damageContribMul = (switch (_hitPoint) do {

		// Hull
		case "hitbody";
		case "hithull": {0.05};

		// Vitals (some are extremely exposed, hence the low multiplier)
		case "hitfuel";
		case "hitengine";
		case "hitengine1";
		case "hitengine2";
		case "hitengine3": {0.02};

		// Aircraft specific
		case "hithrotor";
		case "hitvrotor";
		case "hittransmission": {0.05};

		// Armoured vehicles
		case "hitturret": {0.1};

		// Everything else
		default {0.0};
	});

	private _damageCalc = _damageContribMul * _damageAdjusted;

	// Keep track of the maximum damage in this damage event (is reset when the last hitpoint is being handled)
	if (_damageCalc > _veh getVariable [QGVAR(damage_calc), 0]) then {
		//diag_log format ["  Highest calc (%1): %2", _hitPoint, _damageCalc];
		_veh setVariable [QGVAR(damage_calc), _damageCalc, false];
	};
/*
	if (_damageCalc > 0) then {
		diag_log format ["  (%1) %2: %3 (%4)", diag_frameNo, _hitPoint, _damageAdjusted, _newRawTotalDamage];
	};
*/


	// For any hitpoint other than the hull, allow the total damage to be updated.
	// The hull hitpoint is updated exclusively during the last hitpoint context, to prevent interference.
	if (_hitPoint == "hithull") then {
		_newCalcTotalDamage = _prevTotalDamage;
	};

	// Last hit point: override the hull damage
	// Rationale: use the hull as "proxy" to convey overall damage.
	// Every vehicle should have a "hithull" hitpoint, so this approach should be general enough to work
	// in most/all cases.
	if (_context == 2) then {
		private _prevTotalDamageHull = _veh getHitPointDamage "hithull";
		private _damageCalc          = _veh getVariable [QGVAR(damage_calc), 0];

		// This is where the overall damage before hitpoint iteration comes into play.
		// Since we are unable to determine its cause directly, we can infer its parameters from the
		// highest damage's source (which we already store for damage tracking purposes).
		// This way we can retroactively apply the damage multipliers as in the hitpoint iteration check.
		private _damageOverall    = _veh getVariable [QGVAR(damage_overall), 0];
		private _damageMulOverall = switch (_veh getVariable [QGVAR(damage_enum), MACRO_ENUM_DAMAGE_UNKNOWN]) do {
			case MACRO_ENUM_DAMAGE_BULLET:    {MACRO_GM_VEH_DAMAGEMUL_BULLET};
			case MACRO_ENUM_DAMAGE_EXPLOSIVE: {MACRO_GM_VEH_DAMAGEMUL_EXPLOSIVE};
			case MACRO_ENUM_DAMAGE_PHYSICS:   {MACRO_GM_VEH_DAMAGEMUL_PHYSICS};
			default                           {1};
		};

		// Put everything together into the total hull damage
		private _newCalcTotalDamageHull = (_prevTotalDamageHull + _damageCalc + _damageOverall * _damageMulOverall) min MACRO_VEHICLE_HEALTH_MAXHITPOINTDAMAGE;
		//diag_log format ["Hull damage: %1 (%2 + %3 + %4)", _newCalcTotalDamageHull, _prevTotalDamageHull, _damageCalc, _damageOverall * _damageMulOverall];

		if (_hitPoint == "hithull") then  {
			_newCalcTotalDamage = _newCalcTotalDamageHull;
		} else {
			_veh setHitPointDamage ["hithull", _newCalcTotalDamageHull];
		};

		// Flag the vehicle as having received damage (interfaces with gm_sys_monitorEntityDamage)
		_veh setVariable [QGVAR(gm_sys_monitorEntityDamage_isHit), true, false];
		GVAR(gm_sys_monitorEntityDamage_update) = true;

		// Reset for future HandleDamage events
		_veh setVariable [QGVAR(damage_overall), 0, false];
		_veh setVariable [QGVAR(damage_calc),    0, false];
		_veh setVariable [QGVAR(damage_stored),  0, false];
	};

	_newCalcTotalDamage;
};
