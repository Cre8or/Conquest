/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Calculates and returns a path between a origin and a destination using Dijkstra's algorithm on a
		predefined nodemesh (built into the mission).
		Used for both infantry and vehicle movement. Use the third parameter to specify which nodeMesh you want
		to calculate a path on.
		Optionally, the starting node can be preset by passing its corresponding node ID. Doing so will skip
		the usual starting node search, aswell as any occlusion checks for that node.
		Returns three empty arrays if no path could be found.
	Arguments:
		0:      <OBJECT>	The object that requested a path (also used as the origin from where the
					search should start)
		1:	<ARRAY>		The destination to which the search should lead (in format posWorld)
		2:	<BOOLEAN>	Whether to use the vehicles nodeMesh (true) or the infantry nodeMesh (false)
		3:	<BOOLEAN>	Whether the values in the radii array should be squared or not (useful in
					combination with distanceSqr)
		4:	<NUMBER>	The ID of the starting node (optional, default: -1)
	Returns:
		0:	<ARRAY>		An array consisting of positions (in format posWorld) that compose the
					resulting path (from the provided origin to the destination).
					The destination is only included if it is within the unit's combat area; the
					origin is never included
		1:	<ARRAY>		An array containing the radii of the path's nodes. If argument #3 is true,
		 			the values will be squared
		2:	<ARRAY>		An Array containing the path's nodes as objects (for the destination, objNull
					is used instead)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

params [
	["_unit", objNull, [objNull]],
	["_destination", [], [[]]],
	["_isVehicle", true, [true]],
	["_outputRadiiSquared", false, [false]],
	["_startNodeID", -1, [-1]]
];

if (!GVAR(nm_isSetup)) exitWith {[[],[],[]]};

if (!alive _unit or {_destination isEqualTo []}) exitWith {
	if (alive _unit) then {
		systemChat "[fnc_nm_findPath] ERROR: Invalid parameters passed! (Object is dead)";
	} else {
		systemChat "[fnc_nm_findPath] ERROR: Invalid parameters passed! (Destination is empty)";
	};
	[[],[],[]]
};





// Set up some constants
private _timeStart = diag_tickTime;
private _const_maxCost      = 2^24;
private _side               = side group _unit;
private _origin             = getPosWorld _unit;
private _originAGL          = ASLtoAGL _origin;
private _destinationAGL     = ASLtoAGL _destination;
private _isDestinationInCA  = [_destination, _side] call FUNC(ca_isInCombatArea);
private _allNodes           = [GVAR(nm_nodesInf), GVAR(nm_nodesVeh)] select _isVehicle;
private _defaultRadius      = [MACRO_NM_DEFAULTRADIUS_INF, MACRO_NM_DEFAULTRADIUS_VEH] select _isVehicle;
private _nodeClass          = [MACRO_CLASS_NODEMESH_NODE_INF, MACRO_CLASS_NODEMESH_NODE_VEH] select _isVehicle;
private _occluderClass      = [MACRO_CLASS_NODEMESH_OCCLUDER_INF, MACRO_CLASS_NODEMESH_OCCLUDER_VEH] select _isVehicle;
private _nodeSearchRadius   = [MACRO_NM_SEARCHRADIUS_NODES_INF, MACRO_NM_SEARCHRADIUS_NODES_VEH] select _isVehicle;
private _varName_cost       = [QGVAR(dist_%1), QGVAR(cost_%1)] select _isVehicle;
private _varName_costArray  = [format [QGVAR(distances_%1_%2), "%1", _side], format [QGVAR(costs_%1_%2), "%1", _side]] select _isVehicle;
private _varName_knots      = format [QGVAR(knots_%1), _side];
private _varName_usedBySide = format [QGVAR(usedBy_%1), _side];
private _varName_segmentsX  = format [QGVAR(segments_%1_%2), "%1", _side];

