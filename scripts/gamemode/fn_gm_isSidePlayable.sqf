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





private _index = _side;
if (_side isEqualType sideEmpty) then {
	_index = GVAR(sides) find _side;
};

switch (_index) do {
	case 0:		{GVAR(ticketsEast) > 0};
	case 1:		{GVAR(ticketsResistance) > 0};
	case 2:		{GVAR(ticketsWest) > 0};
	default		{false};
};
