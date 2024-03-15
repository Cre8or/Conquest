/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles the gamemode's ending conditions. Conquest missions end when only one playable side remains.
		Additionally handles score rewarding when a side is defeated.

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
MACRO_FNC_INITVAR(GVAR(gm_sys_endConditions_EH),-1);

GVAR(gm_sys_endConditions_nextTime)            = -1;
GVAR(gm_sys_endConditions_validSidesCountPrev) = ({_x > 0} count [GVAR(ticketsEast), GVAR(ticketsResistance), GVAR(ticketsWest)]) max 1;





// Monitor game end conditions
removeMissionEventHandler ["EachFrame", GVAR(gm_sys_endConditions_EH)];
GVAR(gm_sys_endConditions_EH) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	private _time = time;
	if (GVAR(missionState) == MACRO_ENUM_MISSION_LIVE and {_time > GVAR(gm_sys_endConditions_nextTime)}) then {

		private _sideTickets     = [GVAR(ticketsEast), GVAR(ticketsResistance), GVAR(ticketsWest)];
		private _validSidesCount = {_x > 0} count _sideTickets;

		// Check if only one valid side remains
		if (_validSidesCount < GVAR(gm_sys_endConditions_validSidesCountPrev)) then {

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

			GVAR(gm_sys_endConditions_validSidesCountPrev) = _validSidesCount;
		};

		GVAR(gm_sys_endConditions_nextTime) = _time + MACRO_GM_SYS_ENDCONDITIONS_INTERVAL;
	};
}];
