_renderData = [];

{
	_renderData pushBack (_x + [SQUARE(MACRO_COLOUR_A100_WHITE)]);
} forEach _emptyVehicles;

{
	_renderData pushBack (_x + [SQUARE(MACRO_COLOUR_A100_FRIENDLY)]);
} forEach _teamVehicles;

{
	_renderData pushBack (_x + [SQUARE(MACRO_COLOUR_A100_SQUAD)]);
} forEach _squadVehicles;

{
	_renderData pushBack (_x + [SQUARE(MACRO_COLOUR_A100_ENEMY)]);
} forEach _spottedVehicles;





private ["_class", "_icon"];
{
	_x params ["_veh", "_posX", "_colourFill"];

	_class = typeOf _veh;
	_icon  = [_class] call FUNC(ui_getVehicleIcon);

	// Icon
	_iconsQueue pushBack [
		_icon,
		_colourFill,
		_posX,
		24,
		24,
		_mapAngle + getDir _veh,
		"",
		2
	];

	// Shadow 1
	_iconsQueue pushBack [
		_icon,
		SQUARE(MACRO_COLOUR_A75_BLACK),
		_posX,
		20,
		20,
		_mapAngle + getDir _veh,
		"",
		2
	];

	// Shadow 2
	_iconsQueue pushBack [
		_icon,
		SQUARE(MACRO_COLOUR_A75_BLACK),
		_posX,
		28,
		28,
		_mapAngle + getDir _veh,
		"",
		2
	];

} forEach _renderData;
