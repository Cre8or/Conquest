/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[S]
		Handles the storage and braodcasting of serverside mission statistics as needed for the scoreboard.

		Only executed once by the server upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

if (!isServer) exitWith {};





// Set up some variables
MACRO_FNC_INITVAR(GVAR(gm_sys_handleServerStats_EH), -1);

GVAR(gm_sys_handleServerStats_nextUpdate) = -1;
GVAR(gm_sys_handleServerStats_index)      = -1;
GVAR(gm_sys_handleServerStats_count)      = -1;
GVAR(gm_sys_handleServerStats_units)      = [];
GVAR(gm_sys_handleServerStats_cache)      = createHashMap;





removeMissionEventHandler ["EachFrame", GVAR(gm_sys_handleServerStats_EH)];
GVAR(gm_sys_handleServerStats_EH) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	private _time = time;



	private ["_UID", "_data", "_dataOld", "_score", "_kills", "_deaths", "_revives", "_ping", "_canUpdatePing", "_shouldBroadcast"];
	for "_unitIndex" from GVAR(gm_sys_handleServerStats_index) to 0 step -1 do {

		scopeName QGVAR(gm_sys_handleServerStats_loop);

		// Exit early if no more units may be handled this frame (balances the load over multiple frames)
		if (_unitIndex < ((GVAR(gm_sys_handleServerStats_nextUpdate) - _time) * GVAR(gm_sys_handleServerStats_count) / MACRO_GM_SYS_HANDLESERVERSTATS_INTERVAL)) then {
			breakOut QGVAR(gm_sys_handleServerStats_loop);
		};

		_UID     = GVAR(gm_sys_handleServerStats_units) param [_unitIndex, ""];
		_data    = GVAR(sv_stats) getOrDefault [_UID, []];
		_dataOld = GVAR(gm_sys_handleServerStats_cache) getOrDefault [_UID, []];

		_score   = _data param [MACRO_INDEX_SERVERSTAT_SCORE, 0];
		_kills   = _data param [MACRO_INDEX_SERVERSTAT_KILLS, 0];
		_deaths  = _data param [MACRO_INDEX_SERVERSTAT_DEATHS, 0];
		_revives = _data param [MACRO_INDEX_SERVERSTAT_REVIVES, 0];
		_ping    = _data param [MACRO_INDEX_SERVERSTAT_PING, 0];

		_canUpdatePing = (
			_ping != _dataOld param [MACRO_INDEX_SERVERSTAT_PING, 0]
			and {_time > _data param [MACRO_INDEX_SERVERSTAT_PING_NEXTUPDATE, -1]}
		);

		_shouldBroadcast = (
			_dataOld isEqualTo []
			or {_score != _dataOld param [MACRO_INDEX_SERVERSTAT_SCORE, 0]}
			or {_kills != _dataOld param [MACRO_INDEX_SERVERSTAT_KILLS, 0]}
			or {_deaths != _dataOld param [MACRO_INDEX_SERVERSTAT_DEATHS, 0]}
			or {_revives != _dataOld param [MACRO_INDEX_SERVERSTAT_REVIVES, 0]}
			or {_canUpdatePing}
		);

		if (_shouldBroadcast) then {
			[_UID, _score, _kills, _deaths, _revives, _ping] remoteExecCall [QFUNC(ui_processUnitStats), 0, format [QGVAR(gm_processUnitStats_%1), _UID]];
			//systemChat format ["(%1) Updating UID %2 (%3)", _time, _UID, _canUpdatePing];

			// Update the ping broadcast time
			_data set [MACRO_INDEX_SERVERSTAT_PING_NEXTUPDATE, _time + MACRO_GM_SYS_HANDLESERVERSTATS_PING_INTERVAL];

			// Update the cached data entry (for future change detection)
			GVAR(gm_sys_handleServerStats_cache) set [_UID, +_data];
		};

		GVAR(gm_sys_handleServerStats_index) = [-1, _unitIndex - 1] select (_unitIndex > 0);
	};



	// Restart the cycle for the next frame.
	// We do this by aggregating all units once, so we can process them over multiple frames, thus balancing the network traffic.
	if (_time > GVAR(gm_sys_handleServerStats_nextUpdate) and {GVAR(gm_sys_handleServerStats_index) < 0}) then {
		GVAR(gm_sys_handleServerStats_nextUpdate) = _time + MACRO_GM_SYS_HANDLESERVERSTATS_INTERVAL;

		private _players = allPlayers;

		// Start with the AI
		GVAR(gm_sys_handleServerStats_units) = (

			// Match the UID as defined in unit_getUID
			(GVAR(sv_AIIdentities) apply {"AI_" + str (_x # MACRO_INDEX_AIIDENTITY_UNITINDEX)})
		);

		// Add the players, and update the ping in their corresponding data cache while we're at it
		{
			// Match the UID as defined in unit_getUID
			_UID = getPlayerUID _x;
			GVAR(gm_sys_handleServerStats_units) pushBack _UID;

			_ping = ceil ((getUserInfo getPlayerID _x) param [9, []] param [0, 0]);
			_data = GVAR(sv_stats) getOrDefault [_UID, []];
			_data set [MACRO_INDEX_SERVERSTAT_PING, _ping];

			GVAR(sv_stats) set [_UID, _data];
		} forEach _players;

		GVAR(gm_sys_handleServerStats_count) = count GVAR(gm_sys_handleServerStats_units);
		GVAR(gm_sys_handleServerStats_index) = GVAR(gm_sys_handleServerStats_count) - 1;
	};




}];
