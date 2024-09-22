/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles the respawn ticket counts for each side, aswell as ticket bleed resulting from each side's ratio
		of captured sectors.
		A side is considered as playable if it fulfills these two conditions:
			- it still has tickets left, and
			- it owns at least one sector with spawn points, OR has at least one alive unit.

		Only executed once by the server upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"

#include "..\..\res\macros\fnc_initVar.inc"
#include "..\..\res\macros\fnc_broadcastOnChange.inc"





// Set up some variables
MACRO_FNC_INITVAR(GVAR(gm_sys_tickets_EH_eachFrame),-1);
MACRO_FNC_INITVAR(GVAR(gm_sys_tickets_EH_killed),-1);

GVAR(gm_sys_tickets_nextTime) = -1;
GVAR(gm_sys_tickets_canBeWarned) = GVAR(sides) apply {_x != sideEmpty};
GVAR(gm_sys_tickets_remainingWarnings) = ({_x} count GVAR(gm_sys_tickets_canBeWarned)) - 1;

GVAR(ticketsEast_last)       = -1;
GVAR(ticketsResistance_last) = -1;
GVAR(ticketsWest_last)       = -1;

GVAR(ticketBleedTimeEast)       = -1;
GVAR(ticketBleedTimeResistance) = -1;
GVAR(ticketBleedTimeWest)       = -1;

GVAR(ticketBleedEast)       = 0;
GVAR(ticketBleedResistance) = 0;
GVAR(ticketBleedWest)       = 0;

GVAR(ticketBleedEast_last)       = 0;
GVAR(ticketBleedResistance_last) = 0;
GVAR(ticketBleedWest_last)       = 0;





#define MACRO_FNC_PERFORMTICKETBLEED(THISSIDE) \
	if (GVAR(MERGE(tickets,THISSIDE)) > 0 and {MERGE(_sectorCount,THISSIDE) == 0 or {_maxRatio - MERGE(_sectorRatio,THISSIDE) > _c_sectorRatioThresholdInv}}) then { \
		GVAR(MERGE(ticketBleed,THISSIDE)) = 0.0001 max ([MACRO_TICKETBLEED_FAST, MACRO_TICKETBLEED_SLOW] select (MERGE(_sectorCount,THISSIDE) > 0)); \
 \
		if (GVAR(MERGE(ticketBleedTime,THISSIDE)) < 0) then { \
			GVAR(MERGE(ticketBleedTime,THISSIDE)) = _time; \
		} else { \
			private _interval = GVAR(MERGE(ticketBleed,THISSIDE)) / 60; \
			private _steps    = floor ((_time - GVAR(MERGE(ticketBleedTime,THISSIDE))) * _interval); \
 \
			if (_steps > 0) then { \
				GVAR(MERGE(tickets,THISSIDE))          = (GVAR(MERGE(tickets,THISSIDE)) - _steps) max 0; \
				GVAR(MERGE(ticketBleedTime,THISSIDE)) = GVAR(MERGE(ticketBleedTime,THISSIDE)) + _steps / _interval; \
				systemChat format ["(%1) Ticket bleed %2: %3", _time, THISSIDE, _steps]; \
			}; \
		}; \
	} else { \
		GVAR(MERGE(ticketBleed,THISSIDE))      = 0; \
		GVAR(MERGE(ticketBleedTime,THISSIDE)) = -1; \
	}; \





