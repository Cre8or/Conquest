/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Parses a given number using a provided array of bit flags. Returns a boolean for
		each flag indicating whether or not it is present.
	Arguments:
		0:	<NUMBER>	The number to be parsed/decomposed into flags. Must always be smaller than
					(or equal to) the biggest bit flag (see #2)!
		1:	<ARRAY>		An array of numbers representing the flags to try for (must be in decreasing
					order, e.g. [8,4,2,1])
	Returns:
			<ARRAY>		An array of booleans, where each boolean indicates the presence of its
					associated bit flag
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_num", 0, [0]],
	["_flags", [], [[]]]
];

// If the number is less than 0, or the flags array is empty, exit and return an empty array
if (_num < 0 or {_flags isEqualTo []}) exitWith {[]};





// Set up some variables
private _numNew = _num;
private _result = [];





// Decompose the number
{
	_numNew = _num % _x;

	// If the number changed, this flag is present
	if (_num != _numNew) then {
		_result pushBack true;
		_num = _numNew;

	// Otherwise, this flag is missing
	} else {
		_result pushBack false;
	};
} forEach _flags;

// Return the result
_result;
