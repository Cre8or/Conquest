private _c_maxDistEngineerSqr = MACRO_UI_ICONS3D_MAXDISTANCE_ROLEACTION ^ 2;
private _c_iconRepair         = getMissionPath "res\images\abilities\ability_repair.paa";

// Strip specific units from the existing arrays, so we can render them separately while leaving the remaining ones
// for the role-agnostic render method
_renderData = [];
private ["_unitX", "_distX"];

// Define some macro functions
#define MACRO_FNC_FILTERUNITS_ISENGINEER(UNITARRAY, COLOUR) \
	{ \
		_unitX = _x select 0; \
		_distX = _x select 2; \
 \
		if (_distX < _c_maxDistEngineerSqr and {_unitX getVariable [QGVAR(role), MACRO_ENUM_ROLE_INVALID] == MACRO_ENUM_ROLE_ENGINEER} and {[_unitX] call FUNC(unit_isAlive)}) then { \
			_renderData pushBack ( \
				_x + [SQUARE(COLOUR), _isLowHealthOrFreeLook, _health, false] \
			); \
			UNITARRAY deleteAt _forEachIndex; \
		}; \
	} forEachReversed UNITARRAY;





// Inside of a vehicle, the player is shown nearby engineers when their vehicle is low on health
if (_player != _vehPly) then {
	private _health = _vehPly getVariable [QGVAR(health), 1];
	if (_health >= 1) then {
		breakTo QGVAR(ui_sys_drawIcons3D);
	};
	private _isLowHealthOrFreeLook = (_health < MACRO_VEHICLE_HEALTH_THRESHOLDLOW or {_freeLook});

	MACRO_FNC_FILTERUNITS_ISENGINEER(_squadMates, MACRO_COLOUR_A100_SQUAD);
	MACRO_FNC_FILTERUNITS_ISENGINEER(_teamMates, MACRO_COLOUR_A100_FRIENDLY);
};





private ["_pos2D", "_nameX", "_colour", "_posXASL", "_angle", "_distMul"];
{
	_x params ["_unit", "_posX", "_dist", "_colourFill", "_alwaysShown", ["_health", -1], ["_showHealth", false]];

	// Optimisation: don't continue if the position is too far away, or if the icon is off-screem
	if (!_alwaysShown) then {
		if (_dist > _c_maxDistInfSqr) then {
			continue;
		};

		_pos2D = worldToScreen _posX;
		if (_pos2D isEqualTo []) then {
			continue;
		};
	};

	_nameX = name _unit;

	if (_blink and {_health < MACRO_VEHICLE_HEALTH_THRESHOLDLOW}) then {
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

	_iconsQueue pushBack [
		_c_iconRepair,
		[_colour, _colourFill] select _showHealth,
		_posX,
		1.3 * _c_uiScale,
		1.3 * _c_uiScale,
		0,
		_nameX,
		2,
		0.06 * _c_uiScale,
		MACRO_FONT_UI_MEDIUM,
		"center",
		true,
		0,
		-0.085 * _c_uiScale
	];

	// Health bar
	if (_showHealth) then {
		_iconsQueue pushBack [
			[_health] call FUNC(ui_getFillBarIcon),
			_colour,
			_posX,
			1.3 * _c_uiScale,
			2.6 * _c_uiScale,
			0,
			"",
			2,
			0,
			MACRO_FONT_UI_MEDIUM,
			"center",
			false,
			0,
			0
		];
	};

} forEach _renderData;
