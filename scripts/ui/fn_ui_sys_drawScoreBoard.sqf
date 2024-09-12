/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles the drawing of the scoreboard.

		Only executed once by the client upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

if (!hasInterface) exitWith {};





// Set up some variables
MACRO_FNC_INITVAR(GVAR(ui_sys_drawScoreBoard_EH), -1);

MACRO_FNC_INITVAR(GVAR(kb_act_pressed_showScoreBoard), false);





removeMissionEventHandler ["EachFrame", GVAR(ui_sys_drawScoreBoard_EH)];
GVAR(ui_sys_drawScoreBoard_EH) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};



	// Handle the scoreboard UI
	private _UI = uiNamespace getVariable [QGVAR(RscScoreBoard), displayNull];

	if (GVAR(kb_act_pressed_showScoreBoard)) then {

		if (isNull _UI) then {
			QGVAR(RscScoreBoard) cutRsc [QGVAR(RscScoreBoard), "PLAIN"];
			_UI = uiNamespace getVariable [QGVAR(RscScoreBoard), displayNull];
		};

		private _time = time;
		private _ctrlGrpMain = _UI displayCtrl MACRO_IDC_SB_CTRLGRP;

	} else {

		if (!isNull _UI) then {
			QGVAR(RscScoreBoard) cutRsc ["Default", "PLAIN"];
		};
	};

}];
