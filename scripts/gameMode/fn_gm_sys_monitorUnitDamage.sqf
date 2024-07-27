/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Iterates over all local units and raises damage events (if any damage is detected) by executing
		gm_processUnitDamage on them.

		Previously, damage processing was done exclusively on the server, but testing has shown that this introduces
		significant delays in multiplayer. Instead we run things locally, which should be fine seeing as HandleDamage
		exclusively runs on the local/owning machine anyway.

		Damage detection is performed in this script (once per frame), as doing so from directly within the
		HandleDamage EH might raise multiple damage events within a single frame (once for each affected hitpart).
		We don't want that, as it would incur a performance penalty.

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

		// Reset the state
		_x setVariable [QGVAR(damage_stored), 0, false];
		_x setVariable [QGVAR(damage_storedProcessed), 0, false];
		_x setVariable [QGVAR(damage_storedHitPoint), "", false];
	} forEach (allUnits select {local _x});

	GVAR(gm_sys_monitorUnitDamage_update) = false;
}];
