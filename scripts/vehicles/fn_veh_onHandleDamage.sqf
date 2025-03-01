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
	_ammoType = toLower _ammoType;
	//diag_log str _this;

	// Allow vehicle destruction when health has reached 0
	private _health = _veh getVariable [QGVAR(health), 1];
	if (_health <= 0) exitWith {1};

	private _side = _veh getVariable [QGVAR(side), sideEmpty];

	// Determine the instigator's muzzle damage multiplier
	private _muzzleDamageMul = 1;
	if (_ammoType != "" and {!isNull _instigator}) then {
		private _instigatorSide       = _instigator getVariable [QGVAR(side), sideEmpty];
		private _instigatorMuzzleLUT  = _instigator getVariable [QGVAR(muzzleLUT), createHashMap];
		private _muzzleDamageMulCache = missionNamespace getVariable [format [QGVAR(muzzleDamageMulCache_%1), _instigatorSide], createHashMap];
		private _muzzle               = _instigatorMuzzleLUT getOrDefault [_ammoType, ""];
		_muzzleDamageMul              = _muzzleDamageMulCache getOrDefault [_muzzle, 1];
	};

	// Cache the overall damage at the start of the event
	if (_context == 0) exitWith {

		// Flag the vehicle as having received damage (interfaces with gm_sys_monitorEntityDamage)
		GVAR(gm_sys_monitorEntityDamage_vehicles) pushBackUnique _veh;

		// Edge case: killing vehicles through Zeus
		if (isNull _source and {isNull _instigator} and {_newRawTotalDamage >= 1}) then {
			_veh setVariable [QGVAR(damage_enum), MACRO_ENUM_DAMAGE_CURATOR, false];
			//diag_log "Killing vehicle through zeus";
			0;

		} else {
			private _prevTotalDamage   = damage _veh;
			private _damage            = (_newRawTotalDamage - _prevTotalDamage) max 0;
			private _prevOverallDamage = _veh getVariable [QGVAR(damage_overall), 0];

			// Consider the vehicle health multiplier
			private _healthMulCache = missionNamespace getVariable [format [QGVAR(vehicleHealthMulCache_%1), _side], createHashMap];
			private _healthMul      = _healthMulCache getOrDefault [toLower typeOf _veh, 1];
			_damage = _damage * _muzzleDamageMul / _healthMul;

			if (_damage > _prevOverallDamage) then {
				//diag_log format ["  (%1) Caching overall damage: %2", diag_frameNo, _damage];
				_veh setVariable [QGVAR(damage_overall),    _damage, false];
				_veh setVariable [QGVAR(damage_source),     _source, false];
				_veh setVariable [QGVAR(damage_instigator), _instigator, false];
				_veh setVariable [QGVAR(damage_ammoType),   _ammoType, false];

			};

			// Do not modify overall damage!
			_prevTotalDamage;
		};
	};



	private _damageEnum      = MACRO_ENUM_DAMAGE_UNKNOWN;
	private _damageMul       = 1;
	private _prevTotalDamage = _veh getHitPointDamage _hitPoint;
	private _damage          = _newRawTotalDamage - _prevTotalDamage;

	// Filter out minuscule damage increments
	if (_damage < 0.0001) exitWith {
		//diag_log format ["  Filtering low damage (%1): %2", _hitPoint, _damage];
		_prevTotalDamage
	};



	// Fetch the vehicle health multiplier
	private _healthMulCache = missionNamespace getVariable [format [QGVAR(vehicleHealthMulCache_%1), _side], createHashMap];
	private _healthMul      = _healthMulCache getOrDefault [toLower typeOf _veh, 1];

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
	private _damageAdjusted = _damage * _damageMul * _muzzleDamageMul / _healthMul;
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

	// Hull damage is handled separately in gm_sys_monitorEntityDamage to reflect the vehicle's total health
	if (_hitPoint == "hithull") then {
		_newCalcTotalDamage = _prevTotalDamage;
	};

	_newCalcTotalDamage;
};
