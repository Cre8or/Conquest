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





removeMissionEventHandler ["EachFrame", GVAR(gm_sys_monitorEntityDamage_EH)];
GVAR(gm_sys_monitorEntityDamage_EH) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	if (!GVAR(gm_sys_monitorEntityDamage_update) or {GVAR(missionState) < MACRO_ENUM_MISSION_LIVE}) exitWith {};

	// Reset for the next use
	GVAR(gm_sys_monitorEntityDamage_update) = false;



	// Look for injured local units, and if any are found, process their damage
	private ["_storedDamage", "_isHeadShot", "_maxHitPoint"];
	{
		_storedDamage = _x getVariable [QGVAR(damage_stored), 0];

		if (_storedDamage <= 0) then {
			continue;
		};

		_isHeadShot  = false;
		_maxHitPoint = _x getVariable [QGVAR(damage_storedHitPoint), ""];

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
			true,
			_x getVariable [QGVAR(damage_ammoType), ""],
			_isHeadShot
		] call FUNC(gm_processUnitDamage);

		// Reset the damage event state
		_x setVariable [QGVAR(damage_stored), 0, false];
		_x setVariable [QGVAR(damage_storedProcessed), 0, false];
		_x setVariable [QGVAR(damage_storedHitPoint), "", false];
	} forEach (allUnits select {local _x});



	// Look for injured/destroyed local vehicles, and if any are found, process their damage
	{
		if ((_x getVariable [QGVAR(damage_stored), 0]) <= 0) then {
			continue;
		};

		// Reset the damage event state
		_x setVariable [QGVAR(damage_stored), 0, false];

		if (local _x) then {
			_healthOld = _x getVariable [QGVAR(health), 1];
			_healthNew = [_x] call FUNC(veh_calculateHealth);

			if (_healthNew >= _healthOld and {_healthNew > 0}) then {
				_x setVariable [QGVAR(health), _healthNew, true];
				continue;
			};

			[
				_x,
				_healthOld - _healthNew,
				_x getVariable [QGVAR(damage_enum), MACRO_ENUM_DAMAGE_UNKNOWN],
				_x getVariable [QGVAR(damage_source), objNull],
				_x getVariable [QGVAR(damage_instigator), objNull],
				_x getVariable [QGVAR(damage_ammoType), ""]
			] call FUNC(gm_processVehicleDamage);
		};

	} forEach (GVAR(allVehicles));
}];
