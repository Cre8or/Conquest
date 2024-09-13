/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Returns the name of a given side, as provided in the sides' data files.
		The function can either return the short or long version of the side's name.
	Arguments:
		0:      <SIDE>		The side for which the name is needed
		1:		<BOOLEAN>	True to return the long name, false to return the short name.
	Returns:
			<STRING>	The name of the side
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"

params [
	["_side", sideEmpty, [sideEmpty]],
	["_longName", false, [false]]
];





if (_longName) then {
	missionNamespace getVariable [format [QGVAR(longName_%1), _side], "UNKNOWN"];
} else {
	missionNamespace getVariable [format [QGVAR(shortName_%1), _side], "UNKNOWN"];
};
