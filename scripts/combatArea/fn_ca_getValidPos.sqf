/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Checks if the given position is within the specified side's combat area, and - if not - returns a new
		position that is within the combat area (near the node closest to the original position).
		If no valid position could be found, an empty position is returned ([0,0,0]).
	Arguments:
		0:	<ARRAY>		The original position
		1:	<SIDE>		The side whose combat area should be used
		2:	<BOOLEAN>	Whether the new position's Z component should be corrected (ASL) (optional,
					default: false)
	Returns:
			<ARRAY>		The resulting position
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_pos", [], [[]]],
	["_side", sideEmpty, [sideEmpty]],
	["_fixHeightASL", false, [false]]
];

if (_pos isEqualTo [] or {_side == sideEmpty}) exitWith {[0,0,0]};





// If the position is already in the side's combat area, nothing needs to be done
if ([_pos, _side] call FUNC(ca_isInCombatArea)) exitWith {_pos};

// Otherwise, we need to correct it
private _combatArea = missionNamespace getVariable [format [QGVAR(ca_%1), _side], []];
private _pos2D      = +_pos; // Deep copy
_pos2D set [2, 0];

private _minDistSqr = 9e9 ^ 2;
private ["_nearestPos", "_distSqrX", "_index"];

{
	_distSqrX = _pos2D distanceSqr _x;

	if (_distSqrX < _minDistSqr) then {
		_minDistSqr = _distSqrX;
		_nearestPos = _x;
		_index      = _forEachIndex;
	};
} forEach _combatArea;

// Nudge the position into the combat area using the closest node's normal
private _posNew = _nearestPos vectorAdd (
	missionNamespace getVariable [format [QGVAR(ca_%1_normals), _side], []] param [_index, [0, 0, 0]]
);

// Fix the height
if (_fixHeightASL) then {
	_posNew set [2, (ASLtoATL _pos) # 2];
	_posNew = ATLtoASL _posNew;
} else {
	_posNew set [2, _pos # 2];
};

_posNew;
