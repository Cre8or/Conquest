/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Returns the tickets count of the given side.
	Arguments:
		0:      <SIDE>		The side in question
	Returns:
			<NUMBER>	The amount of tickets this side has left
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_side", sideEmpty, [sideEmpty]]
];





// Fetch and return the side's tickets
switch (_side) do {
	case east:       {GVAR(ticketsEast)};
	case resistance: {GVAR(ticketsResistance)};
	case west:       {GVAR(ticketsWest)};
	default          {0};
};
