/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LE]
		Handles the drawing of unit/vehicle icons on 2D controls, such as the main map.

		Called internally via the control's "Draw" EH.
	Arguments:
		0:	<CONTROL>	The map control to draw on
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

// No parameter validation, as this is an internal function
params ["_ctrlMap"];





// Define some macros
#define MACRO_BLINK_INTERVAL 0.5

// Set up some constants
private _c_iconUnit            = getMissionPath "res\images\icon_unit.paa";
private _c_iconUnitUnconscious = getMissionPath "res\images\icon_unit_unconscious.paa";
private _c_iconHeal            = getMissionPath "res\images\abilities\ability_heal.paa";

// Set up some variables
private _time               = time;
private _player             = player;
private _groupPly           = group _player;
private _spottedTimeVarName = format [QGVAR(spottedTime_%1), GVAR(side)];
private _mapAngle           = ctrlMapDir _ctrlMap;
private _blink              = ((_time mod (2 * MACRO_BLINK_INTERVAL)) < MACRO_BLINK_INTERVAL);
private _isUnconscious      = _player getVariable [QGVAR(isUnconscious), false];
private _isLowOnHealth      = (_player getVariable [QGVAR(health), 1] <= MACRO_UNIT_HEALTH_THRESHOLDLOW);

private _allUnits       = allUnits select {_x getVariable [QGVAR(isSpawned), false]};
private _squadMates     = units _groupPly select {alive _x and {vehicle _x == _x} and {_x getVariable [QGVAR(isSpawned), false]}};
private _teamMates      = (_allUnits select {side group _x == GVAR(side) and {vehicle _x == _x}}) - _squadMates;
private _spottedEnemies = _allUnits select {side group _x != GVAR(side) and {_time < _x getVariable [_spottedTimeVarName, 0]} and {vehicle _x == _x} and {[_x] call FUNC(unit_isAlive)}};

private _allVehicles   = GVAR(allVehicles) select {alive _x};
private _emptyVehicles = [];
private _squadVehicles = [];
private _teamVehicles  = [];
private _enemyVehicles = [];

private ["_crew", "_driver", "_crewUnit", "_groupX", "_groupIndex"];
{
	_crew     = crew _x select {[_x] call FUNC(unit_isAlive)};
	_driver   = driver _x;
	_crewUnit = [_driver, _crew param [0, objNull]] select (isNull _driver);

	if (isNull _crewUnit) then {
		_emptyVehicles pushBack _x;
		continue;
	};

	_groupX = group _crewUnit;
	if (side _groupX == GVAR(side)) then {

		// Edge case: AI drivers are in a separate group. Fetch the original one.
		if (_groupX getVariable [QGVAR(isVehicleGroup), false]) then {
			_groupIndex = _crewUnit getVariable [QGVAR(groupIndex), -1];
			_groupX     = missionNamespace getVariable [format [QGVAR(AIGroup_%1_%2), GVAR(side), _groupIndex], _groupX];
		};

		if (_groupX == _groupPly) then {
			_squadVehicles pushBack _x;
		} else {
			_teamVehicles pushBack _x;
		};
	} else {
		_crewUnit = _crew param [_crew findIf {_time < _x getVariable [_spottedTimeVarName, 0]}, objNull];

		if (!isNull _crewUnit) then {
			_enemyVehicles pushBack _x;
		};
	};
} forEach _allVehicles;

// Set up some functions
private ["_typeEnum", "_icon"];
private _fnc_drawUnit = {
	params ["_unit", "_colour"];

	if (_unit getVariable [QGVAR(isUnconscious), false]) then {

		if (_unit != _player and {GVAR(role) == MACRO_ENUM_ROLE_MEDIC} and {!_isUnconscious}) then {
			_ctrlMap drawIcon [
				_c_iconHeal,
				[_colour, SQUARE(MACRO_COLOUR_A100_WHITE)] select _blink,
				getPosVisual _unit,
				16,
				16,
				0,
				"",
				1
			];
		} else {
			_ctrlMap drawIcon [
				_c_iconUnitUnconscious,
				_colour,
				getPosVisual _unit,
				12,
				12,
				0,
				"",
				2
			];
		};

	} else {
		if (_unit getVariable [QGVAR(role), MACRO_ENUM_ROLE_INVALID] == MACRO_ENUM_ROLE_MEDIC and {_isUnconscious or {_isLowOnHealth}}) then {
			_ctrlMap drawIcon [
				_c_iconHeal,
				[_colour, SQUARE(MACRO_COLOUR_A100_WHITE)] select _blink,
				getPosVisual _unit,
				16,
				16,
				0,
				"",
				1
			];
		} else {
			_ctrlMap drawIcon [
				_c_iconUnit,
				_colour,
				getPosVisual _unit,
				12,
				12,
				_mapAngle + getDir _unit,
				"",
				2
			];
		};
	};
};

private _fnc_drawVehicle = {
	params ["_veh", "_colour"];

	_typeEnum = [typeOf _veh] call FUNC(veh_getType);
	_icon = [_typeEnum] call FUNC(ui_getVehTypeIcon);

	_ctrlMap drawIcon [
		_icon,
		_colour,
		getPosVisual _veh,
		24,
		24,
		_mapAngle + getDir _veh,
		"",
		1
	];
};





// DEBUG: When in overview mode, don't render any icons to keep the map clean
#ifdef MACRO_DEBUG_UI_MAP_OVERVIEWMODE
	if (true) exitWith {};
#endif





// Draw empty vehicles
{
	[_x, SQUARE(MACRO_COLOUR_A100_WHITE)] call _fnc_drawVehicle;
} forEach _emptyVehicles;


// Draw the units
{
	[_x, SQUARE(MACRO_COLOUR_A100_FRIENDLY)] call _fnc_drawUnit;
} forEach _teamMates;

{
	[_x, SQUARE(MACRO_COLOUR_A100_SQUAD)] call _fnc_drawUnit;
} forEach _squadMates;

{
	[_x, SQUARE(MACRO_COLOUR_A100_ENEMY)] call _fnc_drawUnit;
} forEach _spottedEnemies;


// Draw the vehicles
{
	[_x, SQUARE(MACRO_COLOUR_A100_FRIENDLY)] call _fnc_drawVehicle;
} forEach _teamVehicles;

{
	[_x, SQUARE(MACRO_COLOUR_A100_SQUAD)] call _fnc_drawVehicle;
} forEach _squadVehicles;

{
	[_x, SQUARE(MACRO_COLOUR_A100_ENEMY)] call _fnc_drawVehicle;
} forEach _enemyVehicles;
