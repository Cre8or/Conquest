/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA]
		Returns a 2D-projected (top down) avoidance force based on the specified vehicle's and target's
		parameters.
		The avoidance radius should be the largest bounding sphere radius of the two objects.
		The returned force is expressed as a 3D vector for easier handling, but the Z component is always 0.
	Arguments:
		0:	<ARRAY>		The vehicle's position
		1:	<ARRAY>		The target object's position
		2:	<ARRAY>		The vehicle's velocity vector
		3:	<ARRAY>		The target's velocity vector
		4:	<NUMBER>	The avoidance radius (in meters)
		6:	<NUMBER>	An overall force multiplier (optional, default: 1)
	Returns:
			<ARRAY>		The resulting avoidance force
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_posA", [], [[]], 3],
	["_posB", [], [[]], 3],
	["_velA", [0,0,0], [[]], 3],
	["_velB", [0,0,0], [[]], 3],
	["_radius", -1, [-1]],
	["_forceMul", 1, [1]]
];

// Validation
if (_posA isEqualTo [] or {_posB isEqualTo []}) exitWith {[0, 0, 0]};
if (_radius <= 0) exitWith {[0, 0, 0]};





// Set up some variables
private _offset  = _posB vectorDiff _posA;
private _velDiff = _velA vectorDiff _velB;

// Ray-sphere intersection
([_posA, _velDiff, _posB, _radius] call FUNC(math_raySphereIntersection)) params ["_distThrough", "_distToIn"];

if (_distThrough <= 0) exitWith {[0, 0, 0]};

// Coordinate system
private _vecForward = vectorNormalized _offset;
private _vecUp      = [0, 0, 1];
private _vecRight   = vectorNormalized (_vecForward vectorCrossProduct _vecUp);

// The resulting avoidance force is a lateral vector that linearily scales with decreasing distance
private _force = _vecRight vectorMultiply ([1, -1] select (_vecRight vectorDotProduct _velDiff >= 0));
private _dist = vectorMagnitude (_offset vectorDiff _velDiff);
_force = _force vectorMultiply ((_dist / 5 - _radius) / _radius min 0);

_force;
