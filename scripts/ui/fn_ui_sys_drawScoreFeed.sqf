/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles the drawing of the score feed. Data is added to the score feed by calling gm_processScoreEvent.

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
MACRO_FNC_INITVAR(GVAR(ui_sys_drawScoreFeed_EH), -1);

GVAR(ui_sys_drawScoreFeed_data)       = [];
GVAR(ui_sys_drawScoreFeed_redrawLast) = false;
GVAR(ui_sys_drawScoreFeed_ctrls)      = [];

// Open the UI
QGVAR(RscScoreFeed) cutRsc [QGVAR(RscScoreFeed), "PLAIN"];





removeMissionEventHandler ["EachFrame", GVAR(ui_sys_drawScoreFeed_EH)];
GVAR(ui_sys_drawScoreFeed_EH) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	private _time = time;
	private _indexLastData = count GVAR(ui_sys_drawScoreFeed_data) - 1;
	private _indexLastCtrl = count GVAR(ui_sys_drawScoreFeed_ctrls) - 1;

	private _UI = uiNamespace getVariable [QGVAR(RscScoreFeed), displayNull];
	private _ctrlGrpMain = _UI displayCtrl MACRO_IDC_SF_CTRLGRP;
	private _animEndTime = _UI getVariable [QGVAR(animEndTime), 0];
	private _animOffset  = _UI getVariable [QGVAR(animOffset), 0];
	private _animPhase   = (((_animEndTime - _time) / MACRO_UI_SCOREFEED_ANIMDURATION) max 0) ^ 3;

	// Special case: redrawing is requested
	if (GVAR(ui_sys_drawScoreFeed_redrawLast)) then {
		{
			ctrlDelete _x;
		} forEach (GVAR(ui_sys_drawScoreFeed_ctrls) deleteAt _indexLastCtrl);
		_indexLastCtrl = _indexLastCtrl - 1;
	};

	private ["_ctrls", "_indexRev", "_messageWidth", "_argWidth", "_scoreWidth", "_fade", "_col"];

	// Draw the score feed
	for "_index" from _indexLastData to 0 step -1 do {

		(GVAR(ui_sys_drawScoreFeed_data) # _index) params ["_endTime", "", "_score", "_messageText", ["_messageArg", ""], ["_messageArgColour", SQUARE(MACRO_COLOUR_A100_WHITE)]];
		_ctrls = GVAR(ui_sys_drawScoreFeed_ctrls) param [_index, []];
		_ctrls params ["_ctrlGrp", "_ctrlBackground", "_ctrlBackgroundScore", "_ctrlMessage", "_ctrlMessageArg", "_ctrlScore"];

		if (_endTime < _time) then {
			GVAR(ui_sys_drawScoreFeed_data) deleteAt _index;
			{
				ctrlDelete _x;
			} forEach (GVAR(ui_sys_drawScoreFeed_ctrls) deleteAt _index);

		} else {

			// Create new controls for this entry
			if (_index > _indexLastCtrl) then {
				_ctrlGrp = _UI ctrlCreate ["RscControlsGroupNoScrollbars", -1, _ctrlGrpMain];

				// Reset the animation
				if (!GVAR(ui_sys_drawScoreFeed_redrawLast)) then {
					_animEndTime = _time + MACRO_UI_SCOREFEED_ANIMDURATION;
					_animOffset  = _animOffset * _animPhase + MACRO_POS_SF_ENTRY_TEXTSIZE;
					_animPhase   = 1;
				};

				_UI setVariable [QGVAR(animEndTime), _animEndTime];
				_UI setVariable [QGVAR(animOffset),  _animOffset];

				_messageWidth = ("w" + _messageText) getTextWidth [MACRO_FONT_UI_MEDIUM, MACRO_POS_SF_ENTRY_TEXTSIZE];
				_argWidth     = ("w" + _messageArg) getTextWidth [MACRO_FONT_UI_MEDIUM, MACRO_POS_SF_ENTRY_TEXTSIZE];
				_scoreWidth   = ("w" + str _score) getTextWidth [MACRO_FONT_UI_MEDIUM, MACRO_POS_SF_ENTRY_TEXTSIZE];

				// Main background
				_ctrlBackground = _UI ctrlCreate [QGVAR(RscFrame), -1, _ctrlGrp];
				_ctrlBackground ctrlSetPosition [
					MACRO_POS_SF_X_OFFSET - _messageWidth - _argWidth,
					0,
					_messageWidth + _argWidth + MACRO_POS_SF_SCORE_WIDTH,
					MACRO_POS_SF_ENTRY_HEIGHT
				];
				_ctrlBackground ctrlCommit 0;
				_ctrlBackground setVariable [QGVAR(fillColour), SQUARE(MACRO_COLOUR_INGAME_BACKGROUND)];
				_ctrlBackground ctrlSetPixelPrecision 2;

				// Score background (only for penalties)
				if (_score < 0) then {
					_ctrlBackgroundScore = _UI ctrlCreate [QGVAR(RscFrame), -1, _ctrlGrp];
					_ctrlBackgroundScore ctrlSetPosition [
						MACRO_POS_SF_X_OFFSET + MACRO_POS_SF_SCORE_WIDTH - _scoreWidth,
						0,
						_scoreWidth,
						MACRO_POS_SF_ENTRY_TEXTSIZE
					];
					_ctrlBackgroundScore ctrlCommit 0;
					_ctrlBackgroundScore setVariable [QGVAR(fillColour), SQUARE(MACRO_COLOUR_A100_RED)];
				} else {
					_ctrlBackgroundScore = controlNull;
				};

				// Message argument
				if (_messageArg != "") then {
					_ctrlMessageArg = _UI ctrlCreate [QGVAR(RscScoreFeed_Text), -1, _ctrlGrp];
					_ctrlMessageArg ctrlSetPosition [
						MACRO_POS_SF_X_OFFSET - _argWidth,
						0,
						_argWidth,
						MACRO_POS_SF_ENTRY_TEXTSIZE
					];
					_ctrlMessageArg ctrlCommit 0;
					_ctrlMessageArg ctrlSetText _messageArg;
					_ctrlMessageArg setVariable [QGVAR(textColour), _messageArgColour];
				} else {
					_ctrlMessageArg = controlNull;
				};

				// Message
				_ctrlMessage = _UI ctrlCreate [QGVAR(RscScoreFeed_Text), -1, _ctrlGrp];
				_ctrlMessage ctrlSetPosition [
					MACRO_POS_SF_X_OFFSET - _messageWidth - _argWidth,
					0,
					_messageWidth,
					MACRO_POS_SF_ENTRY_TEXTSIZE
				];
				_ctrlMessage ctrlCommit 0;
				_ctrlMessage ctrlSetText _messageText;

				// Score
				_ctrlScore = _UI ctrlCreate [QGVAR(RscScoreFeed_Text), -1, _ctrlGrp];
				_ctrlScore ctrlSetPosition [
					MACRO_POS_SF_X_OFFSET + MACRO_POS_SF_SCORE_WIDTH - _scoreWidth,
					0,
					_scoreWidth,
					MACRO_POS_SF_ENTRY_TEXTSIZE
				];
				_ctrlScore ctrlCommit 0;
				_ctrlScore ctrlSetText str ceil _score;

				_ctrls = [_ctrlGrp, _ctrlBackground, _ctrlBackgroundScore, _ctrlMessage, _ctrlMessageArg, _ctrlScore];
				GVAR(ui_sys_drawScoreFeed_ctrls) set [_index, _ctrls];
				GVAR(ui_sys_drawScoreFeed_redrawLast) = false;
			};

			// Animate the entry
			_indexRev = _indexLastData - _index;
			_ctrlGrp ctrlSetPosition [0, _indexRev * MACRO_POS_SF_ENTRY_TEXTSIZE - _animOffset * _animPhase];
			_ctrlGrp ctrlCommit 0;

			// Fade the solid controls
			_fade = ((_endTime - _time) min MACRO_UI_SCOREFEED_ENTRYFADEDURATION) / MACRO_UI_SCOREFEED_ENTRYFADEDURATION;
			{
				_col = +(_x getVariable [QGVAR(fillColour), [1,1,1,1]]);
				_col set [3, (_col # 3) * _fade];
				_x ctrlSetBackgroundColor _col;
			} forEach [
				_ctrlBackground,
				_ctrlBackgroundScore
			];

			// Fade the text controls
			{
				_col = +(_x getVariable [QGVAR(textColour), [1,1,1,1]]);
				_col set [3, (_col # 3) * _fade];
				_x ctrlSetTextColor _col;
			} forEach [
				_ctrlMessage,
				_ctrlMessageArg,
				_ctrlScore
			];
		};
	};
}];
