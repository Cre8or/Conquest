/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Returns a 2D bounding box spanning the area covered by the given positions. The bounding box is
		expressed as an array consisting of its bottom-left and top-right corner positions.

		NOTE: While this function returns 3D positions, the Z component is always 0, enabling the use of
		vector scripting commands (which require 3 components).
	Arguments:
		0	<ARRAY>		The positions to be covered by the bounding box (2D/3D position)
	Returns:
		0:	<ARRAY>		The bottom-left corner of the bounding box (3D position)
		1:	<ARRAY>		The bottomtop-right corner of the bounding box (3D position)
-------------------------------------------------------------------------------------------------------------------- */

// Fetch our params
params [
	["_positions", [], [[]]]
];

// If no positions were passed, exit and return default values
if (_positions isEqualTo []) exitWith {[[0,0,0], [0,0,0]]};





// Set up some variables
private _posBottom = 999999;
private _posLeft   = 999999;
private _posTop    = -999999;
private _posRight  = -999999;





// Calculate the edges of the bounding box
{
	_posLeft   = _posLeft min (_x # 0);
	_posRight  = _posRight max (_x # 0);
	_posBottom = _posBottom min (_x # 1);
	_posTop    = _posTop max (_x # 1);
} forEach _positions;

// Return the bounding box
[
	[_posLeft, _posBottom, 0],
	[_posRight, _posTop, 0]
];