// Set up some variables
private _result = [];
private _nodeQueue = [];
private _namespace_costs        = createLocation ["NameVillage", [0,0,0], 0, 0];
private _namespace_undiscovered = createLocation ["NameVillage", [0,0,0], 0, 0];
private _namespace_unvisited    = createLocation ["NameVillage", [0,0,0], 0, 0];
private _namespace_precedents   = createLocation ["NameVillage", [0,0,0], 0, 0];
private _namespace_segmentIndex = createLocation ["NameVillage", [0,0,0], 0, 0];
private _namespace_isStartNode  = createLocation ["NameVillage", [0,0,0], 0, 0];
private _namespace_isEndNode    = createLocation ["NameVillage", [0,0,0], 0, 0];
private _namespace_endNodes     = createLocation ["NameVillage", [0,0,0], 0, 0];
private _namespace_endNodesCost = createLocation ["NameVillage", [0,0,0], 0, 0];
private _continue = true;
private _maxCost = _const_maxCost;
private _startNodesCount = 0;
private _endNodesCount = 0;
private _bestEndNode = objNull;

#ifdef MACRO_DEBUG_NM_PATH
	MACRO_FNC_INITVAR(GVAR(nm_nodesPainted), []);
	GVAR(debug_drawData_nm_findPath) = [];

	{
		_x setObjectTexture [0, _x getVariable ["nodeTexture", ""]];
	} forEach GVAR(nm_nodesPainted);

	//GVAR(curatorModule) removeCuratorEditableObjects [GVAR(nm_nodesPainted), false];
	GVAR(nm_nodesPainted) = [];
#endif

scopeName QGVAR(findPath_main);





// --------------------------------------------------------- STAGE 1 / 5 ---------------------------------------------------------
// Determine the start and end nodes, and see if a direct connection is possible at short distances
private ["_posX", "_nodeX", "_nodeStrX", "_cost", "_knotStrX"];
private _startOccluders = nearestObjects [_originAGL, [_occluderClass], _nodeSearchRadius * 1.5, true]; // Additional 50% of search radius to be extra sure
private _endOccluders   = nearestObjects [_destinationAGL, [_occluderClass], _nodeSearchRadius * 1.5, true];

if (
	_isDestinationInCA
	and {_origin distance _destination < ([_nodeSearchRadius / 2, _nodeSearchRadius / 4] select _isVehicle)} // Sets how far a potential direct path is allowed to be
	and {[_origin, _destination, _startOccluders + _endOccluders, _occluderClass] call FUNC(nm_checkOcclusion)}
) exitWith {

	#ifdef MACRO_DEBUG_NM_PATH
		GVAR(debug_drawData_nm_findPath) pushBack [_originAGL vectorAdd [0,0,0.5], _destinationAGL vectorAdd [0,0,0.5], [1,1,0,1]];
	#endif

	private _completionRadius = _defaultRadius;
	if (_outputRadiiSquared) then {
		_completionRadius = _completionRadius ^ 2;
	};

	[[_destination], [_completionRadius], [objNull]];
};

// Find unoccluded start nodes
private _startNode = _allNodes param [_startNodeID, objNull];

// Special case: a starting node was passed
if (alive _startNode) then {
	_startNodesCount = _startNodesCount + 1;

	// Add it to the queue
	_nodeStrX = str _startNodeID;
	_namespace_undiscovered setVariable [_nodeStrX, false];
	_namespace_costs setVariable [_nodeStrX, 0];
	_namespace_isStartNode setVariable [_nodeStrX, true];
	_nodeQueue pushBack [0, _startNode];

// If the starting node is invalid, search for candidates
} else {
	private _speed = 30 + (2 * speed _unit max 0);
	private "_dotMul";
	{
		if (_startNodesCount < MACRO_NM_MAXCOUNT_NODES) then {

			// Only continue if this node may be used by the unit's side
			if (_x getVariable [_varName_usedBySide, true]) then {
				_posX = getPosWorld _x;

				// If the node isn't occluded, make it a start node
				if ([_posX, _origin, _startOccluders, _occluderClass] call FUNC(nm_checkOcclusion)) then {
					_startNodesCount = _startNodesCount + 1;

					// Determine the cost to this node
					_cost = ([_origin, _posX] call FUNC(nm_getRawCost)) * ([MACRO_NM_COSTMULTIPLIER_OFFMESH_INF, MACRO_NM_COSTMULTIPLIER_OFFMESH_VEH] select _isVehicle);

					// Special case: nodes that are not aligned with the vehicle's forward direction get a penalty (to prevent 180°s)
					if (_isVehicle) then {
						_dotMul = [_origin, _origin vectorAdd vectorDir _unit, _origin, _posX, true] call FUNC(math_dot2D);

						_cost = _cost + (1 - _dotMul) * _speed;
					};

					// Add the nodes to the queue
					_nodeStrX = str (_x getVariable [QGVAR(nodeID), -1]);
					_namespace_undiscovered setVariable [_nodeStrX, false];
					_namespace_costs setVariable [_nodeStrX, _cost];
					_namespace_isStartNode setVariable [_nodeStrX, true];
					_nodeQueue pushBack [_cost, _x];
				};
			};
		} else {
			breakTo QGVAR(findPath_main);
		};
	} forEach nearestObjects [_originAGL, [_nodeClass], _nodeSearchRadius];
};

