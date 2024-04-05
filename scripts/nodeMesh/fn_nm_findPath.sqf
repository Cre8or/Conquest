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
private _timeStart            = diag_tickTime; // DEBUG
private _const_maxCost        = 1e38;
private _side                 = side group _unit;
private _origin               = getPosWorld _unit;
private _originAGL            = ASLtoAGL _origin;
private _destinationAGL       = ASLtoAGL _destination;
private _isDestinationInCA    = [_destination, _side] call FUNC(ca_isInCombatArea);
private _allNodes             = [GVAR(nm_nodesInf), GVAR(nm_nodesVeh)] select _isVehicle;
private _defaultRadius        = [MACRO_NM_DEFAULTRADIUS_INF, MACRO_NM_DEFAULTRADIUS_VEH] select _isVehicle;
private _nodeClass            = [MACRO_CLASS_NODEMESH_NODE_INF, MACRO_CLASS_NODEMESH_NODE_VEH] select _isVehicle;
private _occluderClass        = [MACRO_CLASS_NODEMESH_OCCLUDER_INF, MACRO_CLASS_NODEMESH_OCCLUDER_VEH] select _isVehicle;
private _nodeSearchRadius     = [MACRO_NM_SEARCHRADIUS_NODES_INF, MACRO_NM_SEARCHRADIUS_NODES_VEH] select _isVehicle;
private _varName_costX        = [QGVAR(dist_%1), QGVAR(cost_%1)] select _isVehicle;
private _varName_costArrayX   = [format [QGVAR(distances_%1_%2), "%1", _side], format [QGVAR(costs_%1_%2), "%1", _side]] select _isVehicle;
private _varName_knots        = format [QGVAR(knots_%1), _side];
private _varName_usedBySide   = format [QGVAR(usedBy_%1), _side];
private _varName_segmentsX    = format [QGVAR(segments_%1_%2), "%1", _side];
private _varName_dangerLevelX = format [QGVAR(dangerLevel_%1_%2), "%1", _side];

// Set up some variables
private _result = [];
private _nodeQueue = [];
private _namespace_costs          = createLocation ["NameVillage", [0,0,0], 0, 0];
private _namespace_undiscovered   = createLocation ["NameVillage", [0,0,0], 0, 0];
private _namespace_unvisited      = createLocation ["NameVillage", [0,0,0], 0, 0];
private _namespace_precedents     = createLocation ["NameVillage", [0,0,0], 0, 0];
private _namespace_segmentIndex   = createLocation ["NameVillage", [0,0,0], 0, 0];
private _namespace_isStartNode    = createLocation ["NameVillage", [0,0,0], 0, 0];
private _namespace_isEndNode      = createLocation ["NameVillage", [0,0,0], 0, 0];
private _namespace_endNodes       = createLocation ["NameVillage", [0,0,0], 0, 0];
private _namespace_endNodesCost   = createLocation ["NameVillage", [0,0,0], 0, 0];
private _namespace_optFirstIndex  = createLocation ["NameVillage", [0,0,0], 0, 0]; // Keeps track of the first occurance of each entry in the results array
private _namespace_optSkipToIndex = createLocation ["NameVillage", [0,0,0], 0, 0]; // Stores the results array indexes to which the optimisation pass may jump when looping over a repeated node
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




