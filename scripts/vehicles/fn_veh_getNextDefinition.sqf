/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[S]
		Returns the next vehicle definition for a given side and vehicle type enumeration. Definitions are set in the
		faction's files data.
		Used to set up spawn data for every sector's vehicle spawnpoint.

		Only executed once by the server upon initialisation.
	Arguments:
		0:	<SIDE>		The concerned side
		1:	<STRING>	The vehicle type enumeration (see macros.inc)
	Returns:
			<ARRAY>		Vehicle definition
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_side", sideEmpty, [sideEmpty]],
	["_enum", "", [""]]
];
_enum = toUpper _enum;

if (!isServer) exitWith {[]};





private _vehTypesCache      = missionNamespace getVariable [format [QGVAR(vehTypesCache_%1), _side], createHashMap];
private _vehTypesIndexCache = missionNamespace getVariable [format [QGVAR(vehTypesIndexCache_%1), _side], createHashMap];
private _definitions        = _vehTypesCache getOrDefault [_enum, []];

// Exit early if no definitions exist for this type enum
if (_definitions isEqualTo []) exitWith {[]};

// Fetch the next definition and increment the index
(_vehTypesIndexCache get _enum) params ["_indexCurrent", "_indexLast"];
private _definition = _definitions param [_indexCurrent, []];

if (_indexCurrent < _indexLast) then {
	_indexCurrent = _indexCurrent + 1;
} else {
	_indexCurrent = 0;
};

_vehTypesIndexCache set [_enum, [_indexCurrent, _indexLast]];





(+_definition);
