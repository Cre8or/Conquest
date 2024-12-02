/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Registers a vehicle spawnpoint. The spawnpoint must be linked to a sector.
		Vehicle spawnpoints can further be customised by setting a non-default respawn delay, or disallowing AI units
		from using the spawned vehicle.

		Only executed on the server upon initialisation.
	Arguments:
		0:	<OBJECT>	The vehicle spawnpoint
		1:	<STRING>	The vehicle enumeration type to spawn
		2:	<NUMBER>	The respawn delay, in seconds (optional, default: -1)
		3:	<BOOLEAN>	Whether or not only players may use this vehicle (optional, default: false)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_spawnPoint", objNull, [objNull]],
	["_enum", "", [""]],
	["_respawnDelay", -1, [-1]],
	["_playersOnly", false, [false]]
];

if (!isServer or {isNull _spawnPoint}) exitWith {};





// Default value
if (_respawnDelay < 0) then {
	_respawnDelay = MACRO_SECTOR_VEH_RESPAWNDELAY;
};

// Save the passed parameters onto the spawnpoint for processing by gm_postInit
_spawnPoint setVariable [QGVAR(enum), _enum, false];
_spawnPoint setVariable [QGVAR(respawnDelay), _respawnDelay, false];
_spawnPoint setVariable [QGVAR(playersOnly), _playersOnly, false];
