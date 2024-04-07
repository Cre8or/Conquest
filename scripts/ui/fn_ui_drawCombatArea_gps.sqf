/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LE]
		Handles the drawing of the combat area on GPS-like map controls.
		This differs from the map function in that the area outside of the combat area is simply shaded in a
		flat, dark overlay mask.

		Called internally via the control's "Draw" EH.
	Arguments:
		0:	<CONTROL>	The map control to draw on
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

// No parameter validation, as this is an internal function
params ["_ctrlMap"];





// Loop through all combat area triangles
{
	// Fill - darken
	_ctrlMap drawTriangle [
		_x,
		[0.1,0,0,0.5],
		"#(rgb,1,1,1)color(1,1,1,1)"
	];

} forEach (missionNamespace getVariable [format [QGVAR(CA_%1_triangles), GVAR(side)], []]);

// Draw the combat area outline (if we have one)
private _combatArea = missionNamespace getVariable [format [QGVAR(CA_%1), GVAR(side)], []];
if !(_combatArea isEqualTo []) then {
	_ctrlMap drawPolygon [_combatArea, [1,0,0,1]];
};
