/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles the assignment of the curator module to the current admin, aswell as ownership transfers due to admin
		logouts/disconnects.

		Only executed once by the server upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

if (!isServer) exitWith {};





// Set up some variables
MACRO_FNC_INITVAR(GVAR(gm_sys_handleCurator_EH), -1);

GVAR(gm_sys_handleCurator_nextUpdate) = -1;





removeMissionEventHandler ["EachFrame", GVAR(gm_sys_handleCurator_EH)];
GVAR(gm_sys_handleCurator_EH) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	private _time = time;
	if (_time > GVAR(gm_sys_handleCurator_nextUpdate)) then {

		// Assign the curator module to whoever is currently admin.
		// Relying on the editor-placed module introduces a bug when players respawn, where
		// the curator module is revoked from its owner when their corpse is removed.
		// Somehow, doing it by scripting command seems to prevent this issue from appearing.
		private "_admin";

		// In single player and locally hosted multiplayer, the player is always the admin.
		// Otherwise, check all players for whoever is logged in.
		if (!isMultiplayer or {hasInterface}) then {
			_admin = player;
		} else {
			private _players = allPlayers;
			_admin = _players param [_players findIf {admin owner _x >= 2}, objNull]; // Logged-in admin only
		};

		// Assign the ownership of the curator module to the designated admin (if there is one),
		// or blank it out to prevent demoted admins from retaining curator privileges
		private _curOwner = getAssignedCuratorUnit GVAR(curatorModule);

		if (_admin isNotEqualTo _curOwner) then {
			if (!isNull _curOwner) then {
				unassignCurator GVAR(curatorModule);
			};

			if (isNull _admin) then {
				diag_log "[CONQUEST] Removed curator privileges from previous owner";
			} else {
				diag_log format ["[CONQUEST] Assigned curator privileges to new admin (%1)", name _admin];

				_admin assignCurator GVAR(curatorModule);
			};
		};

		GVAR(gm_sys_handleCurator_nextUpdate) = _time + MACRO_GM_SYS_HANDLECURATOR_INTERVAL;
	};
}];
