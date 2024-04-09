/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LE]
		Handles the drawing of the sector location texts on full-screen map controls.

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
private _scale = ctrlMapScale _ctrlMap;
private _mul = MACRO_UI_SECTORNAMES_SCALEMUL * 0.001 / _scale;
private _alpha = 0.6 / (((_mul - 0.1) * MACRO_UI_SECTORNAMES_FADEMUL + 1) max 1);

// If the map is zoomed in far enough, draw the sector names
if (_mul > 0.02) then {

	// Iterate through every sector
	{
		_ctrlMap drawIcon ["a3\ui_f\data\Map\VehicleIcons\IconManLeader_ca.paa", [0,0,0, _alpha], position _x, 1, 1, 0, _x getVariable [QGVAR(name), ""], 0, _mul, "RobotoCondensed", "center"];
	} forEach GVAR(allSectors);
};
