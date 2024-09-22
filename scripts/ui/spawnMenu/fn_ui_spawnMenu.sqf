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

#include "..\..\..\res\common\macros.inc"
#include "..\..\..\mission\settings.inc"

#include "..\..\..\res\macros\fnc_initVar.inc"

// Fetch our params
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
	diag_log format ["[CONQUEST] Spawn menu isn't open! (%1)", _event];
	systemChat format ["Spawn menu isn't open! (%1)", _event];
};
private "_spawnMenu_return";





switch (_event) do {

	#include "events\ui_button_click.sqf"
	#include "events\ui_char_entered.sqf"
	#include "events\ui_focus_reset.sqf"
	#include "events\ui_init.sqf"
	#include "events\ui_key_down.sqf"
	#include "events\ui_listbox_changed.sqf"
	#include "events\ui_mouse_moving.sqf"
	#include "events\ui_mousez_changed.sqf"
	#include "events\ui_unload.sqf"
	#include "events\ui_update_deploy.sqf"
	#include "events\ui_update_role.sqf"
	#include "events\ui_update_side.sqf"
	#include "events\ui_update_spawn.sqf"
};




/*
// DEBUG: Print the event name
private _filteredEvents = [
	"ui_focus_reset",
	"ui_mouse_exit",
//	"ui_mouse_moving",
	"ui_dragging_init",
	"ui_dragging",
	"ui_update_ground",
	"ui_update_storage"
];
if !(_event in _filteredEvents) then {
	systemChat format ["(%1) %2", time, _event];
};
*/

// DEBUG: Check if the event was recognised - if not, print a message
if (!_eventExists) then {
	private _str = format ["[CONQUEST] (%1) SpawnMenu: Unknown event '%2' called!", time, _event];
	systemChat _str;
	hint _str;
};

_spawnMenu_return;
