/* --------------------------------------------------------------------------------------------------------------------
	Author:		Cre8or
	Description:
		Opens and handles the spawn menu UI. Accepts an event name (e.g. "ui_init") and an optional array with
		additional parameters that might be required for the specified event.
	Arguments:
		0:	<STRING>	Name of the event
		1:	<ARRAY>		Array of additional parameters for the specified event (optional, default: [])
	Returns:
		(nothing)
	EXAMPLE:
		["ui_init"] call cre8ive_conquest_fnc_ui_spawnMenu
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"

#include "..\..\res\macros\cond_isValidGroup.inc"
#include "..\..\res\macros\fnc_initVar.inc"
#include "..\..\res\macros\fnc_leaveGroup.inc"
#include "..\..\res\macros\fnc_submitNewCallsign.inc"

params [
	["_event", "", [""]],
	["_args", []]
];

_event = toLower _event;

disableSerialization;
private _eventExists = false;
private _spawnMenu = uiNamespace getVariable [QGVAR(RscSpawnMenu), displayNull];

if (isNull _spawnMenu and {_event != "ui_init"}) exitWith {
	// DEBUG
	//diag_log format ["[CONQUEST] Spawn menu isn't open! (%1)", _event];
	//systemChat format ["Spawn menu isn't open! (%1)", _event];
};





switch (_event) do {

	#include "spawnMenu\ui_button_click.sqf"
	#include "spawnMenu\ui_char_entered.sqf"
	#include "spawnMenu\ui_close.sqf"
	#include "spawnMenu\ui_focus_reset.sqf"
	#include "spawnMenu\ui_init.sqf"
	#include "spawnMenu\ui_key_down.sqf"
	#include "spawnMenu\ui_listbox_changed.sqf"
	#include "spawnMenu\ui_mouse_moving.sqf"
	#include "spawnMenu\ui_mousez_changed.sqf"
	#include "spawnMenu\ui_update_deploy.sqf"
	#include "spawnMenu\ui_update_role.sqf"
	#include "spawnMenu\ui_update_side.sqf"
	#include "spawnMenu\ui_update_spawn.sqf"
};





// DEBUG: Check if the event was recognised - if not, print a message
if (!_eventExists) then {
	private _str = format ["[CONQUEST] (%1) SpawnMenu: Unknown event '%2' called!", time, _event];
	systemChat _str;
	diag_log _str;
};
