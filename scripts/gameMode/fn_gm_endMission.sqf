/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Initiates the mission ending sequence and announces the given side as the winner.
		This function handles both client and server code, and as such must be executed globally.
	Arguments:
		0:      <SIDE>		The side that won the mission
		!:      <BOOLEAN>	Whether or not the ending should be more dramatic (affects the displayed text,
					and selected music)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"

#include "..\..\res\macros\fnc_initVar.inc"

// Fetch our params
params [
	["_winningSide", sideEmpty, [sideEmpty]],
	["_isDecisive", false, [false]]
];





// Set up some variables
MACRO_FNC_INITVAR(GVAR(EH_endMission_eachFrame),-1);

GVAR(endMission_startTime) = time;
GVAR(endMission_stage) = MACRO_ENUM_ENDMISSION_INIT;
GVAR(endMission_nextStageTime) = 0;





// Server code
if (isServer) then {

	GVAR(missionState) = MACRO_ENUM_MISSION_ENDING;
	publicVariable QGVAR(missionState);

	[true] remoteExecCall [QFUNC(setSafeStart), 0, QGVAR(safeStart)];
};





// Client code
if (hasInterface) then {

	[false] call FUNC(ui_blackScreen);
	[MACRO_ENUM_INPUTLOCK_ENDMISSION, true] call FUNC(ui_disableUserInput);

	// Stop any active radio messages
	[MACRO_ENUM_RADIOMSG_INVALID, true] call FUNC(gm_playRadioMsg);

	private _isTie = (_winningSide == sideEmpty);
	private _isWin = (!_isTie and {_winningSide == GVAR(side)});

	// Play music
	0 fadeMusic 0;
	1 fadeMusic 1;

	if (_isWin) then {
		if (_isDecisive) then {
			playMusic ["LeadTrack01_F_Mark", 137];
		} else {
			playMusic ["LeadTrack01_F_Jets", 117];
		};
	} else {
		if (_isDecisive) then {
			playMusic ["EventTrack01_F_EPC", 19.6];
		} else {
			playMusic ["Leadtrack06_F_Tank", 0];
		};
	};



	// Close the spawn menu, if it is still open
	["ui_close", true] call FUNC(ui_spawnMenu);

	// Close the scoreboard
	["ui_close", true] call FUNC(ui_scoreBoard);

	// Disable the combat area warning screen
	QGVAR(RscCombatArea) cutRsc ["Default", "PLAIN"];

	// Disable the score and kill feeds
	QGVAR(RscScoreFeed) cutRsc ["Default", "PLAIN"];
	QGVAR(RscKillFeed) cutRsc ["Default", "PLAIN"];

	// Display the end screen
	QGVAR(RscEndScreen) cutRsc [QGVAR(RscEndScreen), "PLAIN"];

	private _endScreen = uiNamespace getVariable [QGVAR(RscEndScreen), displayNull];
	private _topText    = _endScreen displayCtrl MACRO_IDC_ES_TOP_TEXT;
	private _bottomText = _endScreen displayCtrl MACRO_IDC_ES_BOTTOM_TEXT;
	private _sideLeft   = GVAR(sides) # 0;
	private _sideMiddle = GVAR(sides) # 1;
	private _sideRight  = GVAR(sides) # 2;

	// On a two-sides setup, hide the middle controls
	private _indexEmpty = GVAR(sides) find sideEmpty;
	if (_indexEmpty >= 0) then {

		switch (_indexEmpty) do {
			case 0: {
				_sideLeft = _sideMiddle;
			};
			case 2: {
				_sideRight = _sideMiddle;
			};
		};
		_sideMiddle = sideEmpty;

		(_endScreen displayCtrl MACRO_IDC_ES_FLAG_MIDDLE_PICTURE) ctrlShow false;
		(_endScreen displayCtrl MACRO_IDC_ES_TICKETS_MIDDLE_TEXT) ctrlShow false;
	};

	if (_isWin) then {
		_topText ctrlSetText (["VICTORY", "DECISIVE VICTORY"] select _isDecisive);
	} else {
		if (_isTie) then {
			_topText ctrlSetText "DRAW";
		} else {
			_topText ctrlSetText (["DEFEAT", "CRUSHING DEFEAT"] select _isDecisive);
		};
	};

	if (_isTie) then {
		_bottomText ctrlSetText "NOBODY WINS";
	} else {
		_bottomText ctrlSetText toUpper format ["%1 wins", [_winningSide] call FUNC(gm_getSideName)];
	};

	// Set up the flags and tickets
	{
		_x params ["_sideX", "_idcFlag", "_idcTickets"];

		(_endScreen displayCtrl _idcFlag) ctrlSetText ([_sideX] call FUNC(gm_getFlagTexture));
		(_endScreen displayCtrl _idcTickets) ctrlSetText str ([_sideX] call FUNC(gm_getSideTickets));
	} forEach [
		[_sideLeft,   MACRO_IDC_ES_FLAG_LEFT_PICTURE,   MACRO_IDC_ES_TICKETS_LEFT_TEXT],
		[_sideMiddle, MACRO_IDC_ES_FLAG_MIDDLE_PICTURE, MACRO_IDC_ES_TICKETS_MIDDLE_TEXT],
		[_sideRight,  MACRO_IDC_ES_FLAG_RIGHT_PICTURE,  MACRO_IDC_ES_TICKETS_RIGHT_TEXT]
	];



	// ACRE2 compatibility
	ACRE_IS_SPECTATOR = true;

	// Switch into the camera
	GVAR(cam_panorama) cameraEffect ["Internal", "BACK"];
	showCinemaBorder false;
};





