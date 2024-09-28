/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LE]
		Toggles the spawn menu. Only available when the player is alive and spawned; for all other cases, see
		gm_sys_handlePlayerRespawn.

		Only executed on the client.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

if (!hasInterface or {GVAR(missionState) >= MACRO_ENUM_MISSION_ENDING} or {!isNull curatorCamera}) exitWith {false};

disableSerialization;





// Toggle the spawn menu
private _spawnMenu = uiNamespace getVariable [QGVAR(RscSpawnMenu), displayNull];

if (isNull _spawnMenu) then {
	["ui_init"] call FUNC(ui_spawnMenu);
} else {
	["ui_close", true] call FUNC(ui_spawnMenu);
};





true;
