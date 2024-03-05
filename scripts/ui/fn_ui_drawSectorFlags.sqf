/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LE]
		Handles the drawing of the sector letters and flag icons on map controls. Used on various displays,
		including the spawn menu, aswell as GPS/info panels.
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





// Set up some variables
private _scale = MACRO_UI_SECTORFLAGS_SCALEMUL * MACRO_UI_SECTORFLAGS_SCALEOFFSET / ((MACRO_UI_SECTORFLAGS_SCALEOFFSET * 2) min (MACRO_UI_SECTORFLAGS_SCALEOFFSET + ctrlMapScale _ctrlMap));
private _width = 48 * _scale;
private _height = 32 * _scale;
private _lockTexture = getMissionPath "res\images\sector_locked.paa";
private _unspawnableTexture = getMissionPath "res\images\sector_unspawnable.paa";

// Iterate through every sector
private ["_flagTexture", "_flagPole", "_pos"];
{
	// Set up some variables
	_flagTexture = [_x getVariable [QGVAR(side), sideEmpty]] call FUNC(gm_getFlagTexture);
	_flagPole    = _x getVariable [QGVAR(flagPole), objNull];

	if (isNull _flagPole) then {
		_pos = getPosWorld _x;
	} else {
		_pos = getPosWorld _flagPole;
	};

	// Flag
	_ctrlMap drawIcon [
		_flagTexture,
		SQUARE(MACRO_COLOUR_A100_WHITE),
		_pos,
		_width,
		_height,
		0
	];

	// Locked
	if (_x getVariable [QGVAR(isLocked), false]) then {
		_ctrlMap drawIcon [
			_lockTexture,
			SQUARE(MACRO_COLOUR_SECTOR_LOCKED),
			_pos,
			80 * _scale,	// undo the 4:5 ratio of the icon, thus offsetting the icon into the correct position
			64 * _scale,
			0
		];
	};

	// Unspawnable sectors (extended information for the spawn menu only)
	private _isSpawnMenu = _ctrlMap getVariable [QGVAR(isSpawnMenu), false];
	if (_isSpawnMenu and {(_x getVariable [format [QGVAR(spawnPoints_%1), GVAR(side)], []]) isEqualTo []}) then {
		_ctrlMap drawIcon [
			_unspawnableTexture,
			SQUARE(MACRO_COLOUR_A100_RED),
			_pos,
			80 * _scale,
			64 * _scale,
			0
		];
	};

	// Sector letter
	_ctrlMap drawIcon [
		"a3\ui_f\data\IGUI\Cfg\Targeting\Empty_ca.paa",
		SQUARE(MACRO_COLOUR_A100_WHITE),
		_pos,
		_width,
		_height,
		0,
		format [" %1", _x getVariable [QGVAR(letter), "???"]],
		2,
		0.06,
		MACRO_FONT_UI_MEDIUM
	];

} forEach GVAR(allSectors);
