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
MACRO_FNC_INITVAR(GVAR(ui_sys_drawScoreBoard_nextUpdate), -1);

MACRO_FNC_INITVAR(GVAR(kb_act_pressed_showScoreBoard), false);





removeMissionEventHandler ["EachFrame", GVAR(ui_sys_drawScoreBoard_EH)];
GVAR(ui_sys_drawScoreBoard_EH) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};



	// Handle the scoreboard UI
	private _UI = uiNamespace getVariable [QGVAR(RscScoreBoard), displayNull];

	if (GVAR(kb_act_pressed_showScoreBoard)) then {

		private _ctrlGrp   = _UI displayCtrl MACRO_IDC_SB_CTRLGRP;
		private _safeZoneX = safeZoneX;
		private _safeZoneY = safeZoneY;
		private _safeZoneW = safeZoneW;
		private _safeZoneH = safeZoneH;

		private _time       = time;
		private _sidesValid = GVAR(sides) select {_x != sideEmpty};
		_sidesValid params [["_sideLeft", sideEmpty], ["_sideMiddle", sideEmpty], ["_sideRight", sideEmpty]];



		// Initialise the UI
		if (isNull _UI) then {
			QGVAR(RscScoreBoard) cutRsc [QGVAR(RscScoreBoard), "PLAIN"];
			GVAR(ui_sys_drawScoreBoard_nextUpdate) = -1;

			_UI      = uiNamespace getVariable [QGVAR(RscScoreBoard), displayNull];
			_ctrlGrp = _UI displayCtrl MACRO_IDC_SB_CTRLGRP;

			// Adjust the size and position to the amount of sides in the mission
			if (count _sidesValid <= 2) then {
				private _pos = ctrlPosition _ctrlGrp;

				_pos set [0, _safeZoneX + _safezoneW / 2 - MACRO_POS_SB_WIDTH_COLUMN];
				_pos set [2, MACRO_POS_SB_WIDTH_COLUMN * 2];
				_ctrlGrp ctrlSetPosition _pos;
				_ctrlGrp ctrlCommit 0;
			};

			{
				_x params ["_sideX", "_idcSideFlag", "_idcSideName", "_idcListBox"];

				if (_sideX == sideEmpty) then {
					continue;
				};

				(_UI displayCtrl _idcSideName) ctrlSetText ([_sideX] call FUNC(gm_getSideName));
				(_UI displayCtrl _idcSideFlag) ctrlSetText ([_sideX] call FUNC(gm_getFlagTexture));
			} forEach [
				[_sideLeft,   MACRO_IDC_SB_SIDE_FLAG_LEFT_PICTURE,   MACRO_IDC_SB_SIDE_NAME_LEFT_TEXT,   MACRO_IDC_SB_SIDE_PLAYERS_LEFT_LISTBOX],
				[_sideMiddle, MACRO_IDC_SB_SIDE_FLAG_MIDDLE_PICTURE, MACRO_IDC_SB_SIDE_NAME_MIDDLE_TEXT, MACRO_IDC_SB_SIDE_PLAYERS_MIDDLE_LISTBOX],
				[_sideRight,  MACRO_IDC_SB_SIDE_FLAG_RIGHT_PICTURE,  MACRO_IDC_SB_SIDE_NAME_RIGHT_TEXT,  MACRO_IDC_SB_SIDE_PLAYERS_RIGHT_LISTBOX]
			];
		};



		// Update the scoreboard contents
		if (_time > GVAR(ui_sys_drawScoreBoard_nextUpdate)) then {
			GVAR(ui_sys_drawScoreBoard_nextUpdate) = _time + MACRO_SB_SYS_UPDATEINTERVAL;



			{
				_x params ["_sideX", "_idcSideTickets", "_idcListBox"];

				if (_sideX == sideEmpty) then {
					continue;
				};

				(_UI displayCtrl _idcSideTickets) ctrlSetText str ([_sideX] call FUNC(gm_getSideTickets));

				private _ctrlListBox = _UI displayCtrl _idcListBox;
				lnbClear _ctrlListBox;

				private ["_name", "_score", "_kills", "_deaths", "_revives", "_ping"];
				{
					_name    = name _x;
					_score   = -200 + floor random 500;
					_kills   = 0;
					_deaths  = 0;
					_revives = 0;
					_ping    = 0;

					_ctrlListBox lnbAddRow ["", _name, "", "", "", "", ""];

					_ctrlListBox lnbSetTextRight [[_forEachIndex, 2], str _score];
					_ctrlListBox lnbSetValue [[_forEachIndex, 2], _score];
					_ctrlListBox lnbSetTextRight [[_forEachIndex, 3], str _kills];
					_ctrlListBox lnbSetTextRight [[_forEachIndex, 4], str _deaths];
					_ctrlListBox lnbSetTextRight [[_forEachIndex, 5], str _revives];
					_ctrlListBox lnbSetTextRight [[_forEachIndex, 6], str _ping];

					if (isPlayer _x) then {
						_ctrlListBox lnbSetPicture [[_forEachIndex, 0], squadParams _x # 0 # 4];
					} else {
						_ctrlListBox lnbSetText [[_forEachIndex, 0], "AI"];
						_ctrlListBox lnbSetColor [[_forEachIndex, 0], SQUARE(MACRO_COLOUR_A100_GREY)];
					};
				} forEach allUnits;

    			[_ctrlListBox, 2] lnbSortBy ["VALUE", true, false, false, true]

			} forEach [
				[_sideLeft,   MACRO_IDC_SB_SIDE_TICKETS_LEFT_TEXT,   MACRO_IDC_SB_SIDE_PLAYERS_LEFT_LISTBOX],
				[_sideMiddle, MACRO_IDC_SB_SIDE_TICKETS_MIDDLE_TEXT, MACRO_IDC_SB_SIDE_PLAYERS_MIDDLE_LISTBOX],
				[_sideRight,  MACRO_IDC_SB_SIDE_TICKETS_RIGHT_TEXT,  MACRO_IDC_SB_SIDE_PLAYERS_RIGHT_LISTBOX]
			];
		};



	} else {

		if (!isNull _UI) then {
			QGVAR(RscScoreBoard) cutRsc ["Default", "PLAIN"];
		};
	};

}];
