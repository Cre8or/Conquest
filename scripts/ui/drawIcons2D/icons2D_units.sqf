private _c_iconUnit            = getMissionPath "res\images\icon_unit.paa";
private _c_iconUnitUnconscious = getMissionPath "res\images\icon_unit_unconscious.paa";

// Strip specific units from the existing arrays, so we can render them separately while leaving the remaining ones
// for the role-agnostic render method
_renderData = [];

{
	_unitX = _x # 0;

	_renderData pushBack (
		_x + [SQUARE(MACRO_COLOUR_A100_FRIENDLY), _unitX getVariable [QGVAR(isUnconscious), false]]
	);
} forEach _teamMates;

{
	_unitX = _x # 0;

	_renderData pushBack (
		_x + [SQUARE(MACRO_COLOUR_A100_SQUAD), _unitX getVariable [QGVAR(isUnconscious), false]]
	);
} forEach (_squadMates + [[_player, getPosWorld _player]]);

{
	_unitX = _x # 0;

	if !(_unitX getVariable [QGVAR(isUnconscious), false]) then {
		_renderData pushBack (
			_x + [SQUARE(MACRO_COLOUR_A100_ENEMY), false]
		);
	};
} forEach _spottedEnemies;





{
	_x params ["_unit", "_posX", "_colourFill", "_isUnconscious"];

	if (_isUnconscious) then {
		_iconsQueue pushBack [
			_c_iconUnitUnconscious,
			_colourFill,
			_posX,
			12,
			12,
			0,
			"",
			2
		];

	} else {
		_iconsQueue pushBack [
			_c_iconUnit,
			_colourFill,
			_posX,
			12,
			12,
			_mapAngle + getDir _unit,
			"",
			2
		];
	};

} forEachReversed _renderData;
