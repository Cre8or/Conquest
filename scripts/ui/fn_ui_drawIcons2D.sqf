/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LE]
		Handles the drawing of unit/vehicle icons on 2D controls, such as the main map.

		Called via the map control's "Draw" EH.
	Arguments:
		0:	<CONTROL>	The map control to draw on
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params ["_ctrlMap"];





// Define some macros
#define MACRO_BLINK_INTERVAL 0.5

// Set up some constants
private _c_spottedTimeVarName = format [QGVAR(spottedTime_%1), GVAR(side)];

// Set up some variables
private _time       = time;
private _player     = player;
private _groupPly   = group _player;
private _vehPly     = vehicle _player;
private _mapAngle   = ctrlMapDir _ctrlMap;
private _blink      = ((_time mod (2 * MACRO_BLINK_INTERVAL)) < MACRO_BLINK_INTERVAL);
private _iconsQueue = [];

scopeName QGVAR(ui_drawIcons2D);



// Aggregate the units data
private _teamMates      = [];
private _squadMates     = [];
private _spottedEnemies = [];
private ["_posX", "_groupX"];
{
	_posX   = getPosWorld _x;
	_groupX = group _x;

	if (side _groupX == GVAR(side)) then {
		if (_groupX == _groupPly) then {
			_squadMates pushBack [_x, _posX];
		} else {
			_teamMates pushBack [_x, _posX];
		};
	} else {
		if (_time < _x getVariable [_c_spottedTimeVarName, 0] and {!(_x getVariable [QGVAR(isUnconscious), false])}) then {
			_spottedEnemies pushBack [_x, _posX];
		};
	};
} forEach (allUnits select {
	_x == vehicle _x
	and {[_x, true] call FUNC(unit_isAlive)}
	and {_x != _player}
});



// Aggregate the vehicles data
private _allVehicles     = GVAR(allVehicles) select {alive _x};
private _teamVehicles    = [];
private _squadVehicles   = [];
private _spottedVehicles = [];
private _emptyVehicles   = [];
private ["_crew", "_unitX", "_groupX", "_groupIndex"];
{
	_posX  = getPosWorld _x;
	_crew  = crew _x select {[_x] call FUNC(unit_isAlive)};
	_unitX = driver _x;

	if (isNull _unitX) then {
		_unitX = _crew param [0, objNull];
	};

	// Empty vehicles
	if (isNull _unitX) then {
		if (_x getVariable [QGVAR(side), sideEmpty] == GVAR(side)) then {
			_emptyVehicles pushBack [_x, _posX];
		};
		continue;
	};

	// Manned vehicles
	_groupX = group _unitX;
	if (side _groupX == GVAR(side)) then {

		// Edge case: AI drivers are in a separate group. Fetch the original one.
		if (_groupX getVariable [QGVAR(isVehicleGroup), false]) then {
			_groupIndex = _unitX getVariable [QGVAR(groupIndex), -1];
			_groupX     = missionNamespace getVariable [format [QGVAR(AIGroup_%1_%2), GVAR(side), _groupIndex], _groupX];
		};

		if (_x == _vehPly or {_groupX == _groupPly}) then {
			_squadVehicles pushBack [_x, _posX];
		} else {
			_teamVehicles pushBack [_x, _posX];
		};
	} else {
		_unitX = _crew param [_crew findIf {_time < _x getVariable [_c_spottedTimeVarName, 0]}, objNull];

		if (!isNull _unitX) then {
			_spottedVehicles pushBack [_x, _posX];
		};
	};
} forEach _allVehicles;



// Handle role-specific icon drawing
private ["_renderData", "_colour"];

#include "drawIcons2D\icons2D_role_support.sqf"

#include "drawIcons2D\icons2D_role_medic.sqf"

//#include "drawIcons2D\icons2D_role_engineer.sqf"



// Handle role-agnostic unit and vehicle icon drawing
#include "drawIcons2D\icons2D_vehicles.sqf"

#include "drawIcons2D\icons2D_units.sqf"



// Render the queued icons, in reverse order
{
	_ctrlMap drawIcon _x;
} forEachReversed _iconsQueue;
