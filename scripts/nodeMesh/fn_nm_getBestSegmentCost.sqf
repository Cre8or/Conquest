/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LA]
		Returns the travel cost from one node to another. Considers the precompiled node-to-node cost, aswell
		as the edges' current danger level. Intended for internal use by nm_findPath only.
		If more than one segment connects the two nodes, the index of the used segment is returned. Otherwise,
		the index will return -1.

		NOTE: The two passed nodes must either be connected knots, or nodes on a segment (without a knot between
		them).
	Arguments:
		0:      <OBJECT>	The origin node
		1:	<OBJECT>	The destination node
		2:	<STRING>	The side's cost variable name
		3:	<STRING>	The side's segments array variable name
		4:	<STRING>	The side's danger level variable name
		5:	<STRING>	The side's costs array variable name
	Returns:
		0:	<NUMBER>	The total travel cost between the two nodes
		1:	<NUMBER>	The ID of the used segment (optional, default: -1)

-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_nodeFrom", objNull, [objNull]],
	["_nodeTo", objNull, [objNull]],
	["_varName_costX", "", [""]],
	["_varName_segmentsX", "", [""]],
	["_varName_dangerLevelX", "", [""]],
	["_varName_costArrayX", "", [""]]
];

if (isNull _nodeFrom or {isNull _nodeTo}) exitWith {0};





// Set up some variables
private _nodeFromID   = _nodeFrom getVariable [QGVAR(nodeID), -1];
private _nodeToID     = _nodeTo getVariable [QGVAR(nodeID), -1];
private _segmentArray = _nodeFrom getVariable [format [_varName_segmentsX, _nodeToID], []];

// Early check: if the segment array is empty, the cost is simply the direct cost between the two nodes,
// plus the danger level on that edge.
// NOTE: Possible values inside the segment array are either:
// * nothing
// * 1 or more nodes
// * 1 or more arrays that contains 1 or more nodes
if (_segmentArray isEqualTo []) exitWith {
	private _cost = (_nodeFrom getVariable [format [_varName_costX, _nodeToID], 0])
		+ (_nodeFrom getVariable [format [_varName_dangerLevelX, _nodeToID], 0]);

	[_cost, -1];
};

private _nodePrev  = _nodeFrom;
private _segmentID = -1;
private ["_cost", "_nodeNext", "_nodeNextID"];

// Define some macros
#define MACRO_FNC_SUMDANGERLEVEL(SEGMENT) \
 \
	_nodePrev = _nodeFrom; \
	{ \
		_nodeNext   = _x; \
		_nodeNextID = _nodeNext getVariable [QGVAR(nodeID), -1]; \
	 \
		_cost     = _cost + (_nodePrev getVariable [format [_varName_dangerLevelX, _nodeNextID], 0]); \
		_nodePrev = _nodeNext; \
	} forEach SEGMENT





// If there is just one segment leading to the node (this is usually the case), sum up the danger level of each
// edge of the segment.
if (_segmentArray param [0, objNull] isEqualType objNull) then {
	private _segment = _segmentArray + [_nodeTo];
	_cost = _nodeFrom getVariable [format [_varName_costX, _nodeToID], 0];

	MACRO_FNC_SUMDANGERLEVEL(_segment);

//  If there are multiple segments leading to the node, we need to determine the best one
} else {
	private _costArray  = _nodeFrom getVariable [format [_varName_costArrayX, _nodeToID], []];
	private _lowestCost = 2^24;
	private "_segmentX";
	{
		_segmentX = _x + [_nodeTo];
		_cost = _costArray # _forEachIndex;

		MACRO_FNC_SUMDANGERLEVEL(_segmentX);

		if (_cost < _lowestCost) then {
			_lowestCost = _cost;
			_segmentID  = _forEachIndex;
		};
	} foreach _segmentArray;
};





[_cost, _segmentID];
