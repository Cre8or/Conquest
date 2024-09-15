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

	// DEBUG
	//GVAR(kb_act_pressed_showScoreBoard) = true;



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



		if (_time > GVAR(ui_sys_drawScoreBoard_nextUpdate)) then {
			GVAR(ui_sys_drawScoreBoard_nextUpdate) = _time + MACRO_SB_SYS_UPDATEINTERVAL;

			private _player       = player;
			private _plyGroup     = group _player;
			private _allSideUnits = _sidesValid apply {[]};
			private _sideIndexes  = GVAR(sides) apply {_sidesValid find _x}; // Used to match AI units' side indexes

			// Aggregate players data from all sides
			private ["_sideX", "_sideIndex", "_sideUnits"];
			{
				_sideX = _x getVariable [QGVAR(side), sideEmpty];

				_sideIndex = _sidesValid find _sideX;
				if (_sideIndex < 0) then {
					continue;
				};

				_sideUnits = _allSideUnits # _sideIndex;
				_sideUnits pushBack [
					squadParams _x # 0 # 4, // squadIcon
					name _x, // name
					-200 + floor random 500, // score
					floor random 20, // kills
					floor random 20, // deaths
					floor random 5, // revives
					floor random 200, // ping
					group _x, // group
					[_x] call FUNC(unit_isAlive), // isAlive
					true, // isPlayer
					_x == _player // isCurrentPlayer
				];
			} forEach allPlayers;

			// Aggregate AI units data from all sides
			private ["_groupIndex", "_groupX", "_unitX"];
			{
				_sideIndex = _x # 0;

				// Remap the "global" side index to the list of valid sides
				_sideIndex = _sideIndexes # _sideIndex;
				if (_sideIndex < 0) then {
					continue;
				};

				_side       = _sidesValid # _sideIndex;
				_groupIndex = _x # MACRO_ENUM_AIIDENTITY_GROUPINDEX;
				_groupX     = missionNamespace getVariable [format [QGVAR(AIGroup_%1_%2), _side, _groupIndex], grpNull];
				_unitX      = missionNamespace getVariable [format [QGVAR(AIUnit_%1), _forEachIndex], objNull];

				_sideUnits = _allSideUnits # _sideIndex;
				_sideUnits pushBack [
					"", // squadIcon (AI)
					_x # MACRO_ENUM_AIIDENTITY_NAME, // name
					-200 + floor random 500, // score
					floor random 20, // kills
					floor random 20, // deaths
					floor random 5, // revives
					0, // ping
					_groupX, // group
					[_unitX] call FUNC(unit_isAlive), // isAlive
					false // isPlayer
				];

			} forEach GVAR(cl_AIIdentities);

			// Update the scoreboard listboxes for all sides
			private ["_isPlayerSide", "_rowValue", "_colour"];
			{
				_x params ["_sideX", "_idcSideTickets", "_idcListBox"];

				if (_sideX == sideEmpty) then {
					continue;
				};

				scopeName QGVAR(ui_sys_drawScoreBoard_side);

				(_UI displayCtrl _idcSideTickets) ctrlSetText str ([_sideX] call FUNC(gm_getSideTickets));

				private _ctrlListBox = _UI displayCtrl _idcListBox;
				lnbClear _ctrlListBox;

				_sideUnits    = _allSideUnits param [_forEachIndex, []];
				_isPlayerSide = (_sideX == GVAR(side));
				{
					_x params ["_squadIcon", "_name", "_score", "_kills", "_deaths", "_revives", "_ping", "_group", "_isAlive", "_isPlayer", ["_isCurrentPlayer", false]];

					_ctrlListBox lnbAddRow ["", _name, "", "", "", "", ""];
					_ctrlListBox lnbSetTextRight [[_forEachIndex, 2], str _score];
					_ctrlListBox lnbSetValue [[_forEachIndex, 2], _score];
					_ctrlListBox lnbSetTextRight [[_forEachIndex, 3], str _kills];
					_ctrlListBox lnbSetTextRight [[_forEachIndex, 4], str _deaths];
					_ctrlListBox lnbSetTextRight [[_forEachIndex, 5], str _revives];

					// Differentiate players from AI units
					if (_isPlayer) then {
						_ctrlListBox lnbSetPicture [[_forEachIndex, 0], _squadIcon];
						_ctrlListBox lnbSetTextRight [[_forEachIndex, 6], str _ping];

					} else {
						_ctrlListBox lnbSetText [[_forEachIndex, 0], "AI"];
						_ctrlListBox lnbSetColor [[_forEachIndex, 0], SQUARE(MACRO_COLOUR_A25_WHITE)];
					};

					// Mark the player so they can be selected after sorting
					if (_isCurrentPlayer) then {
						_ctrlListBox lnbSetValue [[_forEachIndex, 0], 1];
					};

					// Handle row colours
					_colour = (switch (true) do {
						case (_isPlayer): {
							SQUARE(MACRO_COLOUR_A100_BLACK);
						};
						case (!_isAlive): {
							SQUARE(MACRO_COLOUR_A100_GREY);
						};
						case (_group == _plyGroup): {
							SQUARE(MACRO_COLOUR_A100_SQUAD);
						};
						case (_isPlayerSide): {
							SQUARE(MACRO_COLOUR_A100_FRIENDLY);
						};
						default {
							SQUARE(MACRO_COLOUR_A100_ENEMY);
						};
					});

					_ctrlListBox lnbSetColor [[_forEachIndex, 1], _colour];
					for "_column" from 2 to 6 do {
						_ctrlListBox lnbSetColorRight [[_forEachIndex, _column], _colour];
					};
				} forEach _sideUnits;

				// Sort by score
    			[_ctrlListBox, 2] lnbSortBy ["VALUE", true, false, false, true];

				// Select the player
				if (!_isPlayerSide) then {
					_ctrlListBox lnbSetCurSelRow -1;
					continue;
				};
				for "_i" from 0 to (count _sideUnits) - 1 do {
					_rowValue = _ctrlListBox lnbValue [_i, 0];

					if (_rowValue > 0) then {
						_ctrlListBox lnbSetCurSelRow _i;
						breakTo QGVAR(ui_sys_drawScoreBoard_side);
					};
				};

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
