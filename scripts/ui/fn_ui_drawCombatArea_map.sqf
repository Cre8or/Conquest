/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LE]
		Handles the drawing of the combat area on full-screen map controls.
		This differs from the GPS function in that the area outside of the combat area is filled with
		red stripes.

		Called internally via the control's "Draw" EH.
	Arguments:
		0:	<CONTROL>	The map control to draw on
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

// No parameter validation, as this is an internal function
params ["_ctrlMap"];





// Set up some variables
private _texture = getMissionPath "res\images\stripes_32.paa";





// Loop through all combat area triangles
{
	// Fill - darken
	_ctrlMap drawTriangle [
		_x,
		[0,0,0,0.5],
		"#(rgb,1,1,1)color(1,1,1,1)"
	];

	// Fill - stripes
	_ctrlMap drawTriangle [
		_x,
		[0.5,0.2,0.1,0.5],
		_texture
	];

} forEach (missionNamespace getVariable [format [QGVAR(CA_%1_triangles), GVAR(side)], []]);

// Draw the combat area outline (if this side has one)
private _combatArea = missionNamespace getVariable [format [QGVAR(CA_%1), GVAR(side)], []];
if !(_combatArea isEqualTo []) then {
	_ctrlMap drawPolygon [_combatArea, [1,0,0,1]];
};
