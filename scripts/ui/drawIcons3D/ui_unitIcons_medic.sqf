private _c_maxDistMedicSqr = MACRO_UI_ICONS3D_MAXDISTANCE_MEDIC ^ 2;
private _c_iconHeal        = getMissionPath "res\images\abilities\ability_heal.paa";

// Strip specific units from the existing arrays, so we can render them separately while leaving the remaining ones
// for the role-agnostic renderer
private _renderData_units = [];
private "_unitX";
{
	_unitX = _x # 0;
	_distX = _x # 2;

	if (_distX < _c_maxDistMedicSqr and {[_unitX] call FUNC(unit_needsHealing)}) then {
		_renderData_units pushBack (
			_x + [SQUARE(MACRO_COLOUR_A100_FRIENDLY), false, _unitX getVariable [QGVAR(isUnconscious), false], _unitX getVariable [QGVAR(health), 0]]
		);
		_teamMates deleteAt _forEachIndex;
	};
} forEachReversed _teamMates;
{
	_unitX = _x # 0;
	_distX = _x # 2;

	if (_distX < _c_maxDistMedicSqr and {[_unitX] call FUNC(unit_needsHealing)}) then {
		_renderData_units pushBack (
			_x + [SQUARE(MACRO_COLOUR_A100_SQUAD), _freeLook, _unitX getVariable [QGVAR(isUnconscious), false], _unitX getVariable [QGVAR(health), 0]]
		);
		_squadMates deleteAt _forEachIndex;
	};
} forEachReversed _squadMates;


private ["_pos2D", "_nameX", "_colour", "_posXASL", "_angle", "_distMul"];
{
	_x params ["_unit", "_posX", "_dist", "_colourFill", "_alwaysShown", "_isUnconscious", "_health"];

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

	if (_blink and {_health < MACRO_UI_HB_LOWHEALTH}) then {
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

	if (_isUnconscious) then {
		drawIcon3D [
			_c_iconHeal,
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
	} else {
		drawIcon3D [
			_c_iconHeal,
			_colourFill,
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

		// Health bar
		drawIcon3D [
			[_health] call FUNC(ui_getFillBarIcon),
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
