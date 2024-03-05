/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Returns a random position on a circle around the given position, within the specified radius.
		The returned position's height depends on the used strategy:
		0:	Match the same heightASL as the input position, (no transformation, ignores terrain/water)
		1:	Match the same heightAGL as the input position (only follows terrain)
		2:	Match the same heightAGL as the input position (follows terrain and water)

	Arguments:
		0:	<ARRAY>		The original position (center of the disc) in format posWorld
		1:	<NUMBER>	The radius of the random circle, in meters
		2:	<NUMBER>	The strategy for the returned position's height (optional, default: 2)
	Returns:
			<ARRAY>		A random position on the circle (format posWorld)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

// Fetch our params
params [
	["_posCenter", [], [[]], [3]],
	["_radius", -1, [-1]],
	["_strategy", 2, [2]]
];

if (_posWorld isEqualTo []) exitWith {[0,0,0]};





// Set up some variables
private _dir = random 360;
private _radiusRand = (_radius max 0) * random 1; // Clusters values around the center. For a more "uniform" distribution, use: sqrt random 1
private	_posResult = _posCenter vectorAdd ([cos _dir, sin _dir, 0] vectorMultiply _radiusRand);

// Optionally transform the returned height, depending on the used strategy
switch (_strategy) do {
	case 1: {
		private _heightAGL = (ASLtoAGL _posCenter) # 2;

		_posResult set [2, _heightAGL + getTerrainHeightASL _posResult];
	};
	case 2: {
		private _heightAGL = (ASLtoAGL _posCenter) # 2;

		_posResult set [2, _heightAGL + (0 max getTerrainHeightASL _posResult)];
	};
};

_posResult;
