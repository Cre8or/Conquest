/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Returns a 2D dot product between two vectors, defined by 4 positions. The positions can be 2D or 3D,
		as the Z component is ignored.
		Optionally, the calculated vectors can be normalised, allowing the use of result to determine the
		angle between the two vectors.
	Arguments:
		0:	<ARRAY>		The first vector's start position
		1:	<ARRAY>		The first vector's end position
		2:	<ARRAY>		The second vector's start position
		3:	<ARRAY>		The second vector's end position
		4:	<BOOLEAN>	Whether or not the intermediate vectors should be normalised (optional,
					default: false)
	Returns:
			<NUMBER>	The 2D dot product between the two vectors
-------------------------------------------------------------------------------------------------------------------- */

params [
	["_vecStartA", [], [[]], [2,3]],
	["_vecEndA",   [], [[]], [2,3]],
	["_vecStartB", [], [[]], [2,3]],
	["_vecEndB",   [], [[]], [2,3]],
	["_shouldNormalise", false, [false]]
];

if (
	_vecStartA isEqualTo []
	or {_vecEndA isEqualTo []}
	or {_vecStartB isEqualTo []}
	or {_vecEndB isEqualTo []}
) exitWith {0};





private _vecA = [
	(_vecEndA # 0) - (_vecStartA # 0),
	(_vecEndA # 1) - (_vecStartA # 1),
	0
];
private _vecB = [
	(_vecEndB # 0) - (_vecStartB # 0),
	(_vecEndB # 1) - (_vecStartB # 1),
	0
];

if (_shouldNormalise) then {
	_vecA = vectorNormalized _vecA;
	_vecB = vectorNormalized _vecB;
};

_vecA vectorDotProduct _vecB;
