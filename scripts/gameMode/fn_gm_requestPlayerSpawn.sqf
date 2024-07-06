/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Checks if the specified player can spawn at the requested sector.
		While clients perform the spawn logic themselves, the check that allows them to spawn is performed by
		the server. As such, this function acts as a request form, rather than a fixed operation.

		Only executed on the server via remote call.
	Arguments:
		0:	<OBJECT>	The player to be spawned
		1:	<OBJECT>	The sector on which the player should spawn
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

if (!isServer) exitWith {};

params [
	["_unit", objNull, [objNull]],
	["_sector", objNull, [objNull]]
];

if (!isPlayer _unit or {!alive _unit} or {_sector getVariable [QGVAR(letter), ""] == ""}) exitWith {};





// Set up some variables
private _sideUnit   = _unit getVariable [QGVAR(side), sideEmpty];
private _sideSector = _sector getVariable [QGVAR(side), sideEmpty];





if (_sideUnit == _sideSector and {[_sideUnit] call FUNC(gm_isSidePlayable)}) then {

	// If this sector has any spawnpoints...
	private _spawnPoints = _sector getVariable [format [QGVAR(spawnPoints_%1), _sideUnit], []];
	if (_spawnPoints isNotEqualTo []) then {

		// ...spawn the player on a random one.
		[selectRandom _spawnPoints] remoteExecCall [QFUNC(gm_spawnPlayer), _unit, false];
	};
};
