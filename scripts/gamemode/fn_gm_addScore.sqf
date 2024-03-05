/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Adds score to the unit using the given enumeration (as justification).
		If the object is a player, an event is broadcast to their machine for UI displaying.

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

	case MACRO_ENUM_SCORE_SECTOR_NEUTRALISED:	{MACRO_SCORE_SECTOR_NEUTRALISED};
	case MACRO_ENUM_SCORE_SECTOR_CAPTURING:		{MACRO_SCORE_SECTOR_CAPTURING};
	case MACRO_ENUM_SCORE_SECTOR_CAPTURED:		{MACRO_SCORE_SECTOR_CAPTURED};

	case MACRO_ENUM_SCORE_SUICIDE:			{MACRO_SCORE_SUICIDE};
	case MACRO_ENUM_SCORE_SPOTASSIST:		{MACRO_SCORE_SPOTASSIST};
	case MACRO_ENUM_SCORE_KILLASSIST:		{if (_arg isEqualType 0) then {_arg} else {0}};
	case MACRO_ENUM_SCORE_KILL_ENEMY:		{MACRO_SCORE_KILL_ENEMY};
	case MACRO_ENUM_SCORE_KILL_FRIENDLY:		{MACRO_SCORE_KILL_FRIENDLY};
	case MACRO_ENUM_SCORE_HEADSHOT:			{MACRO_SCORE_HEADSHOT};

	case MACRO_ENUM_SCORE_DESTROYVEHICLE_ENEMY:	{MACRO_SCORE_DESTROYVEHICLE_ENEMY};
	case MACRO_ENUM_SCORE_DESTROYVEHICLE_FRIENDLY:	{MACRO_SCORE_DESTROYVEHICLE_FRIENDLY};

	case MACRO_ENUM_SCORE_SIDEDEFEATED:		{MACRO_SCORE_SIDEDEFEATED};

	default {0};	// Fallback
};

// Ensure the score is valid
if (_score == 0) exitWith {};





// Determine the additional arguments
private _argOut = switch (_enum) do {

	case MACRO_ENUM_SCORE_KILLASSIST: {_score};

	case MACRO_ENUM_SCORE_KILL_ENEMY;
	case MACRO_ENUM_SCORE_KILL_FRIENDLY: {
		[nil, _arg] select (_arg isEqualType objNull);
	};

	case MACRO_ENUM_SCORE_SIDEDEFEATED: {_arg};

	default {nil};	// Fallback
};





// If the unit is a player, send them a score event
if (isPlayer _unit) then {
	[_enum, _argOut] remoteExecCall [QFUNC(ui_processScoreEvent), _unit, false];
};
