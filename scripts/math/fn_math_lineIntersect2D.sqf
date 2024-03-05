/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Checks if two lines intersect in 2D space. The lines are determined from two pairs of start and end
		positions.
		NOTE: This function checks intersections in 2D space, meaning the Z component is ignored.

		Adapted from: http://stackoverflow.com/a/565282/786339
	Arguments:
		0:	<ARRAY>		The first line's start position
		1:	<ARRAY>		The first line's end position
		2:	<ARRAY>		The second line's start position
		3:	<ARRAY>		The second line's end position
	Returns:
			<BOOLEAN>	True if the lines intersect, otherwise false
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_pos1Start", [0,0,0], [[]]],
	["_pos1End", [0,0,0], [[]]],
	["_pos2Start", [0,0,0], [[]]],
	["_pos2End", [0,0,0], [[]]]
];





// Set up some variables
private _vec1     = _pos1End vectorDiff _pos1Start;
private _vec2     = _pos2End vectorDiff _pos2Start;
private _vecStart = _pos2Start vectorDiff _pos1Start;

private _numerator   = (_vecStart vectorCrossProduct _vec1) # 2;
private _denominator = (_vec1 vectorCrossProduct _vec2) # 2;

// Check for parallelism
if (_denominator == 0) exitWith {false};

private _coefU = _numerator / _denominator; // 0.5
private _coefT = ((_vecStart vectorCrossProduct _vec2) # 2) / _denominator;

// Check if the resulting vectors' signs match
(
	_coefT >= 0
	and {_coefT <= 1}
	and {_coefU >= 0}
	and {_coefU <= 1}
);
