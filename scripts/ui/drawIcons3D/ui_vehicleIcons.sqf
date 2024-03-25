private _allVehicles         = GVAR(allVehicles) select {alive _x};
private _renderData_vehicles = [];
private ["_crew", "_commander", "_crewUnit"];

// Aggregate candidate vehicles and compile them into an array for rendering
{
	_crew      = crew _x select {[_x] call FUNC(unit_isAlive)};
	_commander = effectiveCommander _x;
	_crewUnit  = [_commander, _crew # 0] select (_commander in _crew);

	if (isNull _crewUnit) then {
		continue;
	};

	if (_crewUnit getVariable [QGVAR(side), sideEmpty] == GVAR(side)) then {

		if (_x != _vehPly) then {

			if (group _crewUnit == _groupPly) then {
				_renderData_vehicles pushBack [_x, _crewUnit, SQUARE(MACRO_COLOUR_A100_SQUAD), _freeLook, true];
			} else {
				_renderData_vehicles pushBack [_x, _crewUnit, SQUARE(MACRO_COLOUR_A100_FRIENDLY), false, true];
			};
		};
	} else {
		_crewUnit = _crew param [_crew findIf {_time < _x getVariable [_c_spottedTimeVarName, 0]}, objNull];

		if (!isNull _crewUnit) then {
			_renderData_vehicles pushBack [_x, _crewUnit, SQUARE(MACRO_COLOUR_A100_ENEMY), false, false];
		};
	};
} forEach _allVehicles;





// Draw the vehicle icons
private ["_posX", "_posXASL", "_dist", "_pos2D", "_nameX", "_angle", "_distMul", "_typeEnum", "_icon"];
{
	_x params ["_veh", "_unit", "_colour", "_alwaysShown", "_showCrewCount"];

	_posX    = unitAimPositionVisual _veh;
	_posXASL = AGLtoASL _posX;
	_dist    = _posPly distanceSqr _posXASL;

	// Optimisation: don't continue if the position is too far away, or if the icon is off-screem
	if (!_alwaysShown) then {
		if (_dist > _c_maxDistSqr) then {
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

	_distMul = 1 - 0.75 * (sqrt _dist / MACRO_UI_ICONS3D_MAXDISTANCE_VEH);
	_colour set [3, _distMul];

	_typeEnum = [typeOf _veh] call FUNC(veh_getType);
	_icon = [_typeEnum] call FUNC(ui_getVehTypeIcon);

	drawIcon3D [
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

} forEach _renderData_vehicles;
