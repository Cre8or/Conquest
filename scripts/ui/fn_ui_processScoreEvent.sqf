/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LE]
		Processes a score event by appending the corresponding data to the score feed UI handler. For a list of
		score enumerations, refer to macros.inc.

		Only executed by the client, via server remoteExecCall.
	Arguments:
		0:	<NUMBER>	The score enumeration to be processed
		1:	<ANY>		Any additional score arguments (optional, default: nil)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"

#include "..\..\res\macros\fnc_initVar.inc"

params [
	["_enum", MACRO_ENUM_SCORE_INVALID, [MACRO_ENUM_SCORE_INVALID]],
	"_arg"
];

if (!hasInterface or {_enum == MACRO_ENUM_SCORE_INVALID}) exitWith {};





// Set up some variables
MACRO_FNC_INITVAR(GVAR(ui_sys_drawScoreFeed_data), []);
MACRO_FNC_INITVAR(GVAR(ui_sys_drawScoreFeed_redrawLast), false);
MACRO_FNC_INITVAR(GVAR(ui_processScoreEvent_sound), -1);

private _soundData = [];





// Determine the corresponding data to be displayed in the score feed
private _eventData = [];
private _canStack = false;

switch (_enum) do {

	case MACRO_ENUM_SCORE_SECTOR_NEUTRALISED: {
		_eventData = [
			MACRO_SCORE_SECTOR_NEUTRALISED,
			"SECTOR NEUTRALISED"
		];
	};

	case MACRO_ENUM_SCORE_SECTOR_CAPTURING: {
		_eventData = [
			MACRO_SCORE_SECTOR_CAPTURING,
			"CAPTURING"
		];
		_canStack = true;
	};

	case MACRO_ENUM_SCORE_SECTOR_CAPTURED: {
		_eventData = [
			MACRO_SCORE_SECTOR_CAPTURED,
			"SECTOR CAPTURED"
		];
	};

	// --------

	case MACRO_ENUM_SCORE_RESUPPLY: {
		if (_arg isEqualType 0 and {_arg > 0}) then {
			_eventData = [
				_arg,
				"RESUPPLYING"
			];
		};
		_canStack = true;
	};

	// --------

	case MACRO_ENUM_SCORE_HEAL: {
		if (_arg isEqualType 0 and {_arg > 0}) then {
			_eventData = [
				_arg,
				"HEALING"
			];
		};
		_canStack = true;
	};

	case MACRO_ENUM_SCORE_REVIVE: {
		if (_arg isEqualType objNull and {_arg isKindOf "Man"}) then {
			_eventData = [
				MACRO_SCORE_REVIVE,
				"REVIVED",
				name _arg,
				[
					SQUARE(MACRO_COLOUR_A100_FRIENDLY),
					SQUARE(MACRO_COLOUR_A100_SQUAD)
				] select (_arg in units group player)
			];
		};
	};

	// --------

	case MACRO_ENUM_SCORE_SUICIDE: {
		_eventData = [
			MACRO_SCORE_SUICIDE,
			"SUICIDE"
		];
	};

	case MACRO_ENUM_SCORE_DESERTING: {
		_eventData = [
			MACRO_SCORE_SUICIDE,
			"DESERTED"
		];
	};

	// --------

	case MACRO_ENUM_SCORE_SPOTASSIST: {
		_eventData = [
			MACRO_SCORE_SPOTASSIST,
			"SPOT ASSIST"
		];
	};

	case MACRO_ENUM_SCORE_KILLASSIST: {
		if (_arg isEqualType 0) then {
			_eventData = [
				_arg,
				"KILL ASSIST"
			];
		};
	};

	// --------

	case MACRO_ENUM_SCORE_KILL_ENEMY: {
		if (_arg isEqualType objNull and {_arg isKindOf "Man"}) then {
			_eventData = [
				MACRO_SCORE_KILL_ENEMY,
				"KILLED",
				name _arg,
				SQUARE(MACRO_COLOUR_A100_ENEMY)
			];
			_soundData = [QGVAR(EnemyKilled), 4, 1];
		};
	};

	case MACRO_ENUM_SCORE_KILL_FRIENDLY: {
		if (_arg isEqualType objNull and {_arg isKindOf "Man"}) then {
			_eventData = [
				MACRO_SCORE_KILL_FRIENDLY,
				"FRIENDLY-FIRED",
				name _arg,
				[
					SQUARE(MACRO_COLOUR_A100_FRIENDLY),
					SQUARE(MACRO_COLOUR_A100_SQUAD)
				] select (_arg in units group player)
			];
			_soundData = [QGVAR(FriendlyKilled), 3, 1];
		};
	};

	case MACRO_ENUM_SCORE_HEADSHOT: {
		_eventData = [
			MACRO_SCORE_HEADSHOT,
			"HEADSHOT BONUS"
		];
		_soundData = [QGVAR(Headshot), 5, 1];
	};

	// --------

	case MACRO_ENUM_SCORE_DESTROYVEHICLE_ENEMY: {
		_eventData = [
			MACRO_SCORE_DESTROYVEHICLE_ENEMY,
			"VEHICLE DESTROYED"
		];
		_soundData = [QGVAR(EnemyKilled), 4, 1];
	};

	case MACRO_ENUM_SCORE_DESTROYVEHICLE_FRIENDLY: {
		_eventData = [
			MACRO_SCORE_DESTROYVEHICLE_FRIENDLY,
			"FRIENDLY VEHICLE DESTROYED"
		];
		_soundData = [QGVAR(FriendlyKilled), 3, 1];
	};

	// --------

	case MACRO_ENUM_SCORE_SIDEDEFEATED: {
		if (_arg isEqualType sideEmpty and {_arg != sideEmpty}) then {
			_eventData = [
				MACRO_SCORE_SIDEDEFEATED,
				"DEFEATED",
				[_arg] call FUNC(gm_getSideName),
				SQUARE(MACRO_COLOUR_A100_ENEMY)
			];
		};
		_soundData = [QGVAR(SideDefeated), 4, 1];
	};
};





// Append the event data to the score feed
if (_eventData isNotEqualTo []) then {

	if (_canStack and {GVAR(ui_sys_drawScoreFeed_data) isNotEqualTo []}) then {
		private _indexLast = count GVAR(ui_sys_drawScoreFeed_data) - 1;
		private _lastEventData = GVAR(ui_sys_drawScoreFeed_data) # _indexLast;

		// Ensure the previous event has the same score enum
		if (_lastEventData # 1 == _enum) then {
			GVAR(ui_sys_drawScoreFeed_redrawLast) = true;
			GVAR(ui_sys_drawScoreFeed_data) deleteAt _indexLast;

			// Try fetching the displayed score first, and fall back to the event's score if necessary
			private _prevScoreDisplayed = _lastEventData param [6, _lastEventData param [2, 0]];

			// Stack the score, while preserving the entry's original score
			_eventData set [4, _prevScoreDisplayed + _eventData # 0];
		};
	};

	GVAR(ui_sys_drawScoreFeed_data) pushBack (
		[time + MACRO_UI_SCOREFEED_ENTRYLIFETIME, _enum] + _eventData
	);

	// Play a sound
	if (_soundData isNotEqualTo []) then {
		stopSound GVAR(ui_processScoreEvent_sound);
		GVAR(ui_processScoreEvent_sound) = playSoundUI (_soundData + [true]);
	};
};
