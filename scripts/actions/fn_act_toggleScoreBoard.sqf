/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LE]
		Toggles the scoreboard.

		Only executed on the client.
	Arguments:
		0:	<BOOLEAN>	True if the keybinding was pressed, false if it was released
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

params [
	["_keyPressed", false, [false]]
];

if (!hasInterface or {GVAR(missionState) >= MACRO_ENUM_MISSION_ENDING} or {!isNull curatorCamera}) exitWith {false};

disableSerialization;





MACRO_FNC_INITVAR(GVAR(ui_scoreBoard_isDialog), false);





private _scoreBoard = uiNamespace getVariable [QGVAR(RscScoreBoard), displayNull];

// Pressing the toggleScoreBoard keybinding while in dialog mode should close the scoreboard
if (GVAR(ui_scoreBoard_isDialog) and {!isNull _scoreBoard}) then {
	if (_keyPressed) then {
		["ui_close", true] call FUNC(ui_scoreBoard);
	};

// In rscTitle mode, key press and release events should toggle the scoreboard
} else {
	if (_keyPressed and {isNull _scoreBoard}) then {
		["ui_init"] call FUNC(ui_scoreBoard);
	} else {
		["ui_close", true] call FUNC(ui_scoreBoard);
	};
};





true;
