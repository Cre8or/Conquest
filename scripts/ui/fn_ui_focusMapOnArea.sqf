/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LE]
		Sets the center and zoom level of the given map control such that it is focused on the specified area.
		The area is defined as a 2D bounding box via two corner positions (bottom-left and top-right).
		Additionally, a margin can be added to pad the edges.

		As long as the bounding box is fully within the world coordinates, it is guaranteed to be within the
		map's rendered area.
	Arguments:
		0:	<CONTROL>	The map control to be focused
		1:	<ARRAY>		The bottom left crner of the bounding box (2D/3D position)
		2:	<ARRAY>		The top right corner of the bounding box (2D/3D position)
		3:	<NUMBER>	The percentage of padding to be added (optional, default: 0)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

params [
	["_ctrlMap", controlNull, [controlNull]],
	["_posBL", [], [[]], 3],
	["_posTR", [], [[]], 3],
	["_padding", 0, [0]]
];

if (isNull _ctrlMap or {_posBL isEqualTo []} or {_posTR isEqualTo []}) exitWith {};





// Set up some variables
(_posTR vectorDiff _posBL) params ["_boundingBoxWidth", "_boundingBoxHeight"];

// Calculate the overall map scale factor.
// This expresses the UI width of a map distance of 1m at a normalised scale of 1.0,
// which depends on screen resolution, UI scale and possibly even more factors.
// By querying world coordinates from the map, we effectively let the engine take
// these factors out of the equation for us.
private _c_mapScaleFactor = ((_ctrlMap ctrlMapWorldToScreen [1,0,0]) # 0 - (_ctrlMap ctrlMapWorldToScreen [0,0,0]) # 0) * ctrlMapScale _ctrlMap;

private _ctrlPos = ctrlPosition _ctrlMap;
private _mapWidth = _ctrlPos # 2;
private _mapHeight = _ctrlPos # 3 * 0.75;	// Corrected for the safezone's 4:3 aspect ratio

// Focus the map
private _longestSideRatio = (_boundingBoxWidth / _mapWidth) max (_boundingBoxHeight / _mapHeight);
private _scale = (1 + (_padding max 0)) * _c_mapScaleFactor * _longestSideRatio;
private _posCenter = (_posBL vectorAdd _posTR) vectorMultiply 0.5;

_ctrlMap ctrlMapAnimAdd [0, _scale, _posCenter];
ctrlMapAnimCommit _ctrlMap;
