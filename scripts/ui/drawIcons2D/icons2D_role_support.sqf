private _c_iconResupply = getMissionPath "res\images\abilities\ability_resupply.paa";

// Strip specific units from the existing arrays, so we can render them separately while leaving the remaining ones
// for the role-agnostic render method
_renderData = [];

// Define some macro functions
#define MACRO_FNC_FILTERUNITS_LOWAMMO(UNITARRAY, COLOUR) \
	{ \
		_unitX = _x select 0; \
 \
		if (([_unitX] call FUNC(lo_getOverallAmmo)) < MACRO_UNIT_AMMO_THRESHOLDLOW) then { \
			_renderData pushBack ( \
				_x + [SQUARE(COLOUR), true] \
			); \
			UNITARRAY deleteAt _forEachIndex; \
		}; \
	} forEachReversed UNITARRAY;

#define MACRO_FNC_FILTERUNITS_ISSUPPORT(UNITARRAY, COLOUR) \
	{ \
		_unitX = _x select 0; \
 \
		if (_unitX getVariable [QGVAR(role), MACRO_ENUM_ROLE_INVALID] == MACRO_ENUM_ROLE_SUPPORT and {!(_unitX getVariable [QGVAR(isUnconscious), false])}) then { \
			_renderData pushBack ( \
				_x + [SQUARE(COLOUR), _isLowAmmo] \
			); \
			UNITARRAY deleteAt _forEachIndex; \
		}; \
	} forEachReversed UNITARRAY;





// As a support, the player is shown units who are in need of resupplying
if (GVAR(role) == MACRO_ENUM_ROLE_SUPPORT and {[_player] call FUNC(unit_isAlive)}) then {
	MACRO_FNC_FILTERUNITS_LOWAMMO(_teamMates, MACRO_COLOUR_A100_FRIENDLY);
	MACRO_FNC_FILTERUNITS_LOWAMMO(_squadMates, MACRO_COLOUR_A100_SQUAD);

// As a non-support, the player is shown nearby support units when low on ammo
} else {
	private _ammo = [_player] call FUNC(lo_getOverallAmmo);
	if (_ammo >= 1) then {
		breakTo QGVAR(ui_drawIcons2D);
	};
	private _isLowAmmo = (_ammo < MACRO_UNIT_AMMO_THRESHOLDLOW);

	MACRO_FNC_FILTERUNITS_ISSUPPORT(_teamMates, MACRO_COLOUR_A100_FRIENDLY);
	MACRO_FNC_FILTERUNITS_ISSUPPORT(_squadMates, MACRO_COLOUR_A100_SQUAD);
};





{
	_x params ["_unit", "_posX", "_colourFill", "_isCritical"];

	if (_isCritical and {_blink}) then {
		_colour = SQUARE(MACRO_COLOUR_A100_WHITE);
	} else {
		_colour = _colourFill;
	};

	_iconsQueue pushBack [
		_c_iconResupply,
		_colour,
		_posX,
		16,
		16,
		0,
		"",
		1
	];

} forEachReversed _renderData;
