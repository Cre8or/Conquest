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
#define MACRO_MAX_EDGESPERFRAME 20 // How many node edges we should check per frame (not exact - read as: "at least this many")

// Set up some variables
MACRO_FNC_INITVAR(GVAR(nm_sys_dangerLevel_EH), -1);

GVAR(nm_sys_dangerLevel_index) = 0;





removeMissionEventHandler ["EachFrame", GVAR(nm_sys_dangerLevel_EH)];
GVAR(nm_sys_dangerLevel_EH) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	// Wait for the nodemesh to be set up
	if (!GVAR(nm_isSetup) or {GVAR(nm_nodesTotalcount) <= 0}) exitWith {};

	if (GVAR(missionState) == MACRO_ENUM_MISSION_LIVE) then {

		private _time = time;
		private _allSides = GVAR(sides) select {_x != sideEmpty};
		private _edgesChecked = 0;
		private _continue = true;
		private ["_node", "_decreaseRate", "_deltaTime", "_neighbours", "_neighbourX", "_varnameStr", "_dangerLevel"];

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
				_neighbourX = _x;

				// Decrease this edge's danger level
				{
					_varnameStr  = format [QGVAR(dangerLevel_%1_%2), _neighbourX getVariable [QGVAR(nodeID), -1], _x];
					_dangerLevel = _node getVariable [_varnameStr, 0];

					if (_dangerLevel > 0) then {
						//diag_log format ["[dangerLevel] (%1) Edge %2 -> %3 at: %4", _time, _node getVariable [QGVAR(nodeID), -1], _neighbourX getVariable [QGVAR(nodeID), -1], _dangerLevel]
						_node setVariable [_varnameStr, (_dangerLevel - _decreaseRate * _deltaTime) max 0, false];
					};

					_edgesChecked = _edgesChecked + 1;
				} forEach _allSides;
			} forEach _neighbours;

			// Update the node's check time
			_node setVariable [QGVAR(dangerLevel_prevTime), _time, false];

			if (_edgesChecked >= MACRO_MAX_EDGESPERFRAME or {GVAR(nm_sys_dangerLevel_index) >= GVAR(nm_nodesTotalcount)}) then {
				_continue = false;
			};
			GVAR(nm_sys_dangerLevel_index) = GVAR(nm_sys_dangerLevel_index) + 1;
		};

		// Restart at the beginning
		if (GVAR(nm_sys_dangerLevel_index) >= GVAR(nm_nodesTotalcount)) then {
			GVAR(nm_sys_dangerLevel_index) = 0;
			//diag_log format ["[dangerLevel] (%1) Finished full loop - restarting", _time];
		};
	};
}];
