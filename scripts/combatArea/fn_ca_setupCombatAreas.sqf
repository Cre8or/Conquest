/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Parses all combat areas and compiles the resulting global variables for use in other functions.

		Only executed once by all machines upon pre-initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

MACRO_FNC_INITVAR(GVAR(ca_setupCombatAreas_EH_draw3D), -1);

private _allCombatAreas = [ // Fixed order by framework convention
	[east,       "mission\combatArea\data_combatArea_opfor.inc"],
	[resistance, "mission\combatArea\data_combatArea_indfor.inc"],
	[west,       "mission\combatArea\data_combatArea_blufor.inc"]
];
private ["_data", "_positions", "_normals", "_triangles"];





// Iterate over all sides
{
	_x params ["_side", "_filePath"];

	if (!fileExists _filePath) then {
		private _str = format ["[CONQUEST] (ca_setupCombatAreas) ERROR: File not found! (%1)", _filePath];
		systemChat _str;
		diag_log _str;
		continue;
	};

	_data = call compile preprocessFileLineNumbers _filePath;
	if !(_data isEqualType []) then {
		private _str = format ["[CONQUEST] (ca_setupCombatAreas) ERROR: Combat Area data is invalid! (%1)", _filePath];
		systemChat _str;
		diag_log _str;
		continue;
	};

	if (_data isEqualTo []) then {
		continue;
	};

	// Add a Z component to all positions and normals so they can be used properly
	_positions = (_data # 0) apply {_x + [0]};
	_normals   = (_data # 1) apply {_x + [0]};

	// Compile the triangles array by fetching the position associated with each vertex ID
	_triangles = (_data # 2) apply {
		_x apply {_positions # _x}
	};

	// Save the data for use across the framework
	missionNamespace setVariable [format [QGVAR(ca_%1), _side], _positions select [0, (count _positions) - 4], false]; // Drop the last 4 entries (map corners)
	missionNamespace setVariable [format [QGVAR(ca_%1_normals), _side], _normals, false];
	missionNamespace setVariable [format [QGVAR(ca_%1_triangles), _side], _triangles, false];
} forEach _allCombatAreas;





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
