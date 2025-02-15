// Set up some constants
private _c_iconGrenade = getMissionPath "res\images\3d\grenade_highlight.paa";
private _c_iconBlank   = "a3\ui_f\data\IGUI\Cfg\Targeting\Empty_ca.paa";





private ["_icon", "_distRatio", "_distMul", "_scale", "_colour"];
{
	_x params ["_posX", "_dist"];

	_dist      = sqrt _dist;
	_distRatio = _dist / MACRO_UI_ICONS3D_MAXDISTANCE_GRENADES;
	_distMul   = 1 - 0.75 * _distRatio;
	_scale     = 10 * (5 + sin (720 * _time)) * _c_uiScale / (1 + _dist);


	// Optimisation: don't continue if the icon is off-screem
	_pos2D = worldToScreen _posX;
	if (_pos2D isNotEqualTo []) then {

		// Icon
		_iconsQueue pushBack [
			_c_iconGrenade,
			[1, 1, 1, _distMul],
			_posX,
			_scale,
			_scale,
			0,
			"",
			0,
			0.5 * _scale,
			MACRO_FONT_UI_MEDIUM,
			"center",
			false,
			0,
			0
		];
	};

	// Text
	_colour = SQUARE(MACRO_COLOUR_A100_ENEMY);
	_colour set [3, _distMul];
	_iconsQueue pushBack [
		_c_iconBlank,
		_colour,
		_posX,
		_scale,
		_scale,
		0,
		"",
		0,
		0.05 * _scale,
		MACRO_FONT_UI_MEDIUM,
		"center",
		true,
		0,
		0
	];

} forEach _allGrenades;
