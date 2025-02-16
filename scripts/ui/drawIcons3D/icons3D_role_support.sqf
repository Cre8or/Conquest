private _c_maxDistSupportSqr = MACRO_UI_ICONS3D_MAXDISTANCE_ROLEACTION ^ 2;
private _c_iconResupply      = getMissionPath "res\images\abilities\ability_resupply.paa";

// Strip specific units from the existing arrays, so we can render them separately while leaving the remaining ones
// for the role-agnostic render method
_renderData = [];
private ["_unitX", "_distX"];

// Define some macro functions
#define MACRO_FNC_FILTERUNITS_LOWAMMO(UNITARRAY, COLOUR) \
	{ \
		_unitX = _x select 0; \
		_distX = _x select 2; \
 \
		if (_distX < _c_maxDistSupportSqr and {[_unitX] call FUNC(unit_isAlive)}) then { \
			_ammoX = [_unitX] call FUNC(lo_getOverallAmmo); \
 \
			if (_ammoX < 1) then { \
				_renderData pushBack ( \
					_x + [SQUARE(COLOUR), _freeLook or {_ammoX < MACRO_UNIT_AMMO_THRESHOLDLOW}, _ammoX, true] \
				); \
				UNITARRAY deleteAt _forEachIndex; \
			}; \
		}; \
	} forEachReversed UNITARRAY;

#define MACRO_FNC_FILTERUNITS_ISSUPPORT(UNITARRAY, COLOUR) \
	{ \
		_unitX = _x select 0; \
		_distX = _x select 2; \
 \
		if (_distX < _c_maxDistSupportSqr and {_unitX getVariable [QGVAR(role), MACRO_ENUM_ROLE_INVALID] == MACRO_ENUM_ROLE_SUPPORT} and {[_unitX] call FUNC(unit_isAlive)}) then { \
			_renderData pushBack ( \
				_x + [SQUARE(COLOUR), _isLowAmmoOrFreeLook, _ammo] \
			); \
			UNITARRAY deleteAt _forEachIndex; \
		}; \
	} forEachReversed UNITARRAY; \





// As a support, the player is shown nearby units who are in need of resupplying
if (GVAR(role) == MACRO_ENUM_ROLE_SUPPORT) then {
	private ["_ammoX"];

	MACRO_FNC_FILTERUNITS_LOWAMMO(_squadMates, MACRO_COLOUR_A100_SQUAD);
	MACRO_FNC_FILTERUNITS_LOWAMMO(_teamMates, MACRO_COLOUR_A100_FRIENDLY);

// As a non-support, the player is shown nearby support units when low on ammo
} else {
	private _ammo = [_player] call FUNC(lo_getOverallAmmo);

	if (_ammo >= 1) then {
		breakTo QGVAR(ui_sys_drawIcons3D);
	};
	private _isLowAmmoOrFreeLook = (_ammo < MACRO_UNIT_AMMO_THRESHOLDLOW or {_freeLook});

	MACRO_FNC_FILTERUNITS_ISSUPPORT(_squadMates, MACRO_COLOUR_A100_SQUAD);
	MACRO_FNC_FILTERUNITS_ISSUPPORT(_teamMates, MACRO_COLOUR_A100_FRIENDLY);
};





private ["_pos2D", "_nameX", "_colour", "_posXASL", "_angle", "_distMul"];
{
	_x params ["_unit", "_posX", "_dist", "_colourFill", "_alwaysShown", ["_ammo", 0], ["_showAmmo", false]];

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

	_iconsQueue pushBack [
		_c_iconResupply,
		_colour,
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

	// Ammo bar
	if (_showAmmo) then {
		_iconsQueue pushBack [
			[_ammo] call FUNC(ui_getFillBarIcon),
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