// Find unoccluded end nodes
{
	if (_endNodesCount > MACRO_NM_MAXCOUNT_NODES) then {
		breakTo QGVAR(findPath_main);
	};

	// Only continue if this node may be used by the unit's side
	if !(_x getVariable [_varName_usedBySide, true]) then {
		continue;
	};

	// If the node isn't occluded, make it an end node
	_posX = getPosWorld _x;
	if !([_posX, _destination, _endOccluders, _occluderClass] call FUNC(nm_checkOcclusion)) then {
		continue;
	};
	_endNodesCount = _endNodesCount + 1;

	// Determine the cost from this node
	_cost = ([_posX, _destination] call FUNC(nm_getRawCost)) * ([MACRO_NM_COSTMULTIPLIER_OFFMESH_INF, MACRO_NM_COSTMULTIPLIER_OFFMESH_VEH] select _isVehicle);

	// Mark this node as an end node and save its cost
	_nodeStrX = str (_x getVariable [QGVAR(nodeID), -1]);
	_namespace_isEndNode setVariable [_nodeStrX, true];
	_namespace_endNodesCost setVariable [_nodeStrX, _cost];

	// If this node is a segment node, fetch its 2 end knots and make them end nodes aswell
	if !(_x getVariable [QGVAR(isKnot), false]) then {
		_nodeX = _x;

		private ["_knotX", "_segmentPosX", "_segmentNodeStrX", "_costX"];
		{
			_knotStrX = str _x;
			_namespace_isEndNode setVariable [_knotStrX, true];
			_namespace_endNodes setVariable [_knotStrX, (_namespace_endNodes getVariable [_knotStrX, []]) + [_nodeX]];

			// Also make all nodes on the segment to this knot end nodes too, and calculate their cost.
			// This prevents edge cases where the neighbouring knots are favoured over using a part of the segment
			// in order to reach the candidate end nodes (causing loop-arounds).
			_knotX = _allNodes param [_x, objNull];
			{
				_segmentPosX = getPosWorld _x;

				if !([_segmentPosX, _destination, _endOccluders, _occluderClass] call FUNC(nm_checkOcclusion)) then {
					continue;
				};

				_segmentNodeStrX = str (_x getVariable [QGVAR(nodeID), -1]);
				_namespace_isEndNode setVariable [_segmentNodeStrX, true];

				// TODO: Figure out why the first line below does not work (yet the second one does)
				//_costX = ([_x, _nodeX, _varName_cost, _varName_segmentsX] call FUNC(nm_getSegmentCost));
				_costX = ([_nodeX, _x, _varName_cost, _varName_segmentsX] call FUNC(nm_getSegmentCost));

				//systemChat format ["%1 -> %2: %3", _nodeStrX, _segmentNodeStrX, _costX];
				_costX = _costX + _cost;
				_namespace_endNodesCost setVariable [_segmentNodeStrX, _costX];

			} forEach (_knotX getVariable [format [_varName_segmentsX, _nodeStrX], []]);
		} forEach (_nodeX getVariable [_varName_knots, []]);
	};
} forEach nearestObjects [_destinationAGL, [_nodeClass], _nodeSearchRadius];





// If no start or end node could be determined, exit and return an empty array
if (_startNodesCount == 0 or {_endNodesCount == 0}) exitWith {
	//systemChat "[fnc_nm_findPath] ERROR: Could not determine the start/end node!";
	[[],[],[]];
};
/*
diag_log "";
diag_log format ["Candidates (start): %1", _nodeQueue apply {(_x # 1) getVariable [QGVAR(nodeID), -1]}];
diag_log format ["Candidates (end): %1", (allVariables _namespace_isEndNode) apply {
	[parseNumber _x, (_namespace_endNodes getVariable [_x, []]) apply {_x getVariable [QGVAR(nodeID), -1]}]
}];
*/