// --------------------------------------------------- STAGE 1 / 6 ----------------------------------------------------
// Determine the start and end nodes, and see if a direct connection is possible at short distances
private ["_posX", "_nodeX", "_nodeStrX", "_cost"];
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

	[[_origin, _destination], [_completionRadius, _completionRadius], [objNull, objNull]];
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

					_cost = ([_origin, _posX, _isVehicle] call FUNC(nm_getRawCost)) * ([MACRO_NM_COSTMULTIPLIER_OFFMESH_INF, MACRO_NM_COSTMULTIPLIER_OFFMESH_VEH] select _isVehicle);

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

	_nodeX = _x;

	// Only continue if this node may be used by the unit's side
	if !(_nodeX getVariable [_varName_usedBySide, true]) then {
		continue;
	};

	// If the node isn't occluded, make it an end node
	_posX = getPosWorld _nodeX;
	if !([_posX, _destination, _endOccluders, _occluderClass] call FUNC(nm_checkOcclusion)) then {
		continue;
	};
	_endNodesCount = _endNodesCount + 1;

	_cost = ([_posX, _destination, _isVehicle] call FUNC(nm_getRawCost)) * ([MACRO_NM_COSTMULTIPLIER_OFFMESH_INF, MACRO_NM_COSTMULTIPLIER_OFFMESH_VEH] select _isVehicle);

	// Mark this node as an end node and save its cost
	_nodeStrX = str (_nodeX getVariable [QGVAR(nodeID), -1]);
	_namespace_isEndNode setVariable [_nodeStrX, true];
	_namespace_endNodesCost setVariable [_nodeStrX, _cost];
	//diag_log format ["End node cost (%1): %2", _nodeStrX, _cost];

	// If this node is a segment node, fetch its 2 end knots and make them end nodes aswell.
	// This way the next stage will be able to trace these knots back to the actual end node.
	if !(_nodeX getVariable [QGVAR(isKnot), false]) then {
		{
			_knotStrX = str _x;

			_namespace_isEndNode setVariable [_knotStrX, true];
			_namespace_endNodes setVariable [_knotStrX,
				(_namespace_endNodes getVariable [_knotStrX, []]) + [_nodeX]
			];

			// To prevent this knot from bypassing its own end node(s), we set its end cost to
			// the default maximum value.
			// Might seem odd, but this effectively makes the knot a bad end node candidate, but
			// still allows it to become one if it is a potential end node itself (and thus already
			// has an end cost defined for it). This will be useful later.
			_namespace_endNodesCost setVariable [_knotStrX,
				(_namespace_endNodesCost getVariable [_knotStrX, _const_maxCost])
			];
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




// --------------------------------------------------- STAGE 2 / 6 ----------------------------------------------------
// Find a path between the start and end nodes
private ["_curKnot", "_curEntry", "_curCost", "_curKnotStr", "_segmentCost", "_lastNode", "_lastNodeStr", "_segment", "_segmentIndex", "_oldCost", "_newCost", "_nodeIndex"];

while {true} do {

	// Fetch the knot with the lowest cost ( = first in the queue)
	if (_nodeQueue isEqualTo []) then {
		_curKnot = objNull;
	} else {
		_curEntry = _nodeQueue deleteAt 0;
		_curKnot  = _curEntry param [1, objNull];
	};

	// Only continue if there is a knot to check
	if (isNull _curKnot) then {
		breakTo QGVAR(findPath_main);
	};

	_curCost    = _curEntry param [0, _const_maxCost];
	_curKnotStr = str (_curKnot getVariable [QGVAR(nodeID), -1]);
	_namespace_unvisited setVariable [_curKnotStr, false];
	//diag_log format ["Checking knot %1 (cost: %2)", _curKnotStr, _curCost];

	// Abort early if this knot's cost exceeds the highest determined cost
	if (_curCost >= _maxCost) then {
		//diag_log format ["Ending search - candidate knot is too expensive (max: %1)", _maxCost];
		_nodeQueue = []; // Also clear the queue, as any subsequent entries will be even more expensive than this one
		continue;
	};

	// If this knot leads to the destination, compare it to the current best end node
	if (_namespace_isEndNode getVariable [_curKnotStr, false]) then {
		//diag_log format ["  Knot %1 leads to the end", _curKnotStr];

		// Let the knot's end nodes have the first go at being the best candidate
		private _endNodes = _namespace_endNodes getVariable [_curKnotStr, []];
		{
			_nodeX       = _x;
			_nodeStrX    = str (_nodeX getVariable [QGVAR(nodeID), -1]);
			_segmentCost = [_curKnot, _nodeX, _varName_costX, _varName_segmentsX, _varName_dangerLevelX, _varName_costArrayX] call FUNC(nm_getBestSegmentCost);
			_newCost     = (_segmentCost # 0) + (_namespace_endNodesCost getVariable [_nodeStrX, 0]) + _curCost;

			// If this node has a lower cost to the destination than the previous maximum, set it as the new end node
			if (_newCost < _maxCost) then {
				//diag_log format ["    Knot %1's end node %2 is new best end node (%3 < %4)", _curKnotStr, _nodeStrX, _newCost, _maxCost];
				_maxCost     = _newCost;
				_bestEndNode = _nodeX;

				_namespace_precedents setVariable [_nodeStrX, _curKnot];
				_namespace_segmentIndex setVariable [format ["%1_%2", _curKnotStr, _nodeStrX], _segmentCost # 1];
/*			} else {
				diag_log format ["    Knot %1's end node %2 costs more (%3 > %4), ignoring...", _curKnotStr, _nodeStrX, _newCost, _maxCost];
*/			};
		} forEach _endNodes;

		// Only after checking the knot's end nodes (if it has any), we check the knot itself as a candidate.
		// Generally, knots lead to an end node via a segment (or part thereof) that they're connected to. However,
		// sometimes the knot itself is a candidate end node, so we can't just ignore it.
		// This is why we give the knot's end nodes "dibs" on this check, and afterwards check the knot.
		//
		// The reason this works (the knot does not have an end cost precalculated; only segment nodes do), is because
		// when determining end nodes (stage #2), we defaulted the knot's cost to the maximum value.
		_newCost = (_namespace_endNodesCost getVariable [_curKnotStr, 0]) + _curCost;

		if (_newCost < _maxCost) then {
			//diag_log format ["    Knot %1 is new best end node (%2 < %3)", _curKnotStr, _newCost, _maxCost];
			_maxCost     = _newCost;
			_bestEndNode = _curKnot;
/*		} else {
			diag_log format ["    Knot %1 costs more (%2 > %3), ignoring...", _curKnotStr, _newCost, _maxCost];
*/		};
	};

	//diag_log format ["  Neighbouring knots: %1", _curKnot getVariable [_varName_knots, []]];

	// Iterate through this node's neighbour knots
	{
		_nodeStrX = str _x;

		// Only check this knot if it hasn't been visited yet
		if !(_namespace_unvisited getVariable [_nodeStrX, true]) then {
			//diag_log format ["    Skipping neighbour %1 (already visited)", _x];
			continue;
		};

		_oldCost = _namespace_costs getVariable [_nodeStrX, _const_maxCost];

		_nodeX       = _allNodes # _x;
		_segmentCost = [_curKnot, _nodeX, _varName_costX, _varName_segmentsX, _varName_dangerLevelX, _varName_costArrayX] call FUNC(nm_getBestSegmentCost);
		_newCost     = (_segmentCost # 0) + _curCost;

		// If the new cost is lower, update the node's precedent
		if (_newCost < _oldCost) then {
			//diag_log format ["    Saving new cost (%1 -> %2: %3) - previous: %4", _curKnotStr, _nodeStrX, _newCost, _oldCost];
			_namespace_costs setVariable [_nodeStrX, _newCost];
			_namespace_precedents setVariable [_nodeStrX, _curKnot];
			_namespace_segmentIndex setVariable [format ["%1_%2", _curKnotStr, _nodeStrX], _segmentCost # 1];
/*		} else {
			diag_log format ["    Neighbour knot %1 costs more (%2 > %3) - ignoring...", _x, _newCost, _oldCost];
*/		};

		// Add the new node to the queue
		// Generally we only do this for nodes that are undiscovered, but if a lower cost is found to a previously
		// disovered neighbour, we'll want to update its value in the queue (so it evaluated sooner).
		if (_namespace_undiscovered getVariable [_nodeStrX, true]) then {
			_namespace_undiscovered setVariable [_nodeStrX, false];
			_nodeQueue pushBack [_newCost, _nodeX];
			//diag_log format ["    Adding neighbour knot %1 to the queue (cost: %2 / %3)", _x, _newCost, _oldCost];
		} else {
			if (_newCost < _oldCost) then {
				_nodeIndex = _nodeQueue findIf {_x # 1 == _nodeX};

				if (_nodeIndex >= 0) then {
					//diag_log format ["    Updating queued neighbour knot %1's cost (%2) - previous: %3", _x, _newCost, _oldCost];
					_nodeQueue set [_nodeIndex, [_newCost, _nodeX]];
				};
			};
		};
	} forEach (_curKnot getVariable [_varName_knots, []]);

	// Sort the (new) priority queue
	_nodeQueue sort true;
};

// If we finished searching and failed to reach an end node, it means no path could be found
if (isNull _bestEndNode) exitWith {
	//systemChat "ERROR: Couldn't find a path! Exiting...";
	//diag_log "ERROR: Couldn't find a path! Exiting...";
	[[],[],[]]
};

_lastNode = _bestEndNode;
_curKnot  = _namespace_precedents getVariable [str (_bestEndNode getVariable [QGVAR(nodeID), -1]), objNull];
_result pushBack _bestEndNode;

//diag_log format ["Reversing path (starting at %1)", _bestEndNode getVariable [QGVAR(nodeID), -1]];
while {alive _curKnot} do {
	_curKnotStr = str (_curKnot getVariable [QGVAR(nodeID), -1]);
	_lastNodeStr = str (_lastNode getVariable [QGVAR(nodeID), -1]);
	//diag_log format ["  At node %1...", _curKnotStr];

	// Fetch this node's segment and segment index
	_segment = _curKnot getVariable [format [_varName_segmentsX, _lastNodeStr], []];
	_segmentIndex = _namespace_segmentIndex getVariable [format ["%1_%2", _curKnotStr, _lastNodeStr], -1];

	// Add the segment nodes between the two knots (if there are any)
	if (_segmentIndex >= 0 or {!(_segment isEqualTo [])}) then {

		// If there are multiple segments; we need to pick the right one
		if (_segmentIndex >= 0) then {
			_segment = _segment # _segmentIndex;
		};
		//diag_log format ["    Appending segment #%1 (%2 -> %3): %4", _segmentIndex, _curKnotStr, _lastNodeStr, _segment apply {_x getVariable [QGVAR(nodeID), -1]}];

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
//diag_log format ["Preliminary path (%1): %2", _maxCost, _result apply {_x getVariable [QGVAR(nodeID), -1]}];





// --------------------------------------------------- STAGE 3 / 6 ----------------------------------------------------
// Cut out any loops in the results array (segments that fold back onto the same node).
// This can happen when the start and end node are on the same segment. Usually, one of the knots of that segment ends
// up in the result array, which is often unnecessary (since knots are the last nodes of a segment).
private _shouldRebuildResult = false;
private ["_prevIndex"];
{
	_nodeStrX  = str (_x getVariable [QGVAR(nodeID), -1]);
	_prevIndex = _namespace_optFirstIndex getVariable [_nodeStrX, -1];

	if (_prevIndex < 0) then {
		_namespace_optFirstIndex setVariable [_nodeStrX, _forEachIndex];
		continue;
	};

	// A repetition was found; link the first occurence to the current index
	_shouldRebuildResult = true;
	_namespace_optSkipToIndex setVariable [_nodeStrX, _forEachIndex];
} forEach _result;

// If at least one repetition was found, the result array needs to be rebuilt
if (_shouldRebuildResult) then {
	private _index     = 0;
	private _indexLast = count _result - 1;
	private _resultCopy = [];

	while {_index <= _indexLast} do {
		_nodeX    = _result # _index;
		_nodeStrX = str (_nodeX getVariable [QGVAR(nodeID), -1]);

		_resultCopy pushBack _nodeX;
		_index = (_index max (_namespace_optSkipToIndex getVariable [_nodeStrX, 0])) + 1;
	};

	_result = _resultCopy;
	//diag_log format ["Removed redundant loops - new path: %1", _result apply {_x getVariable [QGVAR(nodeID), -1]}];
};





// --------------------------------------------------- STAGE 4 / 6 ----------------------------------------------------
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
		diag_log format ["  Optimised away %1 head node(s)", _newHeadIndex];
	};

	if (_newTailIndex < _indexLast) then {
		diag_log format ["  Optimised away %1 tail node(s)", _indexLast - _newTailIndex];
	};
*/
};
//diag_log format ["Found a path! (%1 ms) Cost: %2 - Nodes: %3", (diag_tickTime - _timeStart) * 1000, _maxCost, _result apply {_x getVariable [QGVAR(nodeID), -1]}];





// --------------------------------------------------- STAGE 5 / 6 ----------------------------------------------------
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
	_namespace_endNodesCost,
	_namespace_optFirstIndex,
	_namespace_optSkipToIndex
];





// --------------------------------------------------- STAGE 6 / 6 ----------------------------------------------------
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
