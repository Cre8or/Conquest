/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LA]
		Returns the travel cost from one node to another. Considers the precompiled node-to-node cost, aswell
		as the edges' current danger level. Intended for internal use by nm_findPath only.

		NOTE: The two passed nodes must either be connected knots, or nodes on a segment (without a knot between
		them).
	Arguments:
		0:      <OBJECT>	The origin node
		1:	<OBJECT>	The destination node
		2:	<STRING>	The side's segments variable name
	Returns:
		0:	<NUMBER>	The summed travel cost between the two nodes

-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_nodeFrom", objNull, [objNull]],
	["_nodeTo", objNull, [objNull]],
	["_varName_cost", "", [""]],
	["_varName_segments", "", [""]]
];

if (isNull _nodeFrom or {isNull _nodeTo}) exitWith {0};





private _nodeFromID = _nodeFrom getVariable [QGVAR(nodeID), -1];
private _nodeToID   = _nodeTo getVariable [QGVAR(nodeID), -1];

// Base cost
private _cost = _nodeFrom getVariable [format [_varName_cost, _nodeToID], 0];

// Add the danger level of every node on this segment
private _nodePrev = _nodeFrom;
private ["_nodeNext", "_nodeNextID"];
{
	_nodeNext   = _x;
	_nodeNextID = _nodeNext getVariable [QGVAR(nodeID), -1];

	_cost     = _cost + (_nodePrev getVariable [format [QGVAR(dangerLevel_%1), _nodeNextID], 0]);
	_nodePrev = _nodeNext;
} forEach (_nodeFrom getVariable [format [_varName_segments, _nodeToID], []]);

// Also consider the last node (not part of the segment array)
_cost = _cost + (_nodePrev getVariable [format [QGVAR(dangerLevel_%1), _nodeToID], 0]);





_cost;
