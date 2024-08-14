private _c_maxDistMedicSqr = MACRO_UI_ICONS3D_MAXDISTANCE_MEDIC ^ 2;
private _c_iconHeal        = getMissionPath "res\images\abilities\ability_heal.paa";

// Strip specific units from the existing arrays, so we can render them separately while leaving the remaining ones
// for the role-agnostic renderer
private _renderData_units = [];
private "_unitX";

// As a medic, the player is shown nearby units who are in need of healing
if (GVAR(role) == MACRO_ENUM_ROLE_MEDIC and {!(_player getVariable [QGVAR(isUnconscious), false])}) then {
	private "_healthX";

	{
		_unitX = _x # 0;
		_distX = _x # 2;

		if (
			_distX < _c_maxDistMedicSqr
			and {
				_unitX getVariable [QGVAR(health), 1] < 1
				or {_unitX getVariable [QGVAR(isUnconscious), false]}
			}
		) then {
			_healthX = _unitX getVariable [QGVAR(health), 0];

			_renderData_units pushBack (
				_x + [SQUARE(MACRO_COLOUR_A100_FRIENDLY), _freeLook or {_healthX < MACRO_UNIT_HEALTH_THRESHOLDLOW}, _unitX getVariable [QGVAR(health), 0], !(_unitX getVariable [QGVAR(isUnconscious), false])]
			);
			_teamMates deleteAt _forEachIndex;
		};
	} forEachReversed _teamMates;
	{
		_unitX = _x # 0;
		_distX = _x # 2;

		if (
			_distX < _c_maxDistMedicSqr
			and {
				_unitX getVariable [QGVAR(health), 1] < 1
				or {_unitX getVariable [QGVAR(isUnconscious), false]}
			}		) then {
			_healthX = _unitX getVariable [QGVAR(health), 0];

			_renderData_units pushBack (
				_x + [SQUARE(MACRO_COLOUR_A100_SQUAD), _freeLook or {_healthX < MACRO_UNIT_HEALTH_THRESHOLDLOW}, _healthX, !(_unitX getVariable [QGVAR(isUnconscious), false])]
			);
			_squadMates deleteAt _forEachIndex;
		};
	} forEachReversed _squadMates;

// As a non-medic, the player is shown nearby medics when low on health
} else {

	private _health = _player getVariable [QGVAR(health), -1];
	if (_health >= 1) then {
		breakTo QGVAR(ui_sys_drawIcons3D);
	};

	{
		_unitX = _x # 0;
		_distX = _x # 2;

		if (_distX < _c_maxDistMedicSqr and {_unitX getVariable [QGVAR(role), MACRO_ENUM_ROLE_INVALID] == MACRO_ENUM_ROLE_MEDIC} and {[_unitX] call FUNC(unit_isAlive)}) then {
			_renderData_units pushBack (
				_x + [SQUARE(MACRO_COLOUR_A100_FRIENDLY), _health < MACRO_UNIT_HEALTH_THRESHOLDLOW or {_freeLook}, _health, false]
			);
			_teamMates deleteAt _forEachIndex;
		};
	} forEachReversed _teamMates;
	{
		_unitX = _x # 0;
		_distX = _x # 2;

		if (_distX < _c_maxDistMedicSqr and {_unitX getVariable [QGVAR(role), MACRO_ENUM_ROLE_INVALID] == MACRO_ENUM_ROLE_MEDIC} and {[_unitX] call FUNC(unit_isAlive)}) then {
			_renderData_units pushBack (
				_x + [SQUARE(MACRO_COLOUR_A100_SQUAD), _health < MACRO_UNIT_HEALTH_THRESHOLDLOW or {_freeLook}, _health, false]
			);
			_squadMates deleteAt _forEachIndex;
		};
	} forEachReversed _squadMates;

};





private ["_pos2D", "_nameX", "_colour", "_posXASL", "_angle", "_distMul"];
{
	_x params ["_unit", "_posX", "_dist", "_colourFill", "_alwaysShown", ["_health", -1], ["_showHealth", false]];

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

	if (_blink and {_health < MACRO_UNIT_HEALTH_THRESHOLDLOW}) then {
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
		_c_iconHeal,
		[_colour, _colourFill] select _showHealth,
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
	if (_showHealth) then {
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
