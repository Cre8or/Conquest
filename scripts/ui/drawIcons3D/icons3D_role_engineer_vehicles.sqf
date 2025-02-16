private _c_maxDistEngineerSqr = MACRO_UI_ICONS3D_MAXDISTANCE_ROLEACTION ^ 2;

// Strip specific vehicles from the existing arrays, so we can render them separately while leaving the remaining ones
// for the role-agnostic render method
_renderData = [];

// Define some macro functions
#define MACRO_FNC_FILTERVEHICLES_LOWHEALTH(VEHICLEARRAY, COLOUR) \
	{ \
		_vehX    = _x select 0; \
		_distX   = _x select 3; \
		_healthX = _vehX getVariable [QGVAR(health), 1]; \
 \
		if (_distX < _c_maxDistEngineerSqr and {_healthX < 1}) then { \
			_renderData pushBack ( \
				_x + [SQUARE(COLOUR), _freeLook or {_healthX < MACRO_VEHICLE_HEALTH_THRESHOLDLOW}, _healthX] \
			); \
			VEHICLEARRAY deleteAt _forEachIndex; \
		}; \
	} forEachReversed VEHICLEARRAY;





// As an engineer, the player is shown nearby vehicles that are in need of repairing
if (GVAR(role) == MACRO_ENUM_ROLE_ENGINEER and {!(_player getVariable [QGVAR(isUnconscious), false])}) then {
	private ["_vehX", "_distX", "_healthX"];

	MACRO_FNC_FILTERVEHICLES_LOWHEALTH(_squadVehicles, MACRO_COLOUR_A100_SQUAD);
	MACRO_FNC_FILTERVEHICLES_LOWHEALTH(_teamVehicles, MACRO_COLOUR_A100_FRIENDLY);
};





private ["_pos2D", "_nameX", "_colour", "_angle", "_distMul", "_class", "_icon"];
{
	_x params ["_veh", "_unit", "_posX", "_distX", "_colourFill", "_alwaysShown", "_health"];

	// Optimisation: don't continue if the position is too far away, or if the icon is off-screem
	if (!_alwaysShown) then {
		if (_distX > _c_maxDistVehSqr) then {
			continue;
		};

		_pos2D = worldToScreen _posX;
		if (_pos2D isEqualTo []) then {
			continue;
		};
	};

	_nameX = "";

	if (_alwaysShown) then {
		_angle = 0;
	} else {
		_angle = (_posPly vectorFromTo AGLtoASL _posX) distanceSqr _dirPly;
	};

	if (_angle < _c_maxAngleSqr) then {
		_nameX     = name _unit;
		_crewCount = {alive _x} count crew _veh;

		if (_crewCount > 1) then {
			_nameX = format ["%1 (+%2)", _nameX, _crewCount - 1];
		};
	};

	if (_blink and {_health < MACRO_VEHICLE_HEALTH_THRESHOLDLOW}) then {
		_colour = SQUARE(MACRO_COLOUR_A100_WHITE);
	} else {
		_colour = _colourFill;
	};

	_distMul = 1 - 0.75 * (sqrt _distX / MACRO_UI_ICONS3D_MAXDISTANCE_VEH);
	_colour set [3, _distMul];

	_class = typeOf _veh;
	_icon  = [_class] call FUNC(ui_getVehiclePicture);

	// Name + icon
	_iconsQueue pushBack [
		_icon,
		_colour,
		_posX,
		1.8 * _c_uiScale,
		0.9 * _c_uiScale,
		0,
		_nameX,
		2,
		0.055 * _c_uiScale,
		MACRO_FONT_UI_MEDIUM,
		"center",
		_alwaysShown,
		0,
		-0.07 * _c_uiScale
	];

	// Shadow
	_iconsQueue pushBack [
		_icon,
		[0, 0, 0, _distMul],
		_posX,
		2.0 * _c_uiScale,
		1.0 * _c_uiScale,
		0,
		"",
		2,
		0.0,
		MACRO_FONT_UI_MEDIUM,
		"center",
		_alwaysShown,
		0,
		0.0
	];

	// Health bar
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

} forEach _renderData;