// --------------------------------------------------------- STAGE 2 / 5 ---------------------------------------------------------
// Find a path between the start and end nodes
private ["_curKnot", "_curEntry", "_isKnot", "_curCost", "_curKnotStr", "_lastNode", "_lastNodeStr", "_segment", "_segmentIndex", "_oldCost", "_newCost", "_connectedNodesToCheck", "_segmentCost", "_segmentCostArray", "_costArray", "_segmentArray"];

while {_continue} do {

	// Fetch the node with the lowest cost ( = first in the queue)
	if (_nodeQueue isEqualTo []) then {
		_curKnot = objNull;
	} else {
		_curEntry = _nodeQueue deleteAt 0;
		_curKnot  = _curEntry param [1, objNull];
	};

	// Only continue if there is a knot to check
	if (!isNull _curKnot) then {
		_isKnot     = _curKnot getVariable [QGVAR(isKnot), true];
		_curCost    = _curEntry param [0, _const_maxCost];
		_curKnotStr = str (_curKnot getVariable [QGVAR(nodeID), -1]);
		_namespace_unvisited setVariable [_curKnotStr, false];
		//diag_log format ["Checking node %1 (cost: %2)", _curKnotStr, _curCost];

		// Only continue if this node's current cost is less than our max cost
		if (_curCost < _maxCost) then {

			// If the current knot leads to the destination, compare it to the previous end node
			if (_namespace_isEndNode getVariable [_curKnotStr, false]) then {
				//diag_log format ["  Node %1 is an end node (cost: %2)", _curKnotStr, _curCost];

				// If this knot directly connects to the destination, fetch that cost
				_newCost = _namespace_endNodesCost getVariable [_curKnotStr, -1];
				if (_newCost >= 0) then {
					_newCost = _newCost + _curCost;

					// If this knot has a lower cost to the destination than the previous maximum, set it as the new end node
					if (_newCost < _maxCost) then {
						//diag_log format ["  Saving new end cost (%1 (knot): %2) - previous: %3", _curKnotStr, _newCost, _maxCost];
						_maxCost     = _newCost;
						_bestEndNode = _curKnot;
/*					} else {
						diag_log format ["    Found end (%1 (knot): %2), but cost is higher than max: %3 - ignoring...", _curKnotStr, _newCost, _maxCost];
*/					};
				};

				// If there are segment nodes that connect to the destination, handle them too
				//diag_log format ["  Checking knot %1's end nodes: %2", _curKnotStr, (_namespace_endNodes getVariable [_curKnotStr, []]) apply {_x getVariable [QGVAR(nodeID), -1]}];
				{
					_nodeX = _x;
					_nodeStrX = str (_nodeX getVariable [QGVAR(nodeID), -1]);
					_newCost = _curCost + (_curKnot getVariable [format [_varName_cost, _nodeStrX], 0]) + (_namespace_endNodesCost getVariable [_nodeStrX, 0]);
					_lastNode = _curKnot;

					// Add the danger level of the segment to the new cost
					{
						_newCost = _newCost + (_lastNode getVariable [format [QGVAR(dangerLevel_%1), _x getVariable [QGVAR(nodeID), -1]], 0]);
					} forEach (_curKnot getVariable [format [_varName_segmentsX, _nodeStrX], []]);

					// If this node has a lower cost to the destination than the previous maximum, set it as the new end node
					if (_newCost < _maxCost) then {
						//diag_log format ["    Saving new end cost (%1: %2) - previous: %3", _nodeStrX, _newCost, _maxCost];
						_maxCost = _newCost;
						_bestEndNode = _nodeX;
						_namespace_precedents setVariable [_nodeStrX, _curKnot];
/*					} else {
						diag_log format ["    Found end (%1: %2), but cost is higher than max: %3 - ignoring...", _nodeStrX, _newCost, _maxCost];
*/					};
				} forEach (_namespace_endNodes getVariable [_curKnotStr, []]);
			};

			_connectedNodesToCheck = _curKnot getVariable [_varName_knots, []];
			//diag_log format ["  Neighbouring knots: %1", _connectedNodesToCheck];

			// The next line might seem odd, considering we're only checking knots in this big loop. But we're [k]not. (heh.)
			// The starting nodes can be segment nodes, and if this an end node is on the same segment, our logic will ignore the direct path
			// between the two, and instead opt to first move to one of the neighbouring knots, before backtracking to the end node. Not ideal.
			// To fix this, we add special behaviour for first nodes, instructing the loop to also check all segment nodes (just this once).
			if (!_isKnot) then {
				private _segmentNodes = (
					((_curKnot getVariable [QGVAR(connections), []]) select {_namespace_unvisited getVariable [str _x, true]})
					- (_curKnot getVariable [_varName_knots, []])
				);

				_connectedNodesToCheck = +_connectedNodesToCheck;
				{
					_connectedNodesToCheck pushBackUnique _x;
				} forEach _segmentNodes;
				//diag_log format ["  Not a knot - appending unvisited segment nodes: %1", _segmentNodes];
			};

			// Iterate through this node's neighbour knots
			{
				_knotStrX = str _x;

				// If this node hasn't been visited yet, process it
				if (_namespace_unvisited getVariable [_knotStrX, true]) then {

					_segmentArray = _curKnot getVariable [format [_varName_segmentsX, _knotStrX], []];
					_oldCost = _namespace_costs getVariable [_knotStrX, _const_maxCost];

					// If this node can only be reached via one segment (determined by checking whether the segment array
					// only holds nodes (or is empty)), we only need to consider those segment nodes
					if (_segmentArray param [0, objNull] isEqualType objNull) then {
						_newCost = _curCost + (_curKnot getVariable [format [_varName_cost, _knotStrX], 0]);
						_lastNode = _curKnot;

						// Add the danger level of every node on this segment
						{
							_newCost = _newCost + (_lastNode getVariable [format [QGVAR(dangerLevel_%1), _x getVariable [QGVAR(nodeID), -1]], 0]);
							_lastNode = _x;
						} forEach (_curKnot getVariable [format [_varName_segmentsX, _knotStrX], []]);

						// Also consider the last node (the end knot)
						_newCost = _newCost + (_curKnot getVariable [format [QGVAR(dangerLevel_%1), _knotStrX], 0]);

					// Otherwise, we need to consider all segments leading to this node
					} else {
						_costArray = _curKnot getVariable [format [_varName_costArray, _knotStrX], []];
						_segmentCostArray = [];

						// Iterate through all segments
						{
							_segmentCost = _curCost + (_costArray # _forEachIndex);
							_lastNode = _curKnot;

							// Add the danger level of every node on this segment
							{
								_segmentCost = _segmentCost + (_lastNode getVariable [format [QGVAR(dangerLevel_%1), _x getVariable [QGVAR(nodeID), -1]], 0]);
								_lastNode = _x;
							} forEach _x;
							_segmentCost = _segmentCost + (_lastNode getVariable [format [QGVAR(dangerLevel_%1), _knotStrX], 0]);

							_segmentCostArray pushBack [_segmentCost, _forEachIndex];
						} forEach _segmentArray;

						// Sort all segments by order of increasing cost
						_segmentCostArray sort true;

						// Pick the segment with the lowest cost
						_newCost = _segmentCostArray # 0 # 0;
						_namespace_segmentIndex setVariable [format ["%1_%2", _curKnotStr, _knotStrX], _segmentCostArray # 0 # 1];
					};

					// If the new cost is lower, update the node's precedent
					if (_newCost < _oldCost) then {
						//diag_log format ["  Saving new cost (%1 -> %2: %3) - previous (old): %4", _curKnotStr, _knotStrX, _newCost, _oldCost];
						_namespace_costs setVariable [_knotStrX, _newCost];
						_namespace_precedents setVariable [_knotStrX, _curKnot];
					};

					// Add the new node to the queue
					if (_namespace_undiscovered getVariable [_knotStrX, true]) then {
						_namespace_undiscovered setVariable [_knotStrX, false];
						_nodeQueue pushBack [_oldCost min _newCost, _allNodes # _x];
					};
				};
			} forEach _connectedNodesToCheck;

			// Sort the (new) priority queue
			_nodeQueue sort true;

		// DEBUG
		} else {
			//diag_log format ["Ignoring - candidate is too expensive! (max: %1)", _maxCost];
			_nodeQueue = [];
		};

	// Otherwise, the queue is empty - let's wrap up
	} else {
		_continue = false;

		// If we have an end node, compile our path
		if (alive _bestEndNode) then {
			_lastNode = _bestEndNode;
			_curKnot = _namespace_precedents getVariable [str (_bestEndNode getVariable [QGVAR(nodeID), -1]), objNull];
			_result pushBack _bestEndNode;

			//diag_log "Compiling path in reverse";

			while {alive _curKnot} do {
				_curKnotStr = str (_curKnot getVariable [QGVAR(nodeID), -1]);
				_lastNodeStr = str (_lastNode getVariable [QGVAR(nodeID), -1]);
				//diag_log format ["  At node %1...", _curKnotStr];

				// Fetch this node's segment and segment index
				_segment = _curKnot getVariable [format [_varName_segmentsX, _lastNodeStr], []];
				_segmentIndex = _namespace_segmentIndex getVariable [format ["%1_%2", _curKnotStr, _lastNodeStr], -1];

				// Add the segment nodes between the two knots (if there are any)
				if (_segmentIndex >= 0 or {!(_segment isEqualTo [])}) then {
					//diag_log format ["Appending (%1 -> %2):   %3", _curKnotStr, _lastNodeStr, _segment apply {_x getVariable [QGVAR(nodeID), -1]}];

					// If there are multiple segments; we need to pick the right one
					if (_segmentIndex >= 0) then {
						_segment = _segment # _segmentIndex;
					};

					// Reverse the segment so the nodes are in the correct order, then append it to the results
					_segment = +_segment;
					reverse _segment;
					_result append _segment;
				};

				_result pushBack _curKnot;
				_lastNode = _curKnot;
				_curKnot = _namespace_precedents getVariable [_curKnotStr, objNull];
			};
			reverse _result;
			//systemChat format ["Found a path! (%1s) Cost: %2 - Nodes: %3", diag_tickTime - _timeStart, _maxCost, _result apply {_x getVariable [QGVAR(nodeID), -1]}];
			//diag_log format ["Found a path! (%1s) Cost: %2 - Nodes: %3", diag_tickTime - _timeStart, _maxCost, _result apply {_x getVariable [QGVAR(nodeID), -1]}];
/*
		// Otherwise, terminate
		} else {
			systemChat "ERROR: Couldn't find a path! Exiting...";
			diag_log "ERROR: Couldn't find a path! Exiting...";
*/		};
	};
};





// --------------------------------------------------------- STAGE 3 / 5 ---------------------------------------------------------
// Check if the head and tail of the path can be optimised
private _indexLast = count _result - 1;
private _newHeadIndex = 0;
private _newTailIndex = _indexLast;
private ["_checkOcclusion", "_curNodePos", "_nextNodePos", "_nextNodeX", "_nextNodeStrX", "_canSkipNode"];

for "_i" from 0 to _indexLast do {
	_nodeX      = _result # _i;
	_curNodePos = getPosWorld _nodeX;

	if (_i >= _indexLast) then {
		_checkOcclusion = true;
		_nextNodePos    = _destination;
	} else {
		_checkOcclusion = false;
		_nextNodeX      = _result # (_i + 1);
		_nextNodeStrX   = str (_nextNodeX getVariable [QGVAR(nodeID), -1]);

		// Ensure we only test start nodes
		if !(_namespace_isStartNode getVariable [_nextNodeStrX, false]) then {
			breakTo QGVAR(findPath_main);
		};

		_nextNodePos = getPosWorld _nextNodeX;
	};

	// Skip head nodes that require a >90° turn, provided the origin can also reach the next node
	_canSkipNode = (
		([_origin, _curNodePos, _curNodePos, _nextNodePos] call FUNC(math_dot2D)) < 0
		and {
			!_checkOcclusion
			or {_origin distanceSqr _nextNodePos > _nodeSearchRadius ^ 2}
			or {[_origin, _nextNodePos, _startOccluders, _occluderClass] call FUNC(nm_checkOcclusion)}
		}
	);

	// Abort head optimisation on the first unsuccessful result (no point in checking any further)
	if (!_canSkipNode) then {
		breakTo QGVAR(findPath_main);
	};

	_newHeadIndex = _i + 1;
};

if (_newHeadIndex < _indexLast) then {
	private ["_prevNodePos", "_prevNodeX", "_prevNodeStrX"];

	for "_i" from _indexLast to _newHeadIndex step -1 do {
		_nodeX      = _result # _i;
		_curNodePos = getPosWorld _nodeX;

		if (_i <= 0) then {
			_checkOcclusion = true;
			_prevNodePos    = _origin;
		} else {
			_checkOcclusion = false;
			_prevNodeX      = _result # (_i - 1);
			_prevNodeStrX   = str (_prevNodeX getVariable [QGVAR(nodeID), -1]);

			// Ensure we only test end nodes
			if !(_namespace_isEndNode getVariable [_prevNodeStrX, false]) then {
				breakTo QGVAR(findPath_main);
			};

			_prevNodePos = getPosWorld _prevNodeX;
		};

		// Skip tail nodes that require a >90° turn, provided the previous node can also reach the destination
		_canSkipNode = (
			([_prevNodePos, _curNodePos, _curNodePos, _destination] call FUNC(math_dot2D)) < 0
			and {
				!_checkOcclusion
				or {_destination distanceSqr _prevNodePos > _nodeSearchRadius ^ 2}
				or {[_destination, _prevNodePos, _endOccluders, _occluderClass] call FUNC(nm_checkOcclusion)}
			}
		);

		// Abort tail optimisation on the first unsuccessful result (no point in checking any further)
		if (!_canSkipNode) then {
			breakTo QGVAR(findPath_main);
		};

		_newTailIndex = _i - 1;
	};
};

if (_newHeadIndex > 0 or {_newTailIndex < _indexLast}) then {
	_result = _result select [_newHeadIndex, _newTailIndex + 1 - _newHeadIndex];
/*
	if (_newHeadIndex > 0) then {
		systemchat format ["Optimised away %1 head node(s)", _newHeadIndex];
	};

	if (_newTailIndex < _indexLast) then {
		systemchat format ["Optimised away %1 tail node(s)", _indexLast - _newTailIndex];
	};
*/
};





// --------------------------------------------------------- STAGE 4 / 5 ---------------------------------------------------------
// Cleanup: remove all temporary namespaces
{
	deleteLocation _x;
} forEach [
	_namespace_costs,
	_namespace_undiscovered,
	_namespace_unvisited,
	_namespace_precedents,
	_namespace_segmentIndex,
	_namespace_isStartNode,
	_namespace_isEndNode,
	_namespace_endNodes,
	_namespace_endNodesCost
];





// --------------------------------------------------------- STAGE 5 / 5 ---------------------------------------------------------
// Compile and return the resulting path (in format [positions, radii, nodes])

#ifdef MACRO_DEBUG_NM_PATH
	{
		_x setObjectTexture [0, "#(argb,8,8,3)color(1,1,0,1,ca)"];
	} forEach _result;

	GVAR(nm_nodesPainted) = _result;
	//GVAR(curatorModule) addCuratorEditableObjects [GVAR(nm_nodesPainted), false];

	private _debug_resultData = ([_origin] + (_result apply {getPosWorld _x}) + [_destination]) apply {_x vectorAdd [0, 0, 0.5]};
	for "_i" from 0 to count _debug_resultData - 2 do {
		GVAR(debug_drawData_nm_findPath) pushBack [
			_debug_resultData # _i,
			_debug_resultData # (_i + 1),
			[1,1,0,1]
		];
	};
#endif

// Process the nodes into a path
_result = [
	[_origin] + (_result apply {[getPosWorld _x, _x getVariable [QGVAR(radiusVariance), 0], 2] call FUNC(math_randomPosOnCircle)}),
	[_defaultRadius] + (_result apply {_x getVariable [QGVAR(radius), 0]}),
	[objNull] + _result
];

// Optionally, if the destination is inside of the combat area, include it in the resulting path
if (_isDestinationInCA) then {
	(_result # 0) pushBack _destination;
	(_result # 1) pushBack _defaultRadius;
	(_result # 2) pushBack objNull;
};

// Check if the radii should be squared
if (_outputRadiiSquared) then {
	_result set [1, (_result # 1) apply {_x ^ 2}];
};

_result;
