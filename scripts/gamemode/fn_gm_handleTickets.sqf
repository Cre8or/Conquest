/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles the respawn ticket counts for each side. Includes player and AI respawns, aswell as ticket
		bleed due to uneven side ratios of captured sectors.

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





// Set up some variales
MACRO_FNC_INITVAR(GVAR(EH_handleTickets_eachFrame),-1);
MACRO_FNC_INITVAR(GVAR(EH_handleTickets_killed),-1);

MACRO_FNC_INITVAR(GVAR(AIUnits),[]);

GVAR(handleTickets_nextTime) = -1;
GVAR(handleTickets_canBeWarned) = GVAR(sides) apply {_x != sideEmpty};
GVAR(handleTickets_remainingWarnings) = ({_x} count GVAR(handleTickets_canBeWarned)) - 1;

GVAR(ticketBleedCounterEast)       = 0;
GVAR(ticketBleedCounterResistance) = 0;
GVAR(ticketBleedCounterWest)       = 0;

GVAR(ticketsEast_last)       = -1;
GVAR(ticketsResistance_last) = -1;
GVAR(ticketsWest_last)       = -1;

GVAR(ticketBleedEast_last)       = false;
GVAR(ticketBleedResistance_last) = false;
GVAR(ticketBleedWest_last)       = false;

// Define some macros
#define MACRO_HANDLETICKETS_UPDATEINTERVAL 0.5

#define MACRO_FNC_PERFORMTICKETBLEED(SIDE)																 \
																					 \
	if (																				 \
		(MERGE(_sectorCount,SIDE) == 0 and {GVAR(MERGE(ticketBleedCounter,SIDE)) >= MACRO_TICKETBLEED_INTERVAL_FAST / MACRO_HANDLETICKETS_UPDATEINTERVAL})	 \
		or {GVAR(MERGE(ticketBleedCounter,SIDE)) >= MACRO_TICKETBLEED_INTERVAL_SLOW / MACRO_HANDLETICKETS_UPDATEINTERVAL}					 \
	) then {																			 \
		GVAR(MERGE(ticketBleedCounter,SIDE)) = 0;														 \
		GVAR(MERGE(tickets,SIDE)) = (GVAR(MERGE(tickets,SIDE)) - 1) max 0;											 \
	}





// Handle ticket bleed
removeMissionEventHandler ["EachFrame", GVAR(EH_handleTickets_eachFrame)];
GVAR(EH_handleTickets_eachFrame) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	private _time = time;
	if (GVAR(missionState) == MACRO_ENUM_MISSION_LIVE and {_time > GVAR(handleTickets_nextTime)}) then {

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
					case east:		{GVAR(ticketsEast)       = 0};
					case resistance:	{GVAR(ticketsResistance) = 0};
					case west:		{GVAR(ticketsWest)       = 0};
				};
			};
		} forEach GVAR(sides);

		private _maxRatio         = 0;
		private _sideSectorRatios = [0, 0, 0];
		{
			if (_x != sideEmpty) then {
				_ratioX   = (_freeSectorCount + (_sideSectorCounts # _forEachIndex)) / _totalSectorCount;
				_maxRatio = _maxRatio max _ratioX;

				_sideSectorRatios set [_forEachIndex, _ratioX];
			};
		} forEach GVAR(sides);
		_sideSectorCounts params ["_sectorCountEast", "_sectorCountResistance", "_sectorCountWest"]; // Needed by the ticket bleed macro



		GVAR(ticketBleedEast)       = false;
		GVAR(ticketBleedResistance) = false;
		GVAR(ticketBleedWest)       = false;

		// Determine ticket bleed
		private _c_sectorRatioThresholdInv = 1 - MACRO_TICKETBLEED_SECTORRATIOTHRESHOLD;
		if (_sectorCountEast == 0 or {_maxRatio - _sideSectorRatios # 0 > _c_sectorRatioThresholdInv}) then {
			GVAR(ticketBleedEast) = true;
			GVAR(ticketBleedCounterEast) = GVAR(ticketBleedCounterEast) + 1;
		};
		if (_sectorCountResistance == 0 or {_maxRatio - _sideSectorRatios # 1 > _c_sectorRatioThresholdInv}) then {
			GVAR(ticketBleedResistance) = true;
			GVAR(ticketBleedCounterResistance) = GVAR(ticketBleedCounterResistance) + 1;
		};
		if (_sectorCountWest == 0 or {_maxRatio - _sideSectorRatios # 2 > _c_sectorRatioThresholdInv}) then {
			GVAR(ticketBleedWest) = true;
			GVAR(ticketBleedCounterWest) = GVAR(ticketBleedCounterWest) + 1;
		};

		// Perform ticket bleed
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
		if (GVAR(handleTickets_remainingWarnings) > 0) then {
			{
				_sideX = _x;
				if (
					GVAR(handleTickets_canBeWarned) # _forEachIndex
					and {_sideTickets # _forEachIndex < MACRO_TICKETS_WARNINGTHRESHOLD}
				) then {
					GVAR(handleTickets_remainingWarnings) = GVAR(handleTickets_remainingWarnings) - 1;
					GVAR(handleTickets_canBeWarned) set [_forEachIndex, false];

					[MACRO_ENUM_RADIOMSG_TICKETSLOW_LOSE] remoteExecCall [QFUNC(gm_playRadioMsg), _sideX, true];
					{
						[MACRO_ENUM_RADIOMSG_TICKETSLOW_WIN] remoteExecCall [QFUNC(gm_playRadioMsg), _x, true];
					} forEach (GVAR(sides) - [_sideX]);

					[QGVAR(TicketsLow_Siren)] remoteExecCall ["playSound", _sideX, false];
					["LeadTrack03a_F_EPA"] remoteExecCall ["playMusic", 0, false];
				};
			} forEach GVAR(sides);
		};

		GVAR(handleTickets_nextTime) = _time + MACRO_HANDLETICKETS_UPDATEINTERVAL;
	};
}];





// Handle unit deaths
removeMissionEventHandler ["EntityKilled", GVAR(EH_handleTickets_killed)];
GVAR(EH_handleTickets_killed) = addMissionEventHandler ["EntityKilled", {

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
