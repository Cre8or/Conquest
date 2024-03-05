/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Iterates over all local units and raises damage events (if any damage is detected) by remotely
		executing gm_processUnitDamage on the server.

		Player damage detection is performed on the client (unit_onHandleDamage) and enforced on the server
		(gm_processUnitDamage). This is due to the HandleDamage EH not firing on remote units.

		Only executed once by all machines upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"

#include "..\..\res\macros\fnc_initVar.inc"





// Set up some variables
MACRO_FNC_INITVAR(GVAR(gm_sys_monitorUnitDamage_EH), -1);
MACRO_FNC_INITVAR(GVAR(gm_sys_monitorUnitDamage_update), false);





removeMissionEventHandler ["EachFrame", GVAR(gm_sys_monitorUnitDamage_EH)];
GVAR(gm_sys_monitorUnitDamage_EH) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	if (!GVAR(gm_sys_monitorUnitDamage_update) or {GVAR(missionState) < MACRO_ENUM_MISSION_LIVE}) exitWith {};

	private ["_storedDamage"];
	{
		_storedDamage = _x getVariable [QGVAR(damage_stored), 0];

		if (_storedDamage > 0) then {

			private _isHeadShot = false;
			private _maxHitPoint = _x getVariable [QGVAR(damage_storedHitPoint), ""];

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
			] remoteExecCall [QFUNC(gm_processUnitDamage), 2, false];

			// Reset the state
			_x setVariable [QGVAR(damage_stored), 0, false];
			_x setVariable [QGVAR(damage_storedProcessed), 0, false];
			_x setVariable [QGVAR(damage_storedHitPoint), "", false];
		};

	} forEach (allUnits select {local _x});

	GVAR(gm_sys_monitorUnitDamage_update) = false;
}];
