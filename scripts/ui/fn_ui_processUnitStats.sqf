/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA][LE]
		Processes statistics for the given unit UID, and adds it to the clientside data for use in the scoreboard.
	Arguments:
		0:	<OBJECT>	The unit which should receive damage
		1:	<NUMBER>	The unit's total score
		2:	<NUMBER>	The unit's total kills
		3:	<NUMBER>	The unit's total deaths
		4:	<NUMBER>	The unit's total revives
		5:	<NUMBER>	The unit's ping (optional, default: 0)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

params [
	["_UID", "", [""]],
	["_score", 0, [0]],
	["_kills", 0, [0]],
	["_deaths", 0, [0]],
	["_revives", 0, [0]],
	["_ping", -1, [-1]]
];

if (_UID == "" or {!hasInterface}) exitWith {};





// Set up some variables
MACRO_FNC_INITVAR(GVAR(ui_sys_drawScoreBoard_cache), createHashMap);

private _data = [];





// Transcribe the received data into the clientside stats
_data set [MACRO_INDEX_SERVERSTAT_SCORE,   _score];
_data set [MACRO_INDEX_SERVERSTAT_KILLS,   _kills];
_data set [MACRO_INDEX_SERVERSTAT_DEATHS,  _deaths];
_data set [MACRO_INDEX_SERVERSTAT_REVIVES, _revives];

if (_ping >= 0) then {
	_data set [MACRO_INDEX_SERVERSTAT_PING, _ping];
};

GVAR(ui_sys_drawScoreBoard_cache) set [_UID, _data];
