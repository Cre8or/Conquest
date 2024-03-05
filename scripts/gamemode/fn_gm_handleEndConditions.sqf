/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles the gamemode's ending conditions.
		Conquest missions end when only one side is still able to play. A side is considered as playable if it
		fulfills these two conditions:
		- it still has tickets left,
		- it owns at least one sector, OR has units that are still alive (and thus able to capture any flags).

		Only executed once by the server upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

if (!isServer) exitWith {};





// Set up some variales
MACRO_FNC_INITVAR(GVAR(EH_endConditions_eachFrame),-1);

GVAR(endConditions_nextTime) = -1;
GVAR(endConditions_validSidesCountPrev) = {_x > 0} count [GVAR(ticketsEast), GVAR(ticketsResistance), GVAR(ticketsWest)];





// Handle ticket bleed
removeMissionEventHandler ["EachFrame", GVAR(EH_endConditions_eachFrame)];
GVAR(EH_endConditions_eachFrame) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	private _time = time;
	if (GVAR(missionState) == MACRO_ENUM_MISSION_LIVE and {_time > GVAR(endConditions_nextTime)}) then {

		private _sideTickets     = [GVAR(ticketsEast), GVAR(ticketsResistance), GVAR(ticketsWest)];
		private _validSidesCount = {_x > 0} count _sideTickets;

		// Check if only one valid side remains
		if (_validSidesCount < GVAR(endConditions_validSidesCountPrev)) then {

			switch (_validSidesCount) do {

				case 2: {
					private _defeatedSide = GVAR(sides) # (_sideTickets findIf {_x <= 0});

					[MACRO_ENUM_RADIOMSG_SIDEDEFEATED_LOSE] remoteExecCall [QFUNC(gm_playRadioMsg), _defeatedSide, false];

					{
						[MACRO_ENUM_RADIOMSG_SIDEDEFEATED_WIN] remoteExecCall [QFUNC(gm_playRadioMsg), _x, false];
					} forEach (GVAR(sides) - [_defeatedSide, sideEmpty]);

					// Hand out score, and remove the sector capturing ability from affected units
					{
						if (_x getVariable [QGVAR(side), sideEmpty] == _defeatedSide) then {
							_x setVariable [QGVAR(canCaptureSectors), false, false];
						} else {
							[_x, MACRO_ENUM_SCORE_SIDEDEFEATED, _defeatedSide] call FUNC(gm_addScore);
						};
					} forEach (allPlayers + GVAR(AIUnits));

					[QGVAR(TicketsLow_Siren)] remoteExecCall ["playSound", _defeatedSide, false];
				};

				case 1: {
					private _winnerSide = GVAR(sides) # (_sideTickets findIf {_x > 0});
					private _isDecisive = ([_winnerSide] call FUNC(gm_getSideTickets)) >= MACRO_TICKETS_DECISIVETHRESHOLD;

					[_winnerSide, _isDecisive] remoteExecCall [QFUNC(gm_endMission), 0, true];

					// Give everyone from the winning side some points
					{
						if (_x getVariable [QGVAR(side), sideEmpty] == _winnerSide) then {
							[_x, MACRO_ENUM_SCORE_SIDEDEFEATED] call FUNC(gm_addScore);
						};
					} forEach (allPlayers + GVAR(AIUnits));
				};

				// Edge cases: no valid side remains
				case 0: {
					[sideEmpty, false] remoteExecCall [QFUNC(gm_endMission), 0, true];
				};
			};

			GVAR(endConditions_validSidesCountPrev) = _validSidesCount;
		};

		GVAR(endConditions_nextTime) = _time + 0.25;
	};
}];
