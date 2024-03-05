/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Registers a vehicle spawn to a sector. Effects only apply when executed before server initialisation
		(ie when executed from a vehicle's init field).

		Only executed on the server upon initialisation.
	Arguments:
		0:      <OBJECT>	The vehicle to be added as a spawn; its type, position and orientation will
					be saved
		1:	<SIDE>		The side that should receive this vehicle
		2:	<NUMBER>	The respawn delay of this vehicle, in seconds
					(optional, default: -1)
		3:	<BOOLEAN>	Whether or not only players may use this vehicle (optional, default: false)
		4:	<ARRAY>		A list of vehicle-mounted weapons that should be removed upon spawning
					(optional, default: [])
		5:	<ARRAY>		A list of vehicle-mounted weapon magazines that should be removed upon
					spawning (optional, default: [])
		6:	<ARRAY>		A list of hitpoints that should be immune to damage (optional, default: [])
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"

params [
	["_veh", objNull, [objNull]],
	["_side", sideEmpty, [sideEmpty]],
	["_respawnDelay", -1, [-1]],
	["_playersOnly", false, [false]],
	["_forbiddenWeapons", [], [[]]],
	["_forbiddenMagazines", [], [[]]],
	["_invincibleHitPoints", [], [[]]]
];

if (!isServer or {!alive _veh}) exitWith {};





// Save the passed parameters onto the vehicle
_veh setVariable [QGVAR(side), _side, false];
_veh setVariable [QGVAR(respawnDelay), _respawnDelay, false];
_veh setVariable [QGVAR(playersOnly), _playersOnly, false];
_veh setVariable [QGVAR(forbiddenWeapons), _forbiddenWeapons, false];
_veh setVariable [QGVAR(forbiddenMagazines), _forbiddenMagazines, false];
_veh setVariable [QGVAR(invincibleHitPoints), _invincibleHitPoints, false];
