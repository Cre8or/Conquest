/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[S][GA][GE]
		Adds score to the unit using the given enumeration (as justification).
		If the concerned unit is a player (instead of an AI), an event is broadcast to their machine for UI
		displaying.

		Only executed by the server.
	Arguments:
		0:	<OBJECT>	The unit to add score to
		1:	<NUMBER>	The score enumeration (acts as justification)
		2:	<ANY>		Any additional score arguments (optional, default: nil)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_unit", objNull, [objNull]],
	["_enum", MACRO_ENUM_SCORE_INVALID, [MACRO_ENUM_SCORE_INVALID]],
	"_arg"
];

// If no unit or score enum was passed, or if the function is not running on the server, exit
if (_enum == MACRO_ENUM_SCORE_INVALID or {!isServer}) exitWith {};





// Determine the score to be added/removed
private _score = switch (_enum) do {

	case MACRO_ENUM_SCORE_SECTOR_NEUTRALISED:      {MACRO_SCORE_SECTOR_NEUTRALISED};
	case MACRO_ENUM_SCORE_SECTOR_CAPTURING:        {MACRO_SCORE_SECTOR_CAPTURING};
	case MACRO_ENUM_SCORE_SECTOR_CAPTURED:         {MACRO_SCORE_SECTOR_CAPTURED};

	case MACRO_ENUM_SCORE_RESUPPLY: {
		private _deltaAmmo = [0, _arg] select (_arg isEqualType 0);

		round (100 * _deltaAmmo * MACRO_SCORE_RESUPPLY);
	};

	case MACRO_ENUM_SCORE_HEAL: {
		private _deltaHealth = [0, _arg] select (_arg isEqualType 0);

		round (100 * _deltaHealth * MACRO_SCORE_HEAL);
	};
	case MACRO_ENUM_SCORE_REVIVE:                  {MACRO_SCORE_REVIVE};

	case MACRO_ENUM_SCORE_DESERTING;
	case MACRO_ENUM_SCORE_SUICIDE:                 {MACRO_SCORE_SUICIDE};

	case MACRO_ENUM_SCORE_SPOTASSIST:              {MACRO_SCORE_SPOTASSIST};
	case MACRO_ENUM_SCORE_KILLASSIST: {
		private _damage = [0, _arg] select (_arg isEqualType 0);

		ceil (_damage * MACRO_SCORE_KILL_ENEMY);
	};
	case MACRO_ENUM_SCORE_KILL_ENEMY:              {MACRO_SCORE_KILL_ENEMY};
	case MACRO_ENUM_SCORE_KILL_FRIENDLY:           {MACRO_SCORE_KILL_FRIENDLY};
	case MACRO_ENUM_SCORE_HEADSHOT:                {MACRO_SCORE_HEADSHOT};

	case MACRO_ENUM_SCORE_DESTROYVEHICLE_ENEMY:    {MACRO_SCORE_DESTROYVEHICLE_ENEMY};
	case MACRO_ENUM_SCORE_DESTROYVEHICLE_FRIENDLY: {MACRO_SCORE_DESTROYVEHICLE_FRIENDLY};

	case MACRO_ENUM_SCORE_SIDEDEFEATED:            {MACRO_SCORE_SIDEDEFEATED};

	default {0};	// Fallback
};

// Ensure the score is valid
if (_score == 0) exitWith {};





// Add the score to the server statistics
private _UID        = [_unit] call FUNC(unit_getUID);
private _data       = GVAR(sv_stats) getOrDefault [_UID, []];
private _totalScore = (_data param [MACRO_INDEX_SERVERSTAT_SCORE, 0]) + _score;
_data set [MACRO_INDEX_SERVERSTAT_SCORE, _totalScore];

// Also keep track of kills and revives
switch (_enum) do {
	case MACRO_ENUM_SCORE_KILL_ENEMY: {
		private _kills = _data param [MACRO_INDEX_SERVERSTAT_KILLS, 0];
		_data set [MACRO_INDEX_SERVERSTAT_KILLS, _kills + 1];
	};
	case MACRO_ENUM_SCORE_REVIVE: {
		private _revives = _data param [MACRO_INDEX_SERVERSTAT_REVIVES, 0];
		_data set [MACRO_INDEX_SERVERSTAT_REVIVES, _revives + 1];
	};
};

GVAR(sv_stats) set [_UID, _data];





// Determine the additional arguments
private _argOut = switch (_enum) do {

	case MACRO_ENUM_SCORE_RESUPPLY;
	case MACRO_ENUM_SCORE_HEAL;
	case MACRO_ENUM_SCORE_KILLASSIST: {_score};

	case MACRO_ENUM_SCORE_REVIVE;
	case MACRO_ENUM_SCORE_KILL_ENEMY;
	case MACRO_ENUM_SCORE_KILL_FRIENDLY: {
		[nil, _arg] select (_arg isEqualType objNull);
	};

	case MACRO_ENUM_SCORE_SIDEDEFEATED: {
		[nil, _arg] select (_arg isEqualType sideEmpty);
	};

	default {nil};	// Fallback
};





// If the unit is a player, send them a score event
if (isPlayer _unit) then {
	[_enum, _argOut] remoteExecCall [QFUNC(ui_processScoreEvent), _unit, false];
};
