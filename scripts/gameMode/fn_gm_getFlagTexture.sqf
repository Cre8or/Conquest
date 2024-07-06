/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Returns the flag texture of a given side, as provided in the mission's settings file.
	Arguments:
		0:      <SIDE>		The side for which the flag texture is needed
	Returns:
			<STRING>	The filepath to the side's flag texture
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"

// Fetch our params
params [["_side", sideEmpty]];





// Fetch and return the side's flag texture
switch (_side) do {
	case east:		{MACRO_FLAG_TEXTURE_EAST};
	case resistance:	{MACRO_FLAG_TEXTURE_RESISTANCE};
	case west:		{MACRO_FLAG_TEXTURE_WEST};
	default			{"a3\data_f\Flags\flag_white_co.paa"};
};
