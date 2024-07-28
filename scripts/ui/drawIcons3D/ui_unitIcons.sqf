// Set up some constants
private _c_iconUnit            = "a3\ui_f\data\IGUI\RscIngameUI\RscHint\indent_gr.paa";
private _c_iconUnitUnconscious = getMissionPath "res\images\icon_unit_unconscious.paa";

// Set up some variables
private _renderData_units = [];





// Compile unit data into an array for rendering
_renderData_units append (_teamMates apply {
	_x + [SQUARE(MACRO_COLOUR_A100_FRIENDLY), false, false]
});
_renderData_units append (_squadMates apply {
	_x + [SQUARE(MACRO_COLOUR_A100_SQUAD), false, _freeLook]
});
_renderData_units append (_spottedEnemies apply {
	_x + [SQUARE(MACRO_COLOUR_A100_ENEMY), true, false]
});





private ["_pos2D", "_posXASL", "_visibility", "_isUnconscious", "_nameX", "_angle", "_distMul"];
{
	_x params ["_unit", "_posX", "_dist", "_colour", "_checkVisibility", "_alwaysShown"];

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

	_posXASL = AGLtoASL _posX;
	if (_checkVisibility) then {
		_visibility = [_vehPly, "VIEW", vehicle _unit] checkVisibility [_posPly, _posXASL];

		if (_visibility < MACRO_ACT_SPOTTING_MINVISIBILITY) then {
			continue;
		};
	};

	_isUnconscious = _unit getVariable [QGVAR(isUnconscious), false];

	if (!_isUnconscious) then {
		_nameX = name _unit;
	};

	if (!_alwaysShown) then {
		_angle = (_posPly vectorFromTo _posXASL) distanceSqr _dirPly;

		if (_angle > _c_maxAngleSqr) then {
			_nameX = "";
		};

		_distMul = 1 - 0.75 * (sqrt _dist / MACRO_UI_ICONS3D_MAXDISTANCE_INF);
		_colour set [3, _distMul];
	};

	if (_isUnconscious) then {
		drawIcon3D [
			_c_iconUnitUnconscious,
			_colour,
			_posX,
			0.4,
			0.4,
			0,
			"",
			2,
			0.03,
			MACRO_FONT_UI_THIN, // TahomaB
			"center",
			false,
			0,
			-0.07 * _c_uiScale
		];
	} else {
		drawIcon3D [
			_c_iconUnit,
			_colour,
			_posX,
			0.6,
			0.6,
			0,
			_nameX,
			2,
			0.03,
			MACRO_FONT_UI_THIN, // TahomaB
			"center",
			false,
			0,
			-0.07 * _c_uiScale
		];
	};
} forEach _renderData_units;
