/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Returns the travel cost from one position to another. Used by the validateNodeMesh function, aswell
		as the findPath function (to determine the initial nodes).
	Arguments:
		0:      <ARRAY>		The origin ("from") position (in format posWorld)
		1:	<ARRAY>		The destination ("to") position (in format posWorld)
		2:	<BOOLEAN>	True if the calculation is for a vehicle, otherwise false
	Returns:
		0:	<NUMBER>	The travel cost from the provided origin to the destination

-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_origin", [], [[0,0,0]]],
	["_destination", [], [[0,0,0]]],
	["_isVehicle", false, [false]]
];





// Calculate and return the cost.
// If the destination is above the origin, the cost increases - if it is lower, the cost decreases.
// This makes it more expensive for units to move uphill, and cheaper to move downhill.
if (_isVehicle) exitWith {
	(_origin distance _destination) * (1 + (_origin vectorFromTo _destination) # 2);
};

// Simple distance-based check for infantry requests (altitude doesn't matter as much)
_origin distance _destination;
