/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles the spawning of the custom nodemesh, including nodes and occluders.

		Only executed once upon server init.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"





// Set up some macros
#define MACRO_MAX_SPAWNSPERFRAME 20 // How many nodes to spawn per frame (stage 1)
#define MACRO_MAX_LINKSPERFRAME 100 // How many nodes to link together per frame (stage 2)

// Set up some variables
MACRO_FNC_INITVAR(GVAR(nm_nodesInf), []);
MACRO_FNC_INITVAR(GVAR(nm_nodesVeh), []);
MACRO_FNC_INITVAR(GVAR(nm_occludersInf), []);
MACRO_FNC_INITVAR(GVAR(nm_occludersVeh), []);
MACRO_FNC_INITVAR(GVAR(nm_setupNodeMesh_EH), -1);
MACRO_FNC_INITVAR(GVAR(nm_setupNodeMesh_EH_draw3D_occluders), -1);
MACRO_FNC_INITVAR(GVAR(nm_setupNodeMesh_EH_draw3D_findPath), -1);

#ifdef MACRO_DEBUG_NM_OCCLUDERS
	GVAR(debug_drawData_nm_occluders) = [];
#endif
#ifdef MACRO_DEBUG_NM_PATH
	GVAR(debug_drawData_nm_findPath) = [];
#endif

// Include the nodemesh data files (yep, this looks ugly, but it works)
private _nodeData_inf =
	#include "..\..\mission\nodeMesh\data_nodemesh_inf.inc"
;
private _nodeData_veh =
	#include "..\..\mission\nodeMesh\data_nodemesh_veh.inc"
;
private _occluders_inf =
	#include "..\..\mission\nodeMesh\data_occluders_inf.inc"
;
private _occluders_veh =
	#include "..\..\mission\nodeMesh\data_occluders_veh.inc"
;
GVAR(nm_temp_nodeData)           = _nodeData_inf + _nodeData_veh;
GVAR(nm_temp_occluders)          = _occluders_inf + _occluders_veh;
GVAR(nm_temp_index)              = 0;
GVAR(nm_temp_stage)              = 1;
GVAR(nm_temp_occluders_indexVeh) = count _occluders_inf;
GVAR(nm_temp_occluders_count)    = count GVAR(nm_temp_occluders);

GVAR(nm_nodesInfCount)   = count _nodeData_inf;
GVAR(nm_nodesTotalcount) = count GVAR(nm_temp_nodeData);





// Remove the previous nodes and occluders, if there are any
{deleteVehicle _x} forEach GVAR(nm_nodesInf);
{deleteVehicle _x} forEach GVAR(nm_nodesVeh);
{deleteVehicle _x} forEach GVAR(nm_occludersInf);
{deleteVehicle _x} forEach GVAR(nm_occludersVeh);
GVAR(nm_nodesInf)     = [];
GVAR(nm_nodesVeh)     = [];
GVAR(nm_occludersInf) = [];
GVAR(nm_occludersVeh) = [];





systemChat "Spawning nodemesh...";

