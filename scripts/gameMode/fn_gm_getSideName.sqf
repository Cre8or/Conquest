/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Returns the name of a given side, as provided in the mission's settings file.
	Arguments:
		0:      <SIDE>		The side for which the name is needed
	Returns:
			<STRING>	The name of the side
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"

params [
	["_side", sideEmpty]
];





// Fetch and return the side's name
switch (_side) do {
	case east:		{MACRO_SIDE_NAME_EAST};
	case resistance:	{MACRO_SIDE_NAME_RESISTANCE};
	case west:		{MACRO_SIDE_NAME_WEST};
	default			{"UNKNOWN"};
};
