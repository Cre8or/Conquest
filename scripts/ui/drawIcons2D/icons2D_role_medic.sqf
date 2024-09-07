private _c_iconHeal = getMissionPath "res\images\abilities\ability_heal.paa";

// Strip specific units from the existing arrays, so we can render them separately while leaving the remaining ones
// for the role-agnostic render method
_renderData = [];

// Define some macro functions
#define MACRO_FNC_FILTERUNITS_LOWHEALTH(UNITARRAY, COLOUR) \
	{ \
		_unitX   = _x select 0; \
		_healthX = _unitX getVariable [QGVAR(health), 1]; \
 \
		if (_healthX < 1 or {_unitX getVariable [QGVAR(isUnconscious), false]}) then { \
			_renderData pushBack ( \
				_x + [SQUARE(COLOUR), _healthX < MACRO_UNIT_HEALTH_THRESHOLDLOW] \
			); \
			UNITARRAY deleteAt _forEachIndex; \
		}; \
	} forEachReversed UNITARRAY;

#define MACRO_FNC_FILTERUNITS_ISMEDIC(UNITARRAY, COLOUR) \
	{ \
		_unitX = _x select 0; \
 \
		if (_unitX getVariable [QGVAR(role), MACRO_ENUM_ROLE_INVALID] == MACRO_ENUM_ROLE_MEDIC and {!(_unitX getVariable [QGVAR(isUnconscious), false])}) then { \
			_renderData pushBack ( \
				_x + [SQUARE(COLOUR), _isLowHealth] \
			); \
			UNITARRAY deleteAt _forEachIndex; \
		}; \
	} forEachReversed UNITARRAY;





// As a medic, the player is shown units who are in need of healing
if (GVAR(role) == MACRO_ENUM_ROLE_MEDIC and {[_player] call FUNC(unit_isAlive)}) then {
	private "_healthX";

	MACRO_FNC_FILTERUNITS_LOWHEALTH(_teamMates, MACRO_COLOUR_A100_FRIENDLY);
	MACRO_FNC_FILTERUNITS_LOWHEALTH(_squadMates, MACRO_COLOUR_A100_SQUAD);

// As a non-medic, the player is shown nearby medics when low on health
} else {
	private _health = _player getVariable [QGVAR(health), 0];
	if (_health >= 1) then {
		breakTo QGVAR(ui_drawIcons2D);
	};
	private _isLowHealth = (_health < MACRO_UNIT_HEALTH_THRESHOLDLOW);

	MACRO_FNC_FILTERUNITS_ISMEDIC(_teamMates, MACRO_COLOUR_A100_FRIENDLY);
	MACRO_FNC_FILTERUNITS_ISMEDIC(_squadMates, MACRO_COLOUR_A100_SQUAD);
};





{
	_x params ["_unit", "_posX", "_colourFill", "_isCritical"];

	if (_isCritical and {_blink}) then {
		_colour = SQUARE(MACRO_COLOUR_A100_WHITE);
	} else {
		_colour = _colourFill;
	};

	_iconsQueue pushBack [
		_c_iconHeal,
		_colour,
		_posX,
		16,
		16,
		0,
		"",
		1
	];

} forEachReversed _renderData;
