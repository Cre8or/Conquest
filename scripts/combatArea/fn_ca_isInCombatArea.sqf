/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Returns true if the provided position is inside the specified side's combat area, otherwise false.
	Arguments:
		0:	<ARRAY>		The position to test
		1:	<SIDE>		The side whose combat area will be used
	Returns:
			<BOOLEAN>	Whether the position is within the side's combat area
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_pos", [], [[]]],
	["_side", sideEmpty, [sideEmpty]]
];

if (_pos isEqualTo [] or {_side == sideEmpty}) exitWith {false};





private _combatArea = missionNamespace getVariable [format [QGVAR(CA_%1), _side], []];

// Ignore empty combat areas
if (_combatArea isEqualTo []) exitWith {false};

_pos inPolygon _combatArea;
