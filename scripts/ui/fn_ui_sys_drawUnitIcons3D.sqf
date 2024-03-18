/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles the drawing of unit/vehicle icons in 3D.

		Only executed once by the client upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

if (!hasInterface) exitWith {};





// Set up some variables
MACRO_FNC_INITVAR(GVAR(ui_sys_drawUnitIcons3D_EH), -1);





removeMissionEventHandler ["Draw3D", GVAR(ui_sys_drawUnitIcons3D_EH)];
GVAR(ui_sys_drawUnitIcons3D_EH) = addMissionEventHandler ["Draw3D", {

	if (isGamePaused) exitWith {};

	private _player = player;

	if (alive _player and {!dialog}) then { // Don't use unit_isAlive here!

		// Set up some constants
		private _c_maxDist = 500;
		private _c_maxDistSqr = _c_maxDist ^ 2;
		private _c_maxAngleSqr = (0.2 * getObjectFOV cameraOn) ^ 2;	// Minimum angle within which unit names should be displayed
		private _c_uiScale = getResolution # 5;

		// Set up some variables
		private _time = time;
		private _vehPly = vehicle _player;
		private _groupPly = group _player;
		private _posPly = ATLtoASL positionCameraToWorld [0,0,0];
		private _dirPly = (ATLtoASL positionCameraToWorld [0,0,1]) vectorDiff _posPly;
		private _spottedTimeVarName = format [QGVAR(spottedTime_%1), GVAR(side)];

		private _allUnits = allUnits;
		private _squadMates = units _groupPly select {alive _x and {_x != _player} and {vehicle _x == _x}};
		private _teamMates = (_allUnits select {side group _x == GVAR(side) and {_x != _player} and {vehicle _x == _x}}) - _squadMates;
		private _spottedEnemies = _allUnits select {side group _x != GVAR(side) and {_time < _x getVariable [_spottedTimeVarName, 0]} and {vehicle _x == _x}};

		private _allVehicles = GVAR(allVehicles) select {alive _x};
		private _squadVehicles = [];
		private _teamVehicles = [];
		private _enemyVehicles = [];

		private ["_crew", "_commander", "_crewUnit"];
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
						_squadVehicles pushBack [_x, _crewUnit];
					} else {
						_teamVehicles pushBack [_x, _crewUnit];
					};
				};
			} else {
				_crewUnit = _crew param [_crew findIf {_time < _x getVariable [_spottedTimeVarName, 0]}, objNull];

				if (!isNull _crewUnit) then {
					_enemyVehicles pushBack [_x, _crewUnit];
				};
			};
		} forEach _allVehicles;

		// Set up some functions
		private ["_posX", "_dist", "_distMul", "_angle", "_nameX", "_crewCount", "_typeEnum", "_icon", "_visibility", "_isVisible"];
		private _fnc_drawUnit = {
			params ["_unit", "_colour", "_checkVisibility"];

			_posX = ATLtoASL unitAimPositionVisual _unit;
			_dist = _posPly distanceSqr _posX;

			if (_dist < _c_maxDistSqr) then {

				if (_checkVisibility) then {
					_visibility = [_vehPly, "VIEW", vehicle _unit] checkVisibility [_posPly, _posX];
					_isVisible = (_visibility >= MACRO_ACT_SPOTTING_MINVISIBILITY);
				} else {
					_isVisible = true;
				};

				if (_isVisible) then {
					_angle = (_posPly vectorFromTo _posX) distanceSqr _dirPly;

					if (_angle < _c_maxAngleSqr) then {
						_nameX = name _unit;
					} else {
						_nameX = "";
					};

					_distMul = 1 - (sqrt _dist / _c_maxDist);
					_colour set [3, _distMul];

					drawIcon3D [
						"a3\ui_f\data\IGUI\RscIngameUI\RscHint\indent_gr.paa",
						_colour,
						ASLtoATL _posX,
						0.6,
						0.6,
						0,
						_nameX,
						2,
						0.025,
						"TahomaB",
						"center",
						false,
						0,
						-0.06 * _c_uiScale
					];
				};
			};
		};

		private _fnc_drawVehicle = {
			params ["_veh", "_unit", "_colour", "_showCrewCount"];

			_posX = ATLtoASL unitAimPositionVisual _veh;
			_dist = _posPly distanceSqr _posX;

			if (_dist < _c_maxDistSqr) then {
				_angle = (_posPly vectorFromTo _posX) distanceSqr _dirPly;

				if (_angle < _c_maxAngleSqr) then {
					_nameX = name _unit;

					if (_showCrewCount) then {
						_crewCount = {alive _x} count crew _veh;

						if (_crewCount > 1) then {
							_nameX = format ["%1 (+%2)", _nameX, _crewCount - 1];
						};
					};
				} else {
					_nameX = "";
				};

				_distMul = 1 - (sqrt _dist / _c_maxDist);
				_colour set [3, _distMul];

				_typeEnum = [typeOf _veh] call FUNC(veh_getType);
				_icon = [_typeEnum] call FUNC(ui_getVehTypeIcon);

				drawIcon3D [
					_icon,
					_colour,
					ASLtoATL _posX,
					0.8,
					0.8,
					0,
					_nameX,
					2,
					0.025,
					"TahomaB",
					"center",
					false,
					0,
					-0.08 * _c_uiScale
				];
			};
		};





		// Draw the icons
		{
			[_x, SQUARE(MACRO_COLOUR_A100_FRIENDLY), false] call _fnc_drawUnit;
		} forEach _teamMates;

		{
			[_x, SQUARE(MACRO_COLOUR_A100_SQUAD), false] call _fnc_drawUnit;
		} forEach _squadMates;

		{
			[_x, SQUARE(MACRO_COLOUR_A100_ENEMY), true] call _fnc_drawUnit;
		} forEach _spottedEnemies;

		// Draw the vehicles
		{
			[_x # 0, _x # 1, SQUARE(MACRO_COLOUR_A100_FRIENDLY), true] call _fnc_drawVehicle;
		} forEach _teamVehicles;

		{
			[_x # 0, _x # 1, SQUARE(MACRO_COLOUR_A100_SQUAD), true] call _fnc_drawVehicle;
		} forEach _squadVehicles;

		{
			[_x # 0, _x # 1, SQUARE(MACRO_COLOUR_A100_ENEMY), false] call _fnc_drawVehicle;
		} forEach _enemyVehicles;
	};
}];
