/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Registers a vehicle spawnpoint. The spawnpoint must be linked to a sector.

		To support factions which do not have candidate vehicles for every enumeration type, the provided enumeration
		value can be replaced with an array of values. If the first vehicle enumeration has no candidates, the next
		enumeration is considered (then the next one, and so on) until a vehicle can be spawned. If no candidates can
		be found, the spawn point won't spawn any vehicles for that faction.

		Vehicle spawnpoints can further be customised by setting a non-default respawn delay, or disallowing AI units
		from using the spawned vehicle. Additionally, an initial spawn delay can be set (in seconds), counting from
		the mission start.

		Only executed on the server upon initialisation.
	Arguments:
		0:  <OBJECT>    The vehicle spawnpoint
		1:  <STRING>    The vehicle enumeration type to spawn
		    OR:
		    <ARRAY>     A list of vehicle enumerations to spawn
		2:  <NUMBER>    The respawn delay, in seconds (optional, default: -1)
		3:  <BOOLEAN>   Whether or not only players may use this vehicle (optional, default: false)
		4:  <NUMBER>    Initial spawn delay (optional, default: -1)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_spawnPoint", objNull, [objNull]],
	["_enums", "", ["", []]],
	["_respawnDelay", -1, [-1]],
	["_playersOnly", false, [false]],
	["_initialSpawnDelay", -1, [-1]]
];

if (!isServer or {isNull _spawnPoint}) exitWith {};





if (_enums isEqualType "") then {
	_enums = [_enums];
};

// Default value
if (_respawnDelay < 0) then {
	_respawnDelay = MACRO_SECTOR_VEH_RESPAWNDELAY;
};

// Save the passed parameters onto the spawnpoint for processing by gm_postInit
_spawnPoint setVariable [QGVAR(enums), _enums, false];
_spawnPoint setVariable [QGVAR(respawnDelay), _respawnDelay, false];
_spawnPoint setVariable [QGVAR(playersOnly), _playersOnly, false];
_spawnPoint setVariable [QGVAR(initialSpawnDelay), _initialSpawnDelay, false];