// Handle ticket bleed
removeMissionEventHandler ["EachFrame", GVAR(gm_sys_tickets_EH_eachFrame)];
GVAR(gm_sys_tickets_EH_eachFrame) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	private _time = time;
	if (GVAR(missionState) == MACRO_ENUM_MISSION_LIVE and {_time > GVAR(gm_sys_tickets_nextTime)}) then {

		// NOTE: The order *MUST* match that of GVAR(sides)!
		private ["_sideX", "_validX", "_sectorsX", "_sectorCountX", "_ratioX"];
		private _capturableSectors = GVAR(allSectors) select {!(_x getVariable [QGVAR(isLocked), false])};
		private _totalSectorCount  = count _capturableSectors;
		private _freeSectorCount   = {_x getVariable [QGVAR(side), sideEmpty] == sideEmpty} count _capturableSectors;
		private _sideTickets       = [GVAR(ticketsEast), GVAR(ticketsResistance), GVAR(ticketsWest)];
		private _sideSectorCounts  = [0, 0, 0];
		{
			_sideX        = _x;
			_validX       = false;
			_sectorsX     = GVAR(allSectors) select {_x getVariable [QGVAR(side), sideEmpty] == _sideX};
			_sectorCountX = count _sectorsX;

			if (_sideTickets # _forEachIndex > 0) then {
				if (_sectorsX findIf {_x getVariable [format [QGVAR(spawnPoints_%1), _sideX], []] isNotEqualTo []} >= 0) then { // Exclusively count spawnable sectors
					_validX = true;
				} else {
					if (
						allPlayers findIf {_x getVariable [QGVAR(side), sideEmpty] == _sideX and {[_x] call FUNC(unit_isAlive)}} >= 0
						or {GVAR(AIUnits) findIf {_x getVariable [QGVAR(side), sideEmpty] == _sideX and {[_x] call FUNC(unit_isAlive)}} >= 0}
					) then {
						_validX = true;
					};
				};
			};

			// If the side is deemed invalid (no tickets left / no sectors and no units left), clear it
			if (_validX) then {
				_sideSectorCounts set [_forEachIndex, _sectorCountX];
			} else {
				_freeSectorCount = _freeSectorCount + _sectorCountX;
				_sideTickets set [_forEachIndex, 0];
				switch (_sideX) do {
					case east:       {GVAR(ticketsEast)       = 0};
					case resistance: {GVAR(ticketsResistance) = 0};
					case west:       {GVAR(ticketsWest)       = 0};
				};
			};
		} forEach GVAR(sides);

		private _maxRatio         = 0;
		private _sideSectorRatios = [0, 0, 0];
		{
			if (_x == sideEmpty) then {
				continue;
			};

			_ratioX   = (_freeSectorCount + (_sideSectorCounts # _forEachIndex)) / _totalSectorCount;
			_maxRatio = _maxRatio max _ratioX;

			_sideSectorRatios set [_forEachIndex, _ratioX];
		} forEach GVAR(sides);





		// Perform ticket bleed
		private _c_sectorRatioThresholdInv = 1 - MACRO_TICKETBLEED_SECTORRATIOTHRESHOLD;
		_sideSectorCounts params ["_sectorCountEast", "_sectorCountResistance", "_sectorCountWest"]; // Needed by the ticket bleed macro
		_sideSectorRatios params ["_sectorRatioEast", "_sectorRatioResistance", "_sectorRatioWest"]; // Needed by the ticket bleed macro

		MACRO_FNC_PERFORMTICKETBLEED(East);
		MACRO_FNC_PERFORMTICKETBLEED(Resistance);
		MACRO_FNC_PERFORMTICKETBLEED(West);

		// Broadcast the ticket counts (and ticket bleed), if they have changed
		MACRO_FNC_BROADCASTONCHANGE(GVAR(ticketsEast),GVAR(ticketsEast_last));
		MACRO_FNC_BROADCASTONCHANGE(GVAR(ticketsResistance),GVAR(ticketsResistance_last));
		MACRO_FNC_BROADCASTONCHANGE(GVAR(ticketsWest),GVAR(ticketsWest_last));

		MACRO_FNC_BROADCASTONCHANGE(GVAR(ticketBleedEast),GVAR(ticketBleedEast_last));
		MACRO_FNC_BROADCASTONCHANGE(GVAR(ticketBleedResistance),GVAR(ticketBleedResistance_last));
		MACRO_FNC_BROADCASTONCHANGE(GVAR(ticketBleedWest),GVAR(ticketBleedWest_last));

		// Send a warning if tickets are running low
		if (GVAR(gm_sys_tickets_remainingWarnings) > 0) then {
			{
				_sideX = _x;
				if (
					GVAR(gm_sys_tickets_canBeWarned) # _forEachIndex
					and {_sideTickets # _forEachIndex < MACRO_TICKETS_WARNINGTHRESHOLD}
				) then {
					GVAR(gm_sys_tickets_remainingWarnings) = GVAR(gm_sys_tickets_remainingWarnings) - 1;
					GVAR(gm_sys_tickets_canBeWarned) set [_forEachIndex, false];

					[MACRO_ENUM_RADIOMSG_TICKETSLOW_LOSE] remoteExecCall [QFUNC(gm_playRadioMsg), _sideX, true];
					{
						[MACRO_ENUM_RADIOMSG_TICKETSLOW_WIN] remoteExecCall [QFUNC(gm_playRadioMsg), _x, true];
					} forEach (GVAR(sides) - [_sideX]);

					[QGVAR(TicketsLow_Siren)] remoteExecCall ["playSound", _sideX, false];
					["LeadTrack03a_F_EPA"] remoteExecCall ["playMusic", 0, false];
				};
			} forEach GVAR(sides);
		};

		GVAR(gm_sys_tickets_nextTime) = _time + MACRO_GM_SYS_TICKETS_INTERVAL;
	};
}];





// Handle unit deaths
removeMissionEventHandler ["EntityKilled", GVAR(gm_sys_tickets_EH_killed)];
GVAR(gm_sys_tickets_EH_killed) = addMissionEventHandler ["EntityKilled", {

	params ["_unit"];

	switch (_unit getVariable [QGVAR(side), sideEmpty]) do {
		case east: {
			GVAR(ticketsEast) = (GVAR(ticketsEast) - 1) max 0;
		};
		case resistance: {
			GVAR(ticketsResistance) = (GVAR(ticketsResistance) - 1) max 0;
		};
		case west: {
			GVAR(ticketsWest) = (GVAR(ticketsWest) - 1) max 0;
		};
	};
}];