removeMissionEventHandler ["EachFrame", GVAR(nm_setupNodeMesh_EH)];
GVAR(nm_setupNodeMesh_EH) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	// Set up some constants
	private _allSides = [east, resistance, west];
	private _varName_usedBySide_east       = format [QGVAR(usedBy_%1), east];
	private _varName_usedBySide_resistance = format [QGVAR(usedBy_%1), resistance];
	private _varName_usedBySide_west       = format [QGVAR(usedBy_%1), west];

	private _varNames_usedBySide = [
		_varName_usedBySide_east,
		_varName_usedBySide_resistance,
		_varName_usedBySide_west
	];
	private _varNames_knots = [
		format [QGVAR(knots_%1), east],
		format [QGVAR(knots_%1), resistance],
		format [QGVAR(knots_%1), west]
	];





	// --------------------------------------------------------- STAGE 1 / 4 ---------------------------------------------------------
	// Spawn the nodes
	if (GVAR(nm_temp_stage) == 1) then {
		private ["_curNodeData", "_node"];
		private _iterations = MACRO_MAX_SPAWNSPERFRAME min (GVAR(nm_nodesTotalcount) - GVAR(nm_temp_index));

		for "_i" from GVAR(nm_temp_index) to GVAR(nm_temp_index) + _iterations - 1 do {
			_curNodeData = GVAR(nm_temp_nodeData) # _i;

			// It's an infantry node
			if (_i < GVAR(nm_nodesInfCount)) then {
				_node = MACRO_CLASS_NODEMESH_NODE_INF createVehicleLocal [0,0,0];
				GVAR(nm_nodesInf) pushBack _node;

				[_node, _curNodeData, _i, false] call FUNC(nm_setupNode);

				#ifndef MACRO_DEBUG_NM_NODES_INF
		 			_node hideObject true;
				#endif

			// It's a vehicle node
			} else {
				_node = MACRO_CLASS_NODEMESH_NODE_VEH createVehicleLocal [0,0,0];
				GVAR(nm_nodesVeh) pushBack _node;

				[_node, _curNodeData, _i - GVAR(nm_nodesInfCount), true] call FUNC(nm_setupNode);

				#ifndef MACRO_DEBUG_NM_NODES_VEH
 					_node hideObject true;
				#endif
			};

			// Position the node properly
/* 0  */		_node setPosWorld (_curNodeData # 0);
		};

		// Once we spawned all nodes, move on to stage 2
		GVAR(nm_temp_index) = GVAR(nm_temp_index) + _iterations;
		if (GVAR(nm_temp_index) >= GVAR(nm_nodesTotalcount)) then {
			GVAR(nm_temp_stage) = 2;
			GVAR(nm_temp_index) = 0;
		};
	};





	// --------------------------------------------------------- STAGE 2 / 4 ---------------------------------------------------------
	// Link the nodes together
	if (GVAR(nm_temp_stage) == 2) then {
		// Iterate a second time to establish the segment nodes arrays (since we need all nodes to already be spawned for this to work)
		private ["_node", "_nodeX", "_nodesArray", "_segmentArray", "_allKnotArrays"];
		private _iterations = MACRO_MAX_LINKSPERFRAME min (GVAR(nm_nodesTotalcount) - GVAR(nm_temp_index));

		for "_i" from GVAR(nm_temp_index) to GVAR(nm_temp_index) + _iterations - 1 do {

			if (_i < GVAR(nm_nodesInfCount)) then {
				_nodesArray = GVAR(nm_nodesInf);
				_node = _nodesArray # _i;
			} else {
				_nodesArray = GVAR(nm_nodesVeh);
				_node = _nodesArray # (_i - GVAR(nm_nodesInfCount));
			};

			// Iterate over this node's neighbours
			_node setVariable [QGVAR(neighbours),
				(_node getVariable [QGVAR(neighbours), []]) apply {_nodesArray # _x}
			];

			// Iterate over this node's connections
			{
				// Iterate over all sides' segment arays for this connection
				{
					_segmentArray = _node getVariable [_x, []];

					// If the segments array contains numbers (node IDs), this connection only has one segment
					if (_segmentArray param [0, 0] isEqualType 0) then {
						_node setVariable [_x, _segmentArray apply {
							_nodesArray # _x
						}];

					// Otherwise, if there are nested arrays, there are multiple segments
					} else {
						_node setVariable [_x, _segmentArray apply {
							_x apply {
								_nodesArray # _x;
							}
						}];
					};
				} forEach [
					format [QGVAR(segments_%1_%2), _x, east],
					format [QGVAR(segments_%1_%2), _x, resistance],
					format [QGVAR(segments_%1_%2), _x, west]
				];
			} forEach (_node getVariable [QGVAR(connections), []]);

			_allKnotArrays = [[], [], []];
			_allUsedByVars = [
				_node getVariable [_varName_usedBySide_east, true],
				_node getVariable [_varName_usedBySide_resistance, true],
				_node getVariable [_varName_usedBySide_west, true]
			];

			// Iterate over this node's knots
			{
				_nodeX = _x;
				// Test on all sides
				{
					// If the "usedBySide" status matches on both nodes, keep this node in the knots list
					if (_allUsedByVars # _forEachIndex isEqualTo (_nodesArray # _nodeX getVariable [_varNames_usedBySide # _forEachIndex, true])) then {
						(_allKnotArrays # _forEachIndex) pushBack _nodeX;
					};
			 	} forEach _allSides;
			} forEach (_node getVariable [QGVAR(knots), []]);

			// Save the new side-specific knot arrays onto the node
			{
				_node setVariable [_varNames_knots # _forEachIndex, _x, false];
			} forEach _allKnotArrays;
		};

		// Once we spawned all nodes, move on to stage 3
		GVAR(nm_temp_index) = GVAR(nm_temp_index) + _iterations;
		if (GVAR(nm_temp_index) >= GVAR(nm_nodesTotalcount)) then {
			GVAR(nm_temp_stage) = 3;
			GVAR(nm_temp_index) = 0;
		};
	};





	// --------------------------------------------------------- STAGE 3 / 4 ---------------------------------------------------------
	// Spawn the occluders
	if (GVAR(nm_temp_stage) == 3) then {
		private ["_curNodeData", "_occluder"];
		private _iterations = MACRO_MAX_SPAWNSPERFRAME min (GVAR(nm_temp_occluders_count) - GVAR(nm_temp_index));

		for "_i" from GVAR(nm_temp_index) to GVAR(nm_temp_index) + _iterations - 1 do {

			// It's an infantry node
			if (_i < GVAR(nm_temp_occluders_indexVeh)) then {
				_occluder = MACRO_CLASS_NODEMESH_OCCLUDER_INF createVehicleLocal [0,0,0];
				GVAR(nm_occludersInf) pushBack _occluder;

				_occluder setVariable [QGVAR(nodeID), _i];

			// It's a vehicle node
			} else {
				_occluder = MACRO_CLASS_NODEMESH_OCCLUDER_VEH createVehicleLocal [0,0,0];
				GVAR(nm_occludersVeh) pushBack _occluder;

				_occluder setVariable [QGVAR(nodeID), _i - GVAR(nm_temp_occluders_indexVeh)];
			};

			_curNodeData = GVAR(nm_temp_occluders) # _i;
/* 0 */			_occluder setPosWorld ((_curNodeData # 0) + [0]);

/* 1 */			_occluder setVariable [QGVAR(knots), _curNodeData # 1];
 			_occluder hideObject true;
		};

		// Once we spawned all occluders, move on to stage 4
		GVAR(nm_temp_index) = GVAR(nm_temp_index) + _iterations;
		if (GVAR(nm_temp_index) >= GVAR(nm_temp_occluders_count)) then {
			GVAR(nm_temp_stage) = 4;
			GVAR(nm_temp_index) = 0;
		};
	};





	// --------------------------------------------------------- STAGE 4 / 4 ---------------------------------------------------------
	// Link the occluders together
	if (GVAR(nm_temp_stage) == 4) then {
		// Iterate a second time to establish the segment nodes arrays (since we need all nodes to already be spawned for this to work)
		private ["_occluder", "_occludersArray"];
		private _iterations = MACRO_MAX_LINKSPERFRAME min (GVAR(nm_temp_occluders_count) - GVAR(nm_temp_index));

		for "_i" from GVAR(nm_temp_index) to GVAR(nm_temp_index) + _iterations - 1 do {

			if (_i < GVAR(nm_temp_occluders_indexVeh)) then {
				_occludersArray = GVAR(nm_occludersInf);
				_occluder = _occludersArray # _i;
			} else {
				_occludersArray = GVAR(nm_occludersVeh);
				_occluder = _occludersArray # (_i - GVAR(nm_temp_occluders_indexVeh));
			};

			// Set up the occluder's neighbours list
			_occluder setVariable [QGVAR(neighbours), (_occluder getVariable [QGVAR(knots), []]) apply {
				_occludersArray # _x
			}, false];
			_occluder setVariable [QGVAR(knots), nil, false];

			#ifdef MACRO_DEBUG_NM_OCCLUDERS
				private _posOccluder = getPosWorld _occluder;

				{
					GVAR(debug_drawData_nm_occluders) pushBack [
						_posOccluder,
						getPosWorld _x,
						[[0,1,0,1], [0,0,1,1]] select (_i >= GVAR(nm_temp_occluders_indexVeh))
					];
				} forEach (_occluder getVariable [QGVAR(neighbours), []]);
			#endif
		};

		// Wrap up
		GVAR(nm_temp_index) = GVAR(nm_temp_index) + _iterations;
		if (GVAR(nm_temp_index) >= GVAR(nm_temp_occluders_count)) then {
			removeMissionEventHandler ["EachFrame", GVAR(nm_setupNodeMesh_EH)];

			// Clean up the largest temporary variables
			GVAR(nm_temp_nodeData)  = nil;
			GVAR(nm_temp_occluders) = nil;

			GVAR(nm_isSetup) = true;
			systemChat format ["Spawning nodemesh... DONE! (%1 nodes / %2 occluders)", GVAR(nm_nodesTotalcount), GVAR(nm_temp_occluders_count)];
		};
	};
}];





// Debug rendering
removeMissionEventHandler ["Draw3D", GVAR(nm_setupNodeMesh_EH_draw3D_occluders)];
removeMissionEventHandler ["Draw3D", GVAR(nm_setupNodeMesh_EH_draw3D_findPath)];

#ifdef MACRO_DEBUG_NM_OCCLUDERS
	GVAR(nm_setupNodeMesh_EH_draw3D_occluders) = addMissionEventHandler ["Draw3D", {

		if (isGamePaused) exitWith {};

		{
			_x params ["_posStart", "_posEnd", "_colour"];
			drawLine3D [
				_posStart,
				_posStart vectorAdd [0,0,5],
				_colour
			];
			drawLine3D [
				_posEnd,
				_posEnd vectorAdd [0,0,5],
				_colour
			];
			drawLine3D [
				_posStart vectorAdd [0,0,5],
				_posEnd vectorAdd [0,0,5],
				_colour
			];
		} foreach GVAR(debug_drawData_nm_occluders);
	}];
#endif

#ifdef MACRO_DEBUG_NM_PATH
	GVAR(nm_setupNodeMesh_EH_draw3D_findPath) = addMissionEventHandler ["Draw3D", {

		if (isGamePaused) exitWith {};

		{
			_x params ["_posStart", "_posEnd", "_colour"];

			drawLine3D [
				ASLtoAGL _posStart,
				ASLtoAGL _posEnd,
				_colour
			];
		} foreach GVAR(debug_drawData_nm_findPath);
	}];
#endif
