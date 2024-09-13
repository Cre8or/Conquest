/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Returns the flag texture of a given side, as provided in the mission's settings file.
	Arguments:
		0:	<SIDE>		The side for which the flag texture is needed
	Returns:
			<STRING>	The filepath to the side's flag texture
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"

params [
	["_side", sideEmpty, [sideEmpty]]
];





missionNamespace getVariable [format [QGVAR(flagTexture_%1), _side], MACRO_TEXTURE_FLAG_EMPTY];
