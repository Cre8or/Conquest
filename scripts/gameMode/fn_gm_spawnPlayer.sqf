/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA][GE]
		Spawns the player on the given spawnpoint.

		Only executed on the client via server remote call.
	Arguments:
		0:	<OBJECT>	The spawnpoint on which the player should spawn
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

if (!hasInterface) exitWith {};

params [
	["_spawnPoint", objNull, [objNull]]
];

private _player = player;

// Check the params
if (!alive _player or {isNull _spawnPoint}) exitWith {};





// Assign the selected loadout and select the first available firearm
[_player, GVAR(side), GVAR(role)] call FUNC(lo_setRoleLoadout);
_player selectWeapon ([primaryWeapon _player, handgunWeapon _player] select (primaryWeapon _player == ""));

// Skip the weapon selection animation
_player switchMove "amovpercmstpslowwrfldnon";
[_player, "amovpercmstpslowwrfldnon"] remoteExecCall ["switchMove", -clientOwner, false];

// Enable spawn protection
_player allowDamage false;

// Reinitialise the player
[_player] remoteExecCall [QFUNC(unit_onInit), 0, false];

// Move the player to the spawn point
detach _player;
_player setPosWorld getPosWorld _spawnPoint;
_player setDir getDir _spawnPoint;

// Transition the respawn state
GVAR(gm_sys_handlePlayerRespawn_state) = MACRO_ENUM_RESPAWN_SPAWNED_FROZEN;
