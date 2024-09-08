_renderData = [];

{
	_renderData pushBack (_x + [SQUARE(MACRO_COLOUR_A100_ENEMY), false, false]);
} forEach _spottedVehicles;
{
	_renderData pushBack (_x + [SQUARE(MACRO_COLOUR_A100_SQUAD), false, true]);
} forEach _squadVehicles;
{
	_renderData pushBack (_x + [SQUARE(MACRO_COLOUR_A100_FRIENDLY), _freeLook, true]);
} forEach _teamVehicles;





private ["_posXASL", "_pos2D", "_nameX", "_angle", "_distMul", "_typeEnum", "_icon"];
{
	_x params ["_veh", "_unit", "_colour", "_alwaysShown", "_showCrewCount"];

	_posX    = unitAimPositionVisual _veh;
	_posXASL = AGLtoASL _posX;
	_distX   = _posPly distanceSqr _posXASL;

	// Optimisation: don't continue if the position is too far away, or if the icon is off-screem
	if (!_alwaysShown) then {
		if (_distX > _c_maxDistSqr) then {
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
		_angle = (_posPly vectorFromTo _posXASL) distanceSqr _dirPly;
	};

	if (_angle < _c_maxAngleSqr) then {
		_nameX = name _unit;

		if (_showCrewCount) then {
			_crewCount = {alive _x} count crew _veh;

			if (_crewCount > 1) then {
				_nameX = format ["%1 (+%2)", _nameX, _crewCount - 1];
			};
		};
	};

	_distMul = 1 - 0.75 * (sqrt _distX / MACRO_UI_ICONS3D_MAXDISTANCE_VEH);
	_colour set [3, _distMul];

	_typeEnum = [typeOf _veh] call FUNC(veh_getType);
	_icon = [_typeEnum] call FUNC(ui_getVehTypeIcon);

	_iconsQueue pushBack [
		_icon,
		_colour,
		_posX,
		0.8,
		0.8,
		0,
		_nameX,
		2,
		0.03,
		MACRO_FONT_UI_THIN,
		"center",
		_alwaysShown,
		0,
		-0.08 * _c_uiScale
	];

} forEach _renderData;
