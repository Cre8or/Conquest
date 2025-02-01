// Set up some constants
private _c_iconSectorCaptured = getMissionPath "res\images\3d\sector_captured.paa";
private _c_iconSectorNeutral  = getMissionPath "res\images\3d\sector_neutral.paa";
private _c_iconSectorEnemy    = getMissionPath "res\images\3d\sector_enemy.paa";





private ["_icon", "_colour", "_distRatio", "_distMul", "_scale"];
{
	_x params ["_dist", "_sectorX"];

	// Optimisation: don't continue if the position is too far away, or if the icon is off-screem
	if (_dist > _c_maxDistSectorSqr) then {
		continue;
	};

	// Figure out what state the sector is in
	_sectorX params ["_posX", "_letter", "_kind"];
	switch (_kind) do {
		case MACRO_SECTOR_CAPTURED: {
			_icon   = _c_iconSectorCaptured;
			_colour = SQUARE(MACRO_COLOUR_A100_FRIENDLY);
		};
		case MACRO_SECTOR_NEUTRAL: {
			_icon   = _c_iconSectorNeutral;
			_colour = SQUARE(MACRO_COLOUR_A100_WHITE);
		};
		default {
			_icon   = _c_iconSectorEnemy;
			_colour = SQUARE(MACRO_COLOUR_A100_ENEMY);
		};
	};

	_distRatio = sqrt _dist / MACRO_UI_ICONS3D_MAXDISTANCE_SECTOR;
	_distMul   = 1 - 0.75 * _distRatio;
	_colour set [3, _distMul];

	_distMul = 0.25 + 0.75 * (1 - _distRatio) ^ 2;
	_scale = ([1.5, 2.5] select _freeLook) * _distMul * _c_uiScale;

	_iconsQueue pushBack [
		_icon,
		_colour,
		_posX,
		1.2 * _scale,
		1.2 * _scale,
		0,
		_letter,
		2,
		0.05 * _scale,
		MACRO_FONT_UI_MEDIUM,
		"center",
		true,
		0,
		-0.035 * _scale
	];
} forEach _allSectors;
