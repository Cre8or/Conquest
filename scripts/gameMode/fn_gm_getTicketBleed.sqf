/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Returns the amount of ticket bleed the specified side is currently experiencing. The returned value is
		expressed in tickets per minute.

		Slow ticket bleed occurs when a side's captured sectors count is less than MACRO_TICKETBLEED_SECTORRATIOTHRESHOLD
		percent of the side with the highest captured sectors count.
		Fast ticket bleed occurs when a side has no captured sectors.
	Arguments:
		0:	<SIDE>		The side in question
	Returns:
			<NUMBER>	The amount of ticket bleed this side is experiencing
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_side", sideEmpty, [sideEmpty]]
];





// Fetch and return the side's ticket bleed
switch (_side) do {
	case east:       {GVAR(ticketBleedEast)};
	case resistance: {GVAR(ticketBleedResistance)};
	case west:       {GVAR(ticketBleedWest)};
	default          {0};
};
