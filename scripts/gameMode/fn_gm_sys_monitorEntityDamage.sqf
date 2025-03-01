/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Iterates over all local units and vehicles, and raises damage events (if any damage is detected) by executing
		gm_processUnitDamage on them.

		Damage detection is performed in this script (once per frame), as doing so from directly within the
		HandleDamage EH might raise multiple damage events within a single frame (once for each affected hitpart).
		The unit and vehicle damage handlers instead raise a flag when damage has occured, which triggers the
		execution of this monitor system.

		Only executed once by all machines upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"

#include "..\..\res\macros\fnc_initVar.inc"





MACRO_FNC_INITVAR(GVAR(gm_sys_monitorEntityDamage_EH), -1);
MACRO_FNC_INITVAR(GVAR(gm_sys_monitorEntityDamage_update), false);

GVAR(gm_sys_monitorEntityDamage_units)    = [];
GVAR(gm_sys_monitorEntityDamage_vehicles) = [];





removeMissionEventHandler ["EachFrame", GVAR(gm_sys_monitorEntityDamage_EH)];
GVAR(gm_sys_monitorEntityDamage_EH) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused or {GVAR(missionState) < MACRO_ENUM_MISSION_LIVE}) exitWith {};



	// Look for injured local units, and if any are found, process their damage
	private ["_isHeadShot", "_storedDamage", "_maxHitPoint"];
	{
		if (!local _x) then {continue};

		_isHeadShot   = false;
		_storedDamage = _x getVariable [QGVAR(damage_stored), 0];
		_maxHitPoint  = _x getVariable [QGVAR(damage_storedHitPoint), ""];

		if (_storedDamage <= 0) then {continue};

		// Headshot bonus
		if (_maxHitPoint in ["hithead", "hitface"]) then {
			_isHeadShot = true;
			_storedDamage = _storedDamage * MACRO_GM_UNIT_DAMAGEMUL_HEADSHOT;
		};

		[
			_x,
			_storedDamage,
			_x getVariable [QGVAR(damage_enum), MACRO_ENUM_DAMAGE_UNKNOWN],
			_x getVariable [QGVAR(damage_source), objNull],
			_x getVariable [QGVAR(damage_instigator), objNull],
			_storedDamage >= 0,
			_x getVariable [QGVAR(damage_ammoType), ""],
			_isHeadShot
		] call FUNC(gm_processUnitDamage);

		// Reset the damage event state
		_x setVariable [QGVAR(damage_stored),          0, false];
		_x setVariable [QGVAR(damage_storedProcessed), 0, false];
		_x setVariable [QGVAR(damage_storedHitPoint),  "", false];
		_x setVariable [QGVAR(damage_enum),            MACRO_ENUM_DAMAGE_UNKNOWN, false];
		_x setVariable [QGVAR(damage_source),          objNull, false];
		_x setVariable [QGVAR(damage_instigator),      objNull, false];

	} forEach GVAR(gm_sys_monitorEntityDamage_units);



	// Look for injured/destroyed local vehicles, and if any are found, process their damage
	private ["_enum", "_damage"];
	{
		if (!local _x) then {continue};

		_healthOld = _x getVariable [QGVAR(health), 1];
		_healthNew = [_x] call FUNC(veh_calculateHealth);
		_enum      = _x getVariable [QGVAR(damage_enum), MACRO_ENUM_DAMAGE_UNKNOWN];

		//systemChat format ["(%1) %2 damaged: %3", diag_frameNo, typeOf _x, _healthNew];

		if (_enum == MACRO_ENUM_DAMAGE_CURATOR) then {
			_damage = -1;
		} else {
			_damage = _healthOld - _healthNew;

			// Combine the pending damage from the previous HandleDamage iterations into a final value
			private _damageCalc = _x getVariable [QGVAR(damage_calc), 0];

			// Since we are unable to determine the cause of overall damage directly, we can infer its
			// parameters from the highest damage's source (which we already store for damage tracking purposes).
			// This way we can retroactively apply the damage multipliers as in the hitpoint iteration check.
			private _damageOverall    = _x getVariable [QGVAR(damage_overall), 0];
			private _damageMulOverall = switch (_enum) do {
				case MACRO_ENUM_DAMAGE_BULLET:    {MACRO_GM_VEH_DAMAGEMUL_BULLET};
				case MACRO_ENUM_DAMAGE_EXPLOSIVE: {MACRO_GM_VEH_DAMAGEMUL_EXPLOSIVE};
				case MACRO_ENUM_DAMAGE_PHYSICS:   {MACRO_GM_VEH_DAMAGEMUL_PHYSICS};
				default                           {1};
			};

			// Put everything together
			_damage = _damage + _damageCalc + _damageOverall * _damageMulOverall;
			//systemChat format ["(%1) Damage (%2): %3", diag_frameNo, typeOf _x, _damage];

			if (_damage <= 0) then {
				continue;
			};

			// Update the hull hitpoint, if this vehicle has one
			if (_x getVariable [QGVAR(hasHullHitPoint), false]) then {
				_healthNew = _healthOld - _damage;
				private _hitPointDamage = (1 - _healthNew) * MACRO_VEHICLE_HEALTH_MAXHITPOINTDAMAGE;

				_x setHitPointDamage ["hithull", _hitPointDamage min MACRO_VEHICLE_HEALTH_MAXHITPOINTDAMAGE];
			};
		};

		[
			_x,
			_damage,
			_enum,
			_x getVariable [QGVAR(damage_source), objNull],
			_x getVariable [QGVAR(damage_instigator), objNull],
			_x getVariable [QGVAR(damage_ammoType), ""]
		] call FUNC(gm_processVehicleDamage);

		// Reset the damage event state
		_x setVariable [QGVAR(damage_overall),    0, false];
		_x setVariable [QGVAR(damage_calc),       0, false];
		_x setVariable [QGVAR(damage_stored),     0, false];
		_x setVariable [QGVAR(damage_enum),       MACRO_ENUM_DAMAGE_UNKNOWN, false];
		_x setVariable [QGVAR(damage_source),     objNull, false];
		_x setVariable [QGVAR(damage_instigator), objNull, false];

	} forEach GVAR(gm_sys_monitorEntityDamage_vehicles);



	// Empty the arrays of damaged units/vehicles
	GVAR(gm_sys_monitorEntityDamage_units)    = [];
	GVAR(gm_sys_monitorEntityDamage_vehicles) = [];
}];
