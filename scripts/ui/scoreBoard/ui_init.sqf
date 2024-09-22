case "ui_init": {
	_eventExists = true;

	_args params [
		["_isDialog", false, [false]]
	];

	// Set up some variables
	MACRO_FNC_INITVAR(GVAR(ui_scoreBoard_EH), -1);
	MACRO_FNC_INITVAR(GVAR(ui_scoreBoard_cache), createHashMap);
	MACRO_FNC_INITVAR(GVAR(ui_scoreBoard_isDialog), false);

	GVAR(ui_scoreBoard_selectedSide) = GVAR(side);
	GVAR(ui_scoreBoard_selectedUID)  = [player] call FUNC(unit_getUID);





	// If the scoreboard is already open, close it
	if (!isNull _scoreBoard) then {
		["ui_close", true] call FUNC(ui_scoreBoard);
	};

	// Open the scorebaord
	if (_isDialog) then {
		_scoreBoard = (findDisplay 46) createDisplay QGVAR(RscScoreBoard);
	} else {
		QGVAR(RscScoreBoard) cutRsc [QGVAR(RscScoreBoard), "PLAIN"];
		_scoreBoard = uiNamespace getVariable [QGVAR(RscScoreBoard), displayNull];
	};

	GVAR(ui_scoreBoard_isDialog)   = _isDialog;
	GVAR(ui_scoreBoard_nextUpdate) = -1;
	GVAR(ui_scoreBoard_sides)      = GVAR(sides) select {_x != sideEmpty};

	GVAR(ui_scoreBoard_sides) params [["_sideLeft", sideEmpty], ["_sideMiddle", sideEmpty], ["_sideRight", sideEmpty]];
	private _time = time;





	// Adjust the size and position to the amount of sides in the mission
	if (count GVAR(ui_scoreBoard_sides) <= 2) then {
		private _ctrlGrp = _scoreBoard displayCtrl MACRO_IDC_SB_CTRLGRP;
		private _pos     = ctrlPosition _ctrlGrp;

		_pos set [0, safeZoneX + safezoneW / 2 - MACRO_POS_SB_WIDTH_COLUMN];
		_pos set [2, MACRO_POS_SB_WIDTH_COLUMN * 2];
		_ctrlGrp ctrlSetPosition _pos;
		_ctrlGrp ctrlCommit 0;
	};

	{
		_x params ["_sideX", "_idcSideFlag", "_idcSideName", "_idcListBox"];

		if (_sideX == sideEmpty) then {
			continue;
		};

		(_scoreBoard displayCtrl _idcSideName) ctrlSetText ([_sideX] call FUNC(gm_getSideName));
		(_scoreBoard displayCtrl _idcSideFlag) ctrlSetText ([_sideX] call FUNC(gm_getFlagTexture));
	} forEach [
		[_sideLeft,   MACRO_IDC_SB_SIDE_FLAG_LEFT_PICTURE,   MACRO_IDC_SB_SIDE_NAME_LEFT_TEXT,   MACRO_IDC_SB_SIDE_PLAYERS_LEFT_LISTBOX],
		[_sideMiddle, MACRO_IDC_SB_SIDE_FLAG_MIDDLE_PICTURE, MACRO_IDC_SB_SIDE_NAME_MIDDLE_TEXT, MACRO_IDC_SB_SIDE_PLAYERS_MIDDLE_LISTBOX],
		[_sideRight,  MACRO_IDC_SB_SIDE_FLAG_RIGHT_PICTURE,  MACRO_IDC_SB_SIDE_NAME_RIGHT_TEXT,  MACRO_IDC_SB_SIDE_PLAYERS_RIGHT_LISTBOX]
	];





	// Keep the scoreboard up to date
	GVAR(ui_scoreBoard_EH) = addMissionEventHandler ["EachFrame", {

		if (isGamePaused) exitWith {};

		private _time = time;

		if (_time > GVAR(ui_scoreBoard_nextUpdate)) then {
			GVAR(ui_scoreBoard_nextUpdate) = _time + MACRO_SB_SYS_UPDATEINTERVAL;

			["ui_update"] call FUNC(ui_scoreBoard);
		};
	}];

	// Register CBA's event handlers on the dialog display
	if (GVAR(ui_scoreBoard_isDialog)) then {
		[_scoreBoard] call FUNC(cba_initDisplay);
	};

	_scoreBoard displayAddEventHandler ["Unload", {["ui_close"] call FUNC(ui_scoreBoard)}];

};