// Handle the ending cutscene
removeMissionEventHandler ["EachFrame", GVAR(EH_endMission_eachFrame)];
GVAR(EH_endMission_eachFrame) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	private _time = time;

	// Handle the camera FOV
	if (hasInterface) then {
		private _deltaTime = _time - GVAR(endMission_startTime) + 4;
		private _FOV = 0.75 - 1.5 / _deltaTime;

		GVAR(cam_panorama) camSetFov _FOV;
		GVAR(cam_panorama) camCommit 0;
	};

	// Update the ticket counts
	// Sometimes, a publicVariable network packet for a side's ticket is queued after the call to endMission
	// (so it doesn't make it in time), and so the end screen continues to show a slightly outdated tickets
	// count. This fixed that.
	private _endScreen = uiNamespace getVariable [QGVAR(RscEndScreen), displayNull];

	{
		_x params ["_sideX", "_idcTickets"];

		(_endScreen displayCtrl _idcTickets) ctrlSetText str ([_sideX] call FUNC(gm_getSideTickets));
	} forEach [
		[GVAR(sides) # 0,	MACRO_IDC_ES_TICKETS_LEFT_TEXT],
		[GVAR(sides) # 1,	MACRO_IDC_ES_TICKETS_MIDDLE_TEXT],
		[GVAR(sides) # 2,	MACRO_IDC_ES_TICKETS_RIGHT_TEXT]
	];



	// Handle the state transitions
	if (_time > GVAR(endMission_nextStageTime)) then {

		switch (GVAR(endMission_stage)) do {

			case MACRO_ENUM_ENDMISSION_INIT: {
				GVAR(endMission_stage) = MACRO_ENUM_ENDMISSION_PLAYMUSIC;
				GVAR(endMission_nextStageTime) = _time + 10;
			};
			case MACRO_ENUM_ENDMISSION_PLAYMUSIC: {
				GVAR(endMission_stage) = MACRO_ENUM_ENDMISSION_SHOWSCOREBOARD;
				GVAR(endMission_nextStageTime) = _time + 15;

				// Close the end screen and force-open the scoreboard
				QGVAR(RscEndScreen) cutRsc ["Default", "PLAIN"];
				["ui_init", true] call FUNC(ui_scoreBoard);
			};

			case MACRO_ENUM_ENDMISSION_SHOWSCOREBOARD: {
				GVAR(endMission_stage) = MACRO_ENUM_ENDMISSION_FADEOUT;

				private _fadeDuration = 5;
				GVAR(endMission_nextStageTime) = _time + _fadeDuration + 2;	// Extra delay for a subtle dramatic note

				_fadeDuration fadeMusic 0;
				_fadeDuration fadeSound 0;
				[true, _fadeDuration] call FUNC(ui_blackScreen);
			};

			case MACRO_ENUM_ENDMISSION_FADEOUT: {
				GVAR(endMission_stage) = MACRO_ENUM_ENDMISSION_ENDING;

				// Close the scoreboard
				["ui_close", true] call FUNC(ui_scoreBoard);

				#ifdef MACRO_DEBUG_GM_CONTINUEAFTERENDING
					[MACRO_ENUM_INPUTLOCK_ENDMISSION, false] call FUNC(ui_disableUserInput);
					[false] call FUNC(ui_blackScreen);

					playMusic "";
					0 fadeSound 1;
					0 fadeMusic 1;

					switchCamera player;
					GVAR(cam_panorama) cameraEffect ["Terminate", "BACK"];
					GVAR(cam_panorama) camSetFov 0.75;
					GVAR(cam_panorama) camCommit 0;

					// Re-enable the score and kill feeds
					QGVAR(RscScoreFeed) cutRsc [QGVAR(RscScoreFeed), "PLAIN"];
					QGVAR(RscKillFeed) cutRsc [QGVAR(RscKillFeed), "PLAIN"];

					[MACRO_ENUM_INPUTLOCK_ENDMISSION, false] call FUNC(ui_disableUserInput);
				#else
					endMission "END1";
				#endif
			};
		};
	};
}];
