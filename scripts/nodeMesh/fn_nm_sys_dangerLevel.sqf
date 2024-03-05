/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LE]
		Monitors the danger level of all nodemesh nodes and gradually decrements them back down to 0.

		Only executed once upon server init.
	Arguments:
		(none)
	Returns:
		(nothing)

-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"





// Define some macros
#define MACRO_MAX_EDGESPERFRAME 10 // How many node edges we should check per frame (not exact - read as: "at least this many")

// Set up some variables
MACRO_FNC_INITVAR(GVAR(EH_nm_sys_dangerLevel), -1);

GVAR(nm_sys_dangerLevel_index) = 0;





removeMissionEventHandler ["EachFrame", GVAR(EH_nm_sys_dangerLevel)];
GVAR(EH_nm_sys_dangerLevel) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	// Wait for the nodemesh to be set up
	if (!GVAR(nm_isSetup) or {GVAR(nm_nodesTotalcount) <= 0}) exitWith {};

	if (GVAR(missionState) == MACRO_ENUM_MISSION_LIVE) then {

		private ["_node", "_decreaseRate", "_varnameStr"];
		private _time = time;
		private _edgesChecked = 0;
		private _continue = true;

		while {_continue} do {

			// Fetch the current node
			if (GVAR(nm_sys_dangerLevel_index) < GVAR(nm_nodesInfCount)) then {
				_node         = GVAR(nm_nodesInf) # GVAR(nm_sys_dangerLevel_index);
				_decreaseRate = MACRO_NM_DANGERLEVEL_INF_DECREASERATE;
			} else {
				_node         = GVAR(nm_nodesVeh) # (GVAR(nm_sys_dangerLevel_index) - GVAR(nm_nodesInfCount));
				_decreaseRate = MACRO_NM_DANGERLEVEL_VEH_DECREASERATE;
			};

			_deltaTime = _time - (_node getVariable [QGVAR(dangerLevel_prevTime), _time]);
			_neighbours = _node getVariable [QGVAR(neighbours), []];

			// Iterate over this node's neighbours
			{
				_varnameStr = format [QGVAR(dangerLevel_%1), _x getVariable [QGVAR(nodeID), -1]];

				// Decrease this edge's danger level
				_node setVariable [_varnameStr,
				 	((_node getVariable [_varnameStr, 0]) - _decreaseRate * _deltaTime) max 0,
				false];
			} forEach _neighbours;

			// Update the node's check time
			_node setVariable [QGVAR(dangerLevel_prevTime), _time, false];

			_edgesChecked = _edgesChecked + count _neighbours;
			if (_edgesChecked >= MACRO_MAX_EDGESPERFRAME or {GVAR(nm_sys_dangerLevel_index) >= GVAR(nm_nodesTotalcount)}) then {
				_continue = false;
				GVAR(nm_sys_dangerLevel_index) = 0;
			} else {
				GVAR(nm_sys_dangerLevel_index) = GVAR(nm_sys_dangerLevel_index) + 1;
			};

			//hintSilent format ["INDEX: %1", GVAR(nm_sys_dangerLevel_index)];
		};
	};
}];
