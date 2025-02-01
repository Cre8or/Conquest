private _c_iconUnit            = getMissionPath "res\images\icon_unit.paa";
private _c_iconUnitUnconscious = getMissionPath "res\images\icon_unit_unconscious.paa";

// Strip specific units from the existing arrays, so we can render them separately while leaving the remaining ones
// for the role-agnostic render method
_renderData = [];

{
	_unitX = _x # 0;

	if !(_unitX getVariable [QGVAR(isUnconscious), false]) then {
		_renderData pushBack (
			_x + [SQUARE(MACRO_COLOUR_A100_ENEMY), false]
		);
	};
} forEach _spottedEnemies;

{
	_unitX = _x # 0;

	_renderData pushBack (
		_x + [SQUARE(MACRO_COLOUR_A100_SQUAD), _unitX getVariable [QGVAR(isUnconscious), false], _unitX == _player]
	);
} forEach ([[_player, getPosWorld _player]] + _squadMates);

{
	_unitX = _x # 0;

	_renderData pushBack (
		_x + [SQUARE(MACRO_COLOUR_A100_FRIENDLY), _unitX getVariable [QGVAR(isUnconscious), false]]
	);
} forEach _teamMates;




private ["_sizeX"];
{
	_x params ["_unit", "_posX", "_colourFill", "_isUnconscious", ["_isPlayer", false]];

	_sizeX = [12, 18] select _isPlayer;

	if (_isUnconscious) then {
		_iconsQueue pushBack [
			_c_iconUnitUnconscious,
			_colourFill,
			_posX,
			_sizeX,
			_sizeX,
			0,
			"",
			2
		];

	} else {
		_iconsQueue pushBack [
			_c_iconUnit,
			_colourFill,
			_posX,
			_sizeX,
			_sizeX,
			_mapAngle + getDir _unit,
			"",
			2
		];

	};

} forEach _renderData;
