private _c_iconRepair = getMissionPath "res\images\abilities\ability_repair.paa";

// Strip specific units from the existing arrays, so we can render them separately while leaving the remaining ones
// for the role-agnostic render method
_renderData = [];

// Define some macro functions
#define MACRO_FNC_FILTERUNITS_ISENGINEER(UNITARRAY, COLOUR) \
	{ \
		_unitX = _x select 0; \
 \
		if (_unitX getVariable [QGVAR(role), MACRO_ENUM_ROLE_INVALID] == MACRO_ENUM_ROLE_ENGINEER and {!(_unitX getVariable [QGVAR(isUnconscious), false])}) then { \
			_renderData pushBack ( \
				_x + [SQUARE(COLOUR), _isLowHealth] \
			); \
			UNITARRAY deleteAt _forEachIndex; \
		}; \
	} forEachReversed UNITARRAY;





// As an engineer, the player is shown nearby vehicles that are in need of repairing
if (GVAR(role) == MACRO_ENUM_ROLE_MEDIC and {[_player] call FUNC(unit_isAlive)}) then {
	private "_healthX";

// As a non-engineer, the player is shown nearby engineers when their vehicle is low on health
} else {
	if (!_isSpawned or {_player == _vehPly}) then {
		breakTo QGVAR(ui_drawIcons2D);
	};

	private _health = _vehPly getVariable [QGVAR(health), 1];
	if (_health >= 1) then {
		breakTo QGVAR(ui_drawIcons2D);
	};
	private _isLowHealth = (_health < MACRO_VEHICLE_HEALTH_THRESHOLDLOW);

	MACRO_FNC_FILTERUNITS_ISENGINEER(_squadMates, MACRO_COLOUR_A100_SQUAD);
	MACRO_FNC_FILTERUNITS_ISENGINEER(_teamMates, MACRO_COLOUR_A100_FRIENDLY);
};





{
	_x params ["_unit", "_posX", "_colourFill", "_isCritical"];

	if (_isCritical and {_blink}) then {
		_colour = SQUARE(MACRO_COLOUR_A100_WHITE);
	} else {
		_colour = _colourFill;
	};

	_iconsQueue pushBack [
		_c_iconRepair,
		_colour,
		_posX,
		16,
		16,
		0,
		"",
		1
	];

} forEach _renderData;
