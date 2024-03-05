/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LA]
		Checks if any of the passed occluders are blocking the path between the given origin and destination.
	Arguments:
		0:      <ARRAY>		The origin (in format posWorld)
		1:	<ARRAY>		The destination (in format posWorld)
		2:	<ARRAY>		The candidate occluder objects to be considered
		3:	<STRING>	The classname of the occluders to use, used for caching
	Returns:
		0:	<BOOLEAN>	True if no occluders are blocking the path (the destination can be reached),
					otherwise false
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_origin", [], [[]]],
	["_destination", [], [[]]],
	["_candidateOccluders", [], [[]]],
	["_occluderClass", MACRO_CLASS_NODEMESH_OCCLUDER_VEH, [MACRO_CLASS_NODEMESH_OCCLUDER_VEH]]
];

// Set up some variables
private _result                 = true;
private _namespace_undiscovered = createLocation ["NameVillage", [0,0,0], 0, 0];
private ["_occluderStart", "_posStart", "_occluderEnd", "_posEnd"];

scopeName QGVAR(nm_checkOcclusion);





// Test the occluders
{
	_occluderStart = _x;
	_posStart      = getPosWorld _occluderStart;

	// Test its neighbours
	{
		_occluderEnd = _x;

		if (_namespace_undiscovered getVariable [str (_occludeEnd getVariable [QGVAR(nodeID), -1]), true]) then {
			_posEnd = getPosWorld _occluderEnd;

			if ([_origin, _destination, _posStart, _posEnd] call FUNC(math_lineIntersect2D)) then {
				_result = false;
				breakTo QGVAR(nm_checkOcclusion);
			};
		};

	} forEach (_occluderStart getVariable [QGVAR(neighbours), []]);

	// Mark the node as visited
	_namespace_undiscovered setVariable [str (_occluderStart getVariable [QGVAR(nodeID), -1]), false];

} forEach _candidateOccluders;

// Clean up
deleteLocation _namespace_undiscovered;

_result;
