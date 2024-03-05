/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LE]
		Handles the drawing of the selected spawn sector on full-screen map controls.
	Arguments:
		0:	<CONTROL>	The map control to draw on
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_ctrlMap", controlNull, [controlNull]]
];

if (isNull _ctrlMap) exitWith {};





// Only continue if the player has joined a side, and selected a valid spawn sector
if (GVAR(side) != sideEmpty and {!isNull GVAR(spawnSector)}) then {

	// Set up some variables
	private _scale = ctrlMapScale _ctrlMap;
	private _size = (1 + (1 - time mod 1) ^ 2 * 0.5) * 100 * MACRO_UI_SECTORFLAGS_SCALEMUL * MACRO_UI_SECTORFLAGS_SCALEOFFSET / ((MACRO_UI_SECTORFLAGS_SCALEOFFSET * 2) min (MACRO_UI_SECTORFLAGS_SCALEOFFSET + _scale));
	private _sizeLine = 1000 * _scale;

	private _flagPole = GVAR(spawnSector) getVariable [QGVAR(flagPole), objNull];
	private "_pos";
	if (alive _flagPole) then {
		_pos = getPosWorld _flagPole;
	} else {
		_pos = getPosWorld GVAR(spawnSector);
	};

	// Spinning selection circle
	_ctrlMap drawIcon [
		getMissionPath "res\images\sign_selected.paa",
		SQUARE(MACRO_COLOUR_A100_WHITE),
		_pos,
		_size,
		_size,
		time * 180
	];

	// Lines
	{
		_x params ["_start", "_end"];

		_ctrlMap drawLine [
			_pos vectorAdd (_start vectorMultiply _sizeLine),
			_pos vectorAdd (_end vectorMultiply _sizeLine),
			SQUARE(MACRO_COLOUR_A100_WHITE)
		];
	} forEach [
		[[1,0,0],	[100,0,0]],
		[[0,1,0],	[0,100,0]],
		[[-1,0,0],	[-100,0,0]],
		[[0,-1,0],	[0,-100,0]]
	];
};
