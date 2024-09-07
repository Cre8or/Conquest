private _c_maxDistSupportSqr = MACRO_UI_ICONS3D_MAXDISTANCE_ROLEACTION ^ 2;
private _c_iconResupply      = getMissionPath "res\images\abilities\ability_resupply.paa";

// Strip specific units from the existing arrays, so we can render them separately while leaving the remaining ones
// for the role-agnostic render method
private _renderData_units = [];

// As a support, the player is shown nearby units who are in need of resupplying
if (GVAR(role) == MACRO_ENUM_ROLE_SUPPORT) then {
	private ["_unitX", "_distX", "_ammoX"];

	{
		_unitX = _x # 0;
		_distX = _x # 2;

		if (
			_distX < _c_maxDistSupportSqr
			and {[_unitX] call FUNC(unit_isAlive)}
		) then {
			_ammoX = [_unitX] call FUNC(lo_getOverallAmmo);

			if (_ammoX < 1) then {
				_renderData_units pushBack (
					_x + [SQUARE(MACRO_COLOUR_A100_FRIENDLY), _freeLook or {_ammoX < MACRO_UNIT_AMMO_THRESHOLDLOW}, _ammoX, true]
				);
				_teamMates deleteAt _forEachIndex;
			};
		};
	} forEachReversed _teamMates;
	{
		_unitX = _x # 0;
		_distX = _x # 2;

		if (
			_distX < _c_maxDistSupportSqr
			and {[_unitX] call FUNC(unit_isAlive)}
		) then {
			_ammoX = [_unitX] call FUNC(lo_getOverallAmmo);

			if (_ammoX < 1) then {
				_renderData_units pushBack (
					_x + [SQUARE(MACRO_COLOUR_A100_SQUAD), _freeLook or {_ammoX < MACRO_UNIT_AMMO_THRESHOLDLOW}, _ammoX, true]
				);
				_squadMates deleteAt _forEachIndex;
			};
		};
	} forEachReversed _squadMates;

// As a non-support, the player is shown nearby support units when low on ammo
} else {
	private _ammo = [_player] call FUNC(lo_getOverallAmmo);
	private ["_unitX", "_distX"];

	if (_ammo >= 1) then {
		breakTo QGVAR(ui_sys_drawIcons3D);
	};

	{
		_unitX = _x # 0;
		_distX = _x # 2;

		if (_distX < _c_maxDistSupportSqr and {_unitX getVariable [QGVAR(role), MACRO_ENUM_ROLE_INVALID] == MACRO_ENUM_ROLE_SUPPORT} and {[_unitX] call FUNC(unit_isAlive)}) then {
			_renderData_units pushBack (
				_x + [SQUARE(MACRO_COLOUR_A100_FRIENDLY), _ammo < MACRO_UNIT_AMMO_THRESHOLDLOW or {_freeLook}, _ammo]
			);
			_teamMates deleteAt _forEachIndex;
		};
	} forEachReversed _teamMates;
	{
		_unitX = _x # 0;
		_distX = _x # 2;

		if (_distX < _c_maxDistSupportSqr and {_unitX getVariable [QGVAR(role), MACRO_ENUM_ROLE_INVALID] == MACRO_ENUM_ROLE_SUPPORT} and {[_unitX] call FUNC(unit_isAlive)}) then {
			_renderData_units pushBack (
				_x + [SQUARE(MACRO_COLOUR_A100_SQUAD), _ammo < MACRO_UNIT_AMMO_THRESHOLDLOW or {_freeLook}, _ammo]
			);
			_squadMates deleteAt _forEachIndex;
		};
	} forEachReversed _squadMates;
};





private ["_pos2D", "_nameX", "_colour", "_posXASL", "_angle", "_distMul"];
{
	_x params ["_unit", "_posX", "_dist", "_colourFill", "_alwaysShown", ["_ammo", 0], ["_showAmmo", false]];

	// Optimisation: don't continue if the position is too far away, or if the icon is off-screem
	if (!_alwaysShown) then {
		if (_dist > _c_maxDistSqr) then {
			continue;
		};

		_pos2D = worldToScreen _posX;
		if (_pos2D isEqualTo []) then {
			continue;
		};
	};

	_nameX = name _unit;

	if (_blink and {_ammo < MACRO_UNIT_AMMO_THRESHOLDLOW}) then {
		_colour = SQUARE(MACRO_COLOUR_A100_WHITE);
	} else {
		_colour = _colourFill;
	};

	if (!_alwaysShown) then {
		_posXASL = AGLtoASL _posX;
		_angle   = (_posPly vectorFromTo _posXASL) distanceSqr _dirPly;

		if (_angle > _c_maxAngleSqr) then {
			_nameX = "";
		};

		_distMul = 1 - 0.75 * (sqrt _dist / MACRO_UI_ICONS3D_MAXDISTANCE_INF);
		_colour set [3, _distMul];
	};

	drawIcon3D [
		_c_iconResupply,
		_colour,
		_posX,
		0.7,
		0.7,
		0,
		_nameX,
		2,
		0.03,
		MACRO_FONT_UI_THIN,
		"center",
		true,
		0,
		-0.09 * _c_uiScale
	];

	// Ammo bar
	if (_showAmmo) then {
		drawIcon3D [
			[_ammo] call FUNC(ui_getFillBarIcon),
			_colour,
			_posX,
			0.7,
			1.4,
			0,
			"",
			2,
			0.03,
			MACRO_FONT_UI_THIN, // TahomaB
			"center",
			true,
			0,
			-0.09 * _c_uiScale
		];
	};

} forEach _renderData_units;
