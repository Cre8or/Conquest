/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Tests if a ray intersects with the specified sphere.
		If it does, returns an array containing the crossed distance through the sphere, aswell as the distance
		from the ray origin to the surface of the sphere.
		Otherwise, returns [-1, -1].
	Arguments:
		0:	<ARRAY>		The ray's origin
		1:	<ARRAY>		The ray's direction
		2:	<ARRAY>		The sphere's origin
		3:	<NUMBER>	The sphere's radius
	Returns:
		0:	<NUMBER>	The crossed distance through the sphere
		1:	<NUMBER>	The ray origin's distance to the sphere's surface
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_rayOrigin", [], [[]], 3],
	["_rayDir", [], [[]], 3],
	["_sphereOrigin", [], [[]], 3],
	["_sphereRadius", -1, [-1]]
];

if (_rayOrigin isEqualTo [] or {_rayDir isEqualTo []} or {_sphereOrigin isEqualTo []} or {_sphereRadius <= 0}) exitWith {[-1, -1]};





// Define some macros
#define FLOAT_MAX 3.40282346639e+38 // Using 32-bit floats

// Set up some variables
private _offset = _rayOrigin vectorDiff _sphereOrigin;

private _a = vectorMagnitudeSqr _rayDir;
private _b = 2 * (_offset vectorDotProduct _rayDir);
private _c = (vectorMagnitudeSqr _offset) - _sphereRadius ^ 2;
private _d = _b ^ 2 - (4 * _a * _c);





// Number of intersections:
// * 0 when d < 0;
// * 1 when d = 0 (boundary);
// * 2 when d > 0;
// Here we only care about the 2-intersections case
if (_d <= 0) exitWith {[-1, -1]};

private _s = sqrt _d;
private _distToOut = FLOAT_MAX min (-_b + _s) / (2 * _a);

// If _distToOut is negative, the exit intersection is behind the ray's origin.
// We treat this case as "no intersection".
if (_distToOut < 0) exitWith {[-1, -1]};



private _distToIn = -FLOAT_MAX max ((-_b - _s) / (2 * _a));

[_distToOut - _distToIn, _distToIn];
