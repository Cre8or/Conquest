/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Returns true if the given side is currently playable (has tickets), otherwise false.
	Arguments:
		0:      <SIDE>		The side for which the name is needed
			OR:
		0:      <NUMBER>	The side index inside GVAR(sides)
	Returns:
			<BOOLEAN>	Whether or not the side is playable
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"

params [
	["_side", sideEmpty, [sideEmpty, 0]]
];





// Special case: side expressed as an array index
if (_side isEqualType 0) exitWith {
	switch (_side) do {
		case 0:		{GVAR(ticketsEast) > 0};
		case 1:		{GVAR(ticketsResistance) > 0};
		case 2:		{GVAR(ticketsWest) > 0};
		default		{false};
	};
};

switch (_side) do {
	case east:		{GVAR(ticketsEast) > 0};
	case resistance:	{GVAR(ticketsResistance) > 0};
	case west:		{GVAR(ticketsWest) > 0};
	default			{false};
};
