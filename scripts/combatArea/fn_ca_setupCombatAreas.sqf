/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Parses all combat areas and compiles the resulting global variables for use in other functions.

		Only executed once by all machines upon pre-initialisation.
	Arguments:
		(none)
	Returns:
		(none)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

// Set up some constants
private _mapSize = worldSize;
private _posCornersFar = [
	[-MACRO_CA_CORNEROFFSET, -MACRO_CA_CORNEROFFSET, 0],
	[_mapSize + MACRO_CA_CORNEROFFSET, -MACRO_CA_CORNEROFFSET, 0],
	[_mapSize + MACRO_CA_CORNEROFFSET, _mapSize + MACRO_CA_CORNEROFFSET, 0],
	[-MACRO_CA_CORNEROFFSET, _mapSize + MACRO_CA_CORNEROFFSET, 0],
	[-MACRO_CA_CORNEROFFSET, -MACRO_CA_CORNEROFFSET, 0]
];

// Set up some variables
MACRO_FNC_INITVAR(GVAR(ca_setupCombatAreas_EH_draw3D), -1);

private _data_east =
	#include "..\..\mission\combatArea\data_combatArea_east.inc"
;
private _data_resistance =
	#include "..\..\mission\combatArea\data_combatArea_resistance.inc"
;
private _data_west =
	#include "..\..\mission\combatArea\data_combatArea_west.inc"
;
private ["_curData", "_positions", "_normals", "_triangles"];





// Iterate over all sides
{
	// Fetch the corresponding data array
	_curData = switch (_x) do {
		case east:		{_data_east};
		case resistance:	{_data_resistance};
		case west:		{_data_west};
		default			{[]};
	};

	// If there is any data for this side, parse it
	if !(_curData isEqualTo []) then {

		// Add a Z component to all positions and normals so they can be used properly
		_positions = (_curData # 0) apply {_x + [0]};
		_normals   = (_curData # 1) apply {_x + [0]};

		// Compile the triangles array by fetching the position associated with each vertex ID
		_triangles = (_curData # 2) apply {
			_x apply {_positions # _x}
		};

		// Save the data onto the mission namespace
		missionNamespace setVariable [format [QGVAR(ca_%1), _x], _positions select [0, (count _positions) - 4], false]; // Drop the last 4 entries (map corners)
		missionNamespace setVariable [format [QGVAR(ca_%1_normals), _x], _normals, false];
		missionNamespace setVariable [format [QGVAR(ca_%1_triangles), _x], _triangles, false];
	};
} forEach [east, resistance, west];





// Debug rendering
removeMissionEventHandler ["Draw3D", GVAR(ca_setupCombatAreas_EH_draw3D)];
#ifdef MACRO_DEBUG_CA
	GVAR(ca_setupCombatAreas_EH_draw3D) = addMissionEventHandler ["Draw3D", {

		if (isGamePaused or {isNil QGVAR(side)}) exitWith {};

		private _CA     = missionNamespace getVariable [format [QGVAR(ca_%1), GVAR(side)], []];
		private _count  = count _CA;
		private _stepZ  = 10;
		private _bands  = 5;
		private _startZ = 0 max (round (((ASLtoATL getPosWorld cameraOn) # 2) / _stepZ - _bands / 2) * _stepZ);
		{
			drawLine3D [
				_x,
				_x vectorAdd [0,0,_startZ + _stepZ * _bands],
				[1,0,0,1],
				20
			];

			for "_i" from 0 to _bands do {
				drawLine3D [
					_x vectorAdd [0,0,_startZ + _i * _stepZ],
					(_CA # ((_forEachIndex + 1) mod _count)) vectorAdd [0,0,_startZ + _i * _stepZ],
					[1,0,0,1],
					50
				];
			};
		} forEach _CA;
	}];
#endif
