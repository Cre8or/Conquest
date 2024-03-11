/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Sets up a specific node of the nodemesh with the given data.

		Only used internally by nm_setupNodeMesh.
	Arguments:
		0:	<OBJECT>	The node to set up
		1:	<ARRAY>		The node's data
		2:	<NUMBER>	The node's ID
		3:	<BOOLEAN>	The nodemesh selector (true = vehicles, false = infantry)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

// No parameter validation, as this is an internal function
params ["_node", "_curNodeData", "_nodeID", "_isVehNode"];





// Set up some constants
private _c_allSides = [east, resistance, west]; // The order must match that of the array below!
private _c_allFlags = [MACRO_NM_BITFLAG_SIDE_EAST, MACRO_NM_BITFLAG_SIDE_RESISTANCE, MACRO_NM_BITFLAG_SIDE_WEST];

// Read the node data
private _connections = [];
private ["_nodeX", "_allSegmentArrays", "_connectionDataX", "_allCostArrays", "_allDistArrays", "_segment"];

// Save the node's variables onto it
_node setVariable [QGVAR(nodeID), _nodeID];
_node setVariable [QGVAR(knots), _curNodeData # 1]; // 1

{
	_nodeX = _x # 0; // 3.0
	_allSegmentArrays = [[], [], []];

	// Check the format of the second element
	// If it's an array, we deduce that there are multiple connections leading to this node
	_connectionDataX = _x # 1;
	if (_connectionDataX isEqualType []) then {
		_allCostArrays = [[], [], []];
		_allDistArrays = [[], [], []];

		// Iterate over all connections to this node
		// Index starts at 1 because #0 designates the node to which the subsequent segments lead.
		// This is intentional!
		for "_i" from 1 to (count _x) - 1 do {
			(_x # _i) params ["_costX", "_distX", ["_segmentX", []], ["_segmentFlag", 0]];

			// If we have a segment flag, decompose it
			if (_segmentFlag > 0) then {
				{
					// If this side is not excluded from this segment, save the data to its arrays
					if (!_x) then {
						(_allCostArrays # _forEachIndex) pushBack _costX;
						(_allDistArrays # _forEachIndex) pushBack _distX;
						(_allSegmentArrays # _forEachIndex) pushBack _segmentX;
					};
				} forEach ([_segmentFlag, _c_allFlags] call FUNC(math_parseBitFlag));

			// Otherwise, allow every side to use this segment
			} else {
				{_x pushback _costX} forEach _allCostArrays;
				{_x pushback _distX} forEach _allDistArrays;
				{_x pushback _segmentX} forEach _allSegmentArrays;
			};
		};

		// Save the cost arrays onto this node
		{
			_node setVariable [format [QGVAR(costs_%1_%2), _nodeX, _c_allSides # _forEachIndex],
				_x, // 3.1
			false];
		} forEach _allCostArrays;

		// Save the distance arrays onto this node
		{
			_node setVariable [format [QGVAR(distances_%1_%2), _nodeX, _c_allSides # _forEachIndex],
				_x, // 3.2
			false];
		} forEach _allCostArrays;

		// Save the segment arrays onto the node
		{
			// If this segments array contains more than one segment, save it as-is
			if (count _x > 1) then {
				_node setVariable [format [QGVAR(segments_%1_%2), _nodeX, _c_allSides # _forEachIndex],
					_x, // 3.3
				false];

			// Otherwise, only save its contents (if there are any)
			} else {
				_node setVariable [format [QGVAR(segments_%1_%2), _nodeX, _c_allSides # _forEachIndex],
					_x param [0, []], // 3.3
				false];
			};
		} forEach _allSegmentArrays;

	// Otherwise, there is only one connection to this node
	} else {
		_node setVariable [format [QGVAR(cost_%1), _nodeX], _x # 1, false]; // 3.1
		_node setVariable [format [QGVAR(dist_%1), _nodeX], _x # 2, false]; // 3.2

		_segment = _x param [3, []];
		if !(_segment isEqualTo []) then {
			{
				_node setVariable [format [QGVAR(segments_%1_%2), _nodeX, _x],
					_segment, // 3.3
				false];
			} forEach _c_allSides;
		};
	};

	_connections pushBack _nodeX;
} forEach (_curNodeData # 3); // 3


_node setVariable [QGVAR(neighbours), _curNodeData param [2, 0], false]; // 2
_node setVariable [QGVAR(radius), _curNodeData param [4, [MACRO_NM_DEFAULTRADIUS_INF, MACRO_NM_DEFAULTRADIUS_VEH] select _isVehNode], false]; // 4
_node setVariable [QGVAR(isKnot), (_curNodeData param [5, 0]) > 0, false]; // 5
_node setVariable [QGVAR(isVehNode), _isVehNode, false];
_node setVariable [QGVAR(radiusVariance), _curNodeData param [6, 0], false]; // 6
_node setVariable [QGVAR(connections), _connections, false];

// Handle the sides flag
private _sidesFlag = _curNodeData param [7, 0]; // 7
if (_sidesFlag != 0) then {

	// Iterate over the bit flags
	{
		_node setVariable [format [QGVAR(usedBy_%1), _c_allSides # _forEachIndex], !_x, false];
	} forEach ([_sidesFlag, _allFlags] call FUNC(math_parseBitFlag));
};





#ifdef MACRO_DEBUG_NM_NODES_INF
	if (!_isVehNode) then {
		private _texture = ([
			"#(argb,8,8,3)color(0,0.25,1,0.02,ca)",
			"#(argb,8,8,3)color(0,1,0,0.02,ca)"
		] select ((_curNodeData param [5, 0]) > 0)); // 5

		_node setVariable ["nodeTexture", _texture];
		_node setObjectTexture [0, _texture];
		_node setObjectScale ((_curNodeData # 4) * 2); // Infantry nodes currently use a 200cm diameter sphere
	};
#endif

#ifdef MACRO_DEBUG_NM_NODES_VEH
	if (_isVehNode) then {
		private _texture = ([
			"#(argb,8,8,3)color(0,0.25,1,0.02,ca)",
			"#(argb,8,8,3)color(0,1,0,0.02,ca)"
		] select ((_curNodeData param [5, 0]) > 0)); // 5

		_node setVariable ["nodeTexture", _texture];
		_node setObjectTexture [0, _texture];
		_node setObjectScale (_curNodeData # 4);
	};
#endif
