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

#include "..\..\res\macros\fnc_fadeCtrls.inc"
#include "..\..\res\macros\fnc_initVar.inc"
#include "..\..\res\macros\fnc_tweens.inc"

if (!hasInterface) exitWith {};





// Set up some variables
MACRO_FNC_INITVAR(GVAR(ui_sys_drawScoreFeed_EH), -1);

GVAR(ui_sys_drawScoreFeed_data)       = [];    // Interfaces with ui_processScoreEvent
GVAR(ui_sys_drawScoreFeed_redrawLast) = false; // Interfaces with ui_processScoreEvent
GVAR(ui_sys_drawScoreFeed_ctrls)      = [];





// Open the UI
QGVAR(RscScoreFeed) cutRsc [QGVAR(RscScoreFeed), "PLAIN"];





removeMissionEventHandler ["EachFrame", GVAR(ui_sys_drawScoreFeed_EH)];
GVAR(ui_sys_drawScoreFeed_EH) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	private _time          = time;
	private _UI            = uiNamespace getVariable [QGVAR(RscScoreFeed), displayNull];
	private _indexLastData = count GVAR(ui_sys_drawScoreFeed_data) - 1;
	private _indexLastCtrl = count GVAR(ui_sys_drawScoreFeed_ctrls) - 1;
	private _ctrlGrpMain   = _UI displayCtrl MACRO_IDC_SF_CTRLGRP;
	private _animStartTime = _UI getVariable [QGVAR(animStartTime), 0];
	private _animOffset    = _UI getVariable [QGVAR(animOffset), 0];
	private _animPhase     = 1 - MACRO_TWEEN_CUBIC_OUT(_animStartTime, _time, MACRO_UI_SCOREFEED_ANIMDURATION);
	private _scoreSum      = _UI getVariable [QGVAR(scoreSum), 0];
	private _ctrlsSum      = _UI getVariable [QGVAR(ctrlsSum), []];
	private _updateSum     = false;

	// Special case: redrawing is requested
	if (GVAR(ui_sys_drawScoreFeed_redrawLast)) then {
		{
			ctrlDelete _x;
		} forEach (GVAR(ui_sys_drawScoreFeed_ctrls) deleteAt _indexLastCtrl);
		_indexLastCtrl = _indexLastCtrl - 1;
	};

	private ["_ctrls", "_indexRev", "_messageWidth", "_argWidth", "_scoreWidth", "_fade", "_col", "_alpha"];

	// Process the score feed entries
	for "_index" from _indexLastData to 0 step -1 do {

		(GVAR(ui_sys_drawScoreFeed_data) # _index) params ["_endTime", "", "_score", "_messageText", ["_messageArg", ""], ["_messageArgColour", SQUARE(MACRO_COLOUR_A100_WHITE)], ["_scoreDisplayed", 0]];
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

				// Reset the animation
				if (!GVAR(ui_sys_drawScoreFeed_redrawLast)) then {
					_animStartTime = _time;
					_animOffset    = _animOffset * _animPhase + MACRO_POS_SF_ENTRY_TEXTSIZE;
					_animPhase     = 1;
				};

				// Displayed score can differ from the entry's score in cases where the score event can stack.
				// We still need to differentiate between the "stacked" score and the event's base score, as the
				// latter may get added to the running sum.
				if (_scoreDisplayed == 0) then {
					_scoreDisplayed = _score;
				};

				_UI setVariable [QGVAR(animStartTime), _animStartTime];
				_UI setVariable [QGVAR(animOffset),  _animOffset];

				_messageWidth = ("w" + _messageText) getTextWidth [MACRO_FONT_UI_MEDIUM, MACRO_POS_SF_ENTRY_TEXTSIZE];
				_argWidth     = ("w" + _messageArg) getTextWidth [MACRO_FONT_UI_MEDIUM, MACRO_POS_SF_ENTRY_TEXTSIZE];
				_scoreWidth   = ("w" + str _scoreDisplayed) getTextWidth [MACRO_FONT_UI_MEDIUM, MACRO_POS_SF_ENTRY_TEXTSIZE];

				_ctrlGrp = _UI ctrlCreate ["RscControlsGroupNoScrollbars", -1, _ctrlGrpMain];

				// Main background
				_ctrlBackground = _UI ctrlCreate [QGVAR(RscFrame), -1, _ctrlGrp];
				_ctrlBackground ctrlSetPosition [
					MACRO_POS_SF_X_OFFSET - _messageWidth - _argWidth,
					0,
					_messageWidth + _argWidth + MACRO_POS_SF_SCORE_WIDTH,
					MACRO_POS_SF_ENTRY_HEIGHT
				];
				_ctrlBackground ctrlCommit 0;
				_ctrlBackground ctrlSetPixelPrecision 2;

				// Score background (only for penalties)
				if (_scoreDisplayed < 0) then {
					_ctrlBackgroundScore = _UI ctrlCreate [QGVAR(RscFrame), -1, _ctrlGrp];
					_ctrlBackgroundScore ctrlSetPosition [
						MACRO_POS_SF_X_OFFSET + MACRO_POS_SF_SCORE_WIDTH - _scoreWidth,
						0,
						_scoreWidth,
						MACRO_POS_SF_ENTRY_TEXTSIZE
					];
					_ctrlBackgroundScore ctrlCommit 0;
					_ctrlBackgroundScore ctrlSetBackgroundColor SQUARE(MACRO_COLOUR_A100_RED);
					_ctrlBackgroundScore ctrlSetPixelPrecision 2;
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
					_ctrlMessageArg ctrlSetTextColor _messageArgColour;
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
				_ctrlScore ctrlSetText str ceil _scoreDisplayed;

				_ctrls = [_ctrlGrp, _ctrlBackground, _ctrlBackgroundScore, _ctrlMessage, _ctrlMessageArg, _ctrlScore];
				GVAR(ui_sys_drawScoreFeed_ctrls) set [_index, _ctrls];
				GVAR(ui_sys_drawScoreFeed_redrawLast) = false;

				// Prepare the score sum data.
				// The sum is only shown when more than one score entry is present, or if the sum
				// is still visible from a previous chain of score entries.
				if (_indexLastData >= 1 or {_ctrlsSum isNotEqualTo []}) then {

					if (_ctrlsSum isEqualTo []) then {
						{
							_scoreSum = _scoreSum + (_x # 2);
						} forEach GVAR(ui_sys_drawScoreFeed_data);

						_UI setVariable [QGVAR(scoreSumStartTime), _time];
					} else {
						_scoreSum = _scoreSum + _score;
					};

					_updateSum = true;
					_UI setVariable [QGVAR(scoreSum), _scoreSum];
					_UI setVariable [QGVAR(scoreSumEndTime), _time + MACRO_UI_SCOREFEED_SCORESUMLIFETIME];
				};
			};

			// Position the entry
			_indexRev = _indexLastData - _index;
			_ctrlGrp ctrlSetPosition [0, _indexRev * MACRO_POS_SF_ENTRY_TEXTSIZE - _animOffset * _animPhase];
			_ctrlGrp ctrlCommit 0;

			// Fade the controls out
			_fade = ((_endTime - _time) min MACRO_UI_SCOREFEED_ENTRYFADEDURATION) / MACRO_UI_SCOREFEED_ENTRYFADEDURATION;

			MACRO_FNC_FADECTRL_FILL(_ctrlBackground, _col, _alpha, _fade);
			MACRO_FNC_FADECTRL_FILL(_ctrlBackgroundScore, _col, _alpha, _fade);

			MACRO_FNC_FADECTRL_TEXT(_ctrlMessage, _col, _alpha, _fade);
			MACRO_FNC_FADECTRL_TEXT(_ctrlMessageArg, _col, _alpha, _fade);
			MACRO_FNC_FADECTRL_TEXT(_ctrlScore, _col, _alpha, _fade);
		};
	};



	// Process the score sum entry
	private _startTime = _UI getVariable [QGVAR(scoreSumStartTime), 0];
	private _endTime   = _UI getVariable [QGVAR(scoreSumEndTime), 0];
	if (_time < _endTime) then {
		_ctrlsSum params [["_ctrlGrp", controlNull], "_ctrlBackground", "_ctrlScore"];

		// Create the score sum controls
		if (isNull _ctrlGrp) then {
			_ctrlGrp = _UI ctrlCreate ["RscControlsGroupNoScrollbars", -1, _ctrlGrpMain];

			// Main background
			_ctrlBackground = _UI ctrlCreate [QGVAR(RscFrame), -1, _ctrlGrp];
			_ctrlBackground ctrlSetPosition [
				0,
				0,
				1,
				MACRO_POS_SF_ENTRY_HEIGHT
			];
			_ctrlBackground ctrlCommit 0;
			_ctrlBackground ctrlSetPixelPrecision 2;

			// Score sum
			_ctrlScore = _UI ctrlCreate [QGVAR(RscScoreFeed_Text_Left), -1, _ctrlGrp];
			_ctrlScore ctrlSetPosition [
				0,
				0,
				1,
				MACRO_POS_SF_ENTRY_TEXTSIZE
			];
			_ctrlScore ctrlCommit 0;

			_ctrlsSum = [_ctrlGrp, _ctrlBackground, _ctrlScore];
			_UI setVariable [QGVAR(ctrlsSum), _ctrlsSum];
		};

		private _scoreSumText  = " " + str ceil _scoreSum;
		private _scoreSumWidth = ("w" + _scoreSumText) getTextWidth [MACRO_FONT_UI_MEDIUM, MACRO_POS_SF_ENTRY_TEXTSIZE];
		private _scoreSumPhase = (((_time - _startTime) / MACRO_UI_SCOREFEED_ANIMDURATION - 1) min 0) ^ 3;

		_ctrlGrp ctrlSetPosition [
			MACRO_POS_SF_X_OFFSET + MACRO_POS_SF_SCORE_WIDTH,
			MACRO_POS_SF_ENTRY_HEIGHT * _scoreSumPhase,
			_scoreSumWidth,
			MACRO_POS_SF_ENTRY_HEIGHT
		];
		_ctrlGrp ctrlCommit 0;

		// Update the score sum text and background
		if (_updateSum) then {
			_ctrlBackground ctrlSetBackgroundColor ([
				SQUARE(MACRO_COLOUR_A100_RED),
				SQUARE(MACRO_COLOUR_INGAME_BACKGROUND
			)] select (_scoreSum >= 0));

			_ctrlScore ctrlSetText _scoreSumText;
		};

		// Fade the controls out
		_fade = ((_endTime - _time) min MACRO_UI_SCOREFEED_ENTRYFADEDURATION) / MACRO_UI_SCOREFEED_ENTRYFADEDURATION;
		MACRO_FNC_FADECTRL_FILL(_ctrlBackground, _col, _alpha, _fade);
		MACRO_FNC_FADECTRL_TEXT(_ctrlScore, _col, _alpha, _fade);

	} else {

		// Delete the score sum controls
		if (_ctrlsSum isNotEqualTo []) then {
			{
				ctrlDelete _x;
			} forEach _ctrlsSum;

			_UI setVariable [QGVAR(ctrlsSum), []];
			_UI setVariable [QGVAR(scoreSum), 0];
		};
	};
}];
