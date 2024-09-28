/* --------------------------------------------------------------------------------------------------------------------
	Author:		Cre8or
	Description:
		Handles the scoreboard UI. Accepts an event name (e.g. "ui_init") and an optional array with
		additional parameters that might be required for the specified event.
	Arguments:
		0:	<STRING>	Name of the event
		1:	<ARRAY>		Array of additional parameters for the specified event (optional, default: [])
	Returns:
		(nothing)
	EXAMPLE:
		["ui_init"] call cre8ive_conquest_fnc_ui_scoreBoard
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"

#include "..\..\res\macros\fnc_initVar.inc"

params [
	["_event", "", [""]],
	["_args", []]
];

// Change the case to avoid mistakes
_event = toLower _event;

disableSerialization;
private _eventExists = false;
private _scoreBoard = uiNamespace getVariable [QGVAR(RscScoreBoard), displayNull];

if (isNull _scoreBoard and {_event != "ui_init"}) exitWith {
	// DEBUG
	//diag_log format ["[CONQUEST] Scoreboard isn't open! (%1)", _event];
	//systemChat format ["Scoreboard isn't open! (%1)", _event];
};





switch (_event) do {
	#include "scoreBoard\ui_close.sqf"
	#include "scoreBoard\ui_init.sqf"
	#include "scoreBoard\ui_lbselection_changed.sqf"
	#include "scoreBoard\ui_request_cursor.sqf"
	#include "scoreBoard\ui_update.sqf"
};





// DEBUG: Check if the event was recognised - if not, print a message
if (!_eventExists) then {
	private _str = format ["[CONQUEST] (%1) ScoreBoard: Unknown event '%2' called!", time, _event];
	systemChat _str;
	diag_log _str;
};
