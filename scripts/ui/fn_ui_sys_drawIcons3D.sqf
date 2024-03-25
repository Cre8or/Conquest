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

	if (isGamePaused) exitWith {};

	private _player = player;

	if (dialog or {!([_player, true] call FUNC(unit_isAlive))}) exitWith {};

	// Set up some constants
	private _c_maxDistSqr  = MACRO_UI_ICONS3D_MAXDISTANCE_INF ^ 2;
	private _c_maxAngleSqr = (0.2 * getObjectFOV cameraOn) ^ 2; // Minimum angle within which unit names should be displayed
	private _c_uiScale = getResolution # 5;
	private _c_spottedTimeVarName = format [QGVAR(spottedTime_%1), GVAR(side)];

	// Set up some variables
	private _time     = time;
	private _vehPly   = vehicle _player;
	private _groupPly = group _player;
	private _posPly   = AGLtoASL positionCameraToWorld [0,0,0];
	private _dirPly   = (AGLtoASL positionCameraToWorld [0,0,1]) vectorDiff _posPly;
	private _blink    = ((_time mod (2 * MACRO_BLINK_INTERVAL)) < MACRO_BLINK_INTERVAL);
	private _freeLook = (inputAction "lookAround" > 0);
	private _isMedic  = (GVAR(role) == MACRO_ENUM_ROLE_MEDIC); // Needed to include unconscious units in the aggregation

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
			if (_time < _x getVariable [_c_spottedTimeVarName, 0]) then {
				_spottedEnemies pushBack [_x, _posX, _distX];
			};
		};
	} forEach (allUnits select {
		_x == vehicle _x
		and {[_x, _isMedic] call FUNC(unit_isAlive)}
		and {_x != _player}
	});



	// Handle role-specific icon drawing
	switch (GVAR(role)) do {

		case MACRO_ENUM_ROLE_SUPPORT: {
			#include "drawIcons3D\ui_unitIcons_support.sqf"
		};

		case MACRO_ENUM_ROLE_ENGINEER: {
			#include "drawIcons3D\ui_vehicleIcons_engineer.sqf"
		};

		case MACRO_ENUM_ROLE_MEDIC: {
			#include "drawIcons3D\ui_unitIcons_medic.sqf"
		};
	};



	// Handle role-agnostic unit and vehicle icon drawing
	#include "drawIcons3D\ui_unitIcons.sqf"

	#include "drawIcons3D\ui_vehicleIcons.sqf"
}];
