/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles the drawing of the tutorial hints. The necessary data is provided by gm_sys_tutorialHints.

		Only executed once by the client upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_addHTMLColour.inc"
#include "..\..\res\macros\fnc_fadeCtrls.inc"
#include "..\..\res\macros\fnc_initVar.inc"
#include "..\..\res\macros\fnc_tweens.inc"

if (!hasInterface) exitWith {};





MACRO_FNC_INITVAR(GVAR(ui_sys_drawTutorialHints_EH), -1);

MACRO_FNC_INITVAR(GVAR(gm_sys_tutorialHints_startTime), -1);
MACRO_FNC_INITVAR(GVAR(gm_sys_tutorialHints_expiration), -1);

GVAR(ui_sys_drawTutorialHints_update)   = false; // Interfaces with gm_sys_tutorialHints
GVAR(ui_sys_drawTutorialHints_data)     = [];    // Interfaces with gm_sys_tutorialHints
GVAR(ui_sys_drawTutorialHints_prevBody) = "";
GVAR(ui_sys_drawTutorialHints_height)   = 0;

QGVAR(RscTutorialHints) cutRsc ["Default", "PLAIN"];





removeMissionEventHandler ["EachFrame", GVAR(ui_sys_drawTutorialHints_EH)];
GVAR(ui_sys_drawTutorialHints_EH) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	private _time      = time;
	private _UI        = uiNamespace getVariable [QGVAR(RscTutorialHints), displayNull];
	private _strTitle = "ERROR: Invalid hint";
	private _strBody  = "";
	switch (GVAR(gm_sys_tutorialHints_activeHint)) do {

		#include "drawTutorialHints\hint_magazineRepacking.sqf"
		#include "drawTutorialHints\hint_reopenSpawnMenu.sqf"
		#include "drawTutorialHints\hint_roleAbilities.sqf"
	};





	// On external update requests, invalidate the UI by forcefully closing it.
	if (GVAR(ui_sys_drawTutorialHints_update)) then {
		GVAR(ui_sys_drawTutorialHints_update) = false;

		QGVAR(RscTutorialHints) cutRsc ["Default", "PLAIN"];
		_UI = displayNull;
	};



	// Handle the active hint
	if (GVAR(gm_sys_tutorialHints_activeHint) != MACRO_ENUM_TUTORIALHINT_INVALID) then {

		if (isNull _UI) then {
			GVAR(ui_sys_drawTutorialHints_prevBody) = "";

			QGVAR(RscTutorialHints) cutRsc [QGVAR(RscTutorialHints), "PLAIN"];
			_UI = uiNamespace getVariable [QGVAR(RscTutorialHints), displayNull];
			playSoundUI [QGVAR(Hint), 1, 1];

			(_UI displayCtrl MACRO_IDC_TH_TITLE_TEXT) ctrlSetText _strTitle;
		};

		// Update the body if the text changed
		if (GVAR(ui_sys_drawTutorialHints_prevBody) != _strBody) then {
			private _ctrlBody = _UI displayCtrl MACRO_IDC_TH_BODY_TEXT;
			_ctrlBody ctrlSetStructuredText parseText _strBody;

			// Also recompute the total height
			GVAR(ui_sys_drawTutorialHints_height) = (
				(ctrlTextHeight _ctrlBody)
				+ (ctrlPosition _ctrlBody) # 1
				+ pixelH * MACRO_POS_SPACER_Y
			);
			GVAR(ui_sys_drawTutorialHints_prevBody) = _strBody;
		};

		// Perform a fade-in animation
		private _ctrlGrp   = _UI displayCtrl MACRO_IDC_TH_CTRLGRP;
		private _animPhase = MACRO_TWEEN_CUBIC_OUT(GVAR(gm_sys_tutorialHints_startTime), _time, MACRO_UI_TUTORIALHINTS_ANIMDURATION);

		_ctrlGrp ctrlSetPositionH (_animPhase * GVAR(ui_sys_drawTutorialHints_height));
		_ctrlGrp ctrlCommit 0;

		// Scale the progress fill bar
		private _duration    = GVAR(gm_sys_tutorialHints_expiration) - GVAR(gm_sys_tutorialHints_startTime) max 0.1;
		private _fill        = (_time - GVAR(gm_sys_tutorialHints_startTime)) / _duration;
		private _ctrlFillBar = _UI displayCtrl MACRO_IDC_TH_PROGRESS_BAR;
		_ctrlFillBar ctrlSetPositionW (_fill * MACRO_POS_TH_WIDTH);
		_ctrlFillBar ctrlCommit 0;

	// Fade out the UI if no hint is active
	} else {

		if (!isNull _UI) then {
			private _fade = 1 - (_time - GVAR(gm_sys_tutorialHints_expiration)) / MACRO_UI_TUTORIALHINTS_ENTRYFADEDURATION;

			if (_fade > 0) then {
				private _ctrlBackground     = _UI displayCtrl MACRO_IDC_TH_BACKGROUND;
				private _ctrlFillBar        = _UI displayCtrl MACRO_IDC_TH_PROGRESS_BAR;
				private _ctrlIconPicture    = _UI displayCtrl MACRO_IDC_TH_ICON_PICTURE;
				private _ctrlTitle          = _UI displayCtrl MACRO_IDC_TH_TITLE_TEXT;
				private _ctrlTitleSeparator = _UI displayCtrl MACRO_IDC_TH_TITLE_SEPARATOR;
				private _ctrlBody           = _UI displayCtrl MACRO_IDC_TH_BODY_TEXT;
				private ["_col", "_alpha"];

				MACRO_FNC_FADECTRL_FILL(_ctrlBackground, _col, _alpha, _fade);
				MACRO_FNC_FADECTRL_FILL(_ctrlFillBar, _col, _alpha, _fade);
				MACRO_FNC_FADECTRL_FILL(_ctrlTitleSeparator, _col, _alpha, _fade);

				MACRO_FNC_FADECTRL_TEXT(_ctrlIconPicture, _col, _alpha, _fade);
				MACRO_FNC_FADECTRL_TEXT(_ctrlTitle, _col, _alpha, _fade);
				MACRO_FNC_FADECTRL_TEXT(_ctrlBody, _col, _alpha, _fade);

			} else {
				QGVAR(RscTutorialHints) cutRsc ["Default", "PLAIN"];
			};
		};
	};
}];
