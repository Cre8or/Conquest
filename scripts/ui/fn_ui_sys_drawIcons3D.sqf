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
MACRO_FNC_INITVAR(GVAR(ui_sys_drawIcons3D_EH), -1);

// Define some macros
#define MACRO_BLINK_INTERVAL 0.5





removeMissionEventHandler ["Draw3D", GVAR(ui_sys_drawIcons3D_EH)];
GVAR(ui_sys_drawIcons3D_EH) = addMissionEventHandler ["Draw3D", {

	// Don't render if the game is paused or if the mission is over
	if (isGamePaused or {GVAR(missionState) > MACRO_ENUM_MISSION_LIVE}) exitWith {};

	private _player = player;

	if (dialog or {!([_player, true] call FUNC(unit_isAlive))}) exitWith {};

	// Set up some constants
	private _c_maxDistSqr         = MACRO_UI_ICONS3D_MAXDISTANCE_INF ^ 2;
	private _c_maxAngleSqr        = (0.2 * getObjectFOV cameraOn) ^ 2; // Minimum angle within which unit names should be displayed
	private _c_uiScale            = getResolution # 5;
	private _c_spottedTimeVarName = format [QGVAR(spottedTime_%1), GVAR(side)];

	// Set up some variables
	private _time       = time;
	private _vehPly     = vehicle _player;
	private _groupPly   = group _player;
	private _posPly     = AGLtoASL positionCameraToWorld [0,0,0];
	private _dirPly     = (AGLtoASL positionCameraToWorld [0,0,1]) vectorDiff _posPly;
	private _blink      = ((_time mod (2 * MACRO_BLINK_INTERVAL)) < MACRO_BLINK_INTERVAL);
	private _freeLook   = (inputAction "lookAround" > 0);
	private _iconsQueue = [];

	scopeName QGVAR(ui_sys_drawIcons3D);



	// Aggregate the units data
	private _teamMates      = [];
	private _squadMates     = [];
	private _spottedEnemies = [];
	private ["_posX", "_distX", "_groupX"];
	{
		_posX   = unitAimPositionVisual _x;
		_distX  = _posPly distanceSqr AGLtoASL _posX;
		_groupX = group _x;

		if (side _groupX == GVAR(side)) then {
			if (_groupX == _groupPly) then {
				_squadMates pushBack [_x, _posX, _distX];
			} else {
				_teamMates pushBack [_x, _posX, _distX];
			};
		} else {
			if (_time < _x getVariable [_c_spottedTimeVarName, 0] and {!(_x getVariable [QGVAR(isUnconscious), false])}) then {
				_spottedEnemies pushBack [_x, _posX, _distX];
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
	private ["_crew", "_unitX", "_groupX", "_groupIndex"];
	{
		if (_x == _vehPly) then {
			continue;
		};

		_crew  = crew _x select {[_x] call FUNC(unit_isAlive)};
		_unitX = driver _x;

		if (isNull _unitX) then {
			_unitX = _crew param [0, objNull];
		};

		// Empty vehicles
		if (isNull _unitX) then {
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

			if (_groupX == _groupPly) then {
				_squadVehicles pushBack [_x, _unitX];
			} else {
				_teamVehicles pushBack [_x, _unitX];
			};
		} else {
			_unitX = _crew param [_crew findIf {_time < _x getVariable [_c_spottedTimeVarName, 0]}, objNull];

			if (!isNull _unitX) then {
				_spottedVehicles pushBack [_x, _unitX];
			};
		};
	} forEach _allVehicles;



	// Handle role-specific icon drawing
	private ["_renderData"];

	#include "drawIcons3D\icons3D_role_medic.sqf"

	#include "drawIcons3D\icons3D_role_support.sqf"

	//#include "drawIcons3D\icons3D_role_engineer.sqf"



	// Handle role-agnostic unit and vehicle icon drawing
	#include "drawIcons3D\icons3D_vehicles.sqf"

	#include "drawIcons3D\icons3D_units.sqf"



	// Render the queued icons, in reverse order (3D icons render back to front)
	{
		drawIcon3D _x;
	} forEachReversed _iconsQueue;
}];
