/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Generates context-dependant tutorial hints to be shown to the player, depending on the current game state.

		Only executed once by the client upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

if (!hasInterface) exitWith {};





MACRO_FNC_INITVAR(GVAR(gm_sys_tutorialHints_EH), -1);

MACRO_FNC_INITVAR(GVAR(gm_sys_handlePlayerRespawn_state), MACRO_ENUM_RESPAWN_INIT); // Interfaces with gm_sys_handlePlayerRespawn

GVAR(gm_sys_tutorialHints_nextUpdate) = -1;
GVAR(gm_sys_tutorialHints_activeHint) = MACRO_ENUM_TUTORIALHINT_INVALID;
GVAR(gm_sys_tutorialHints_startTime)  = -1;
GVAR(gm_sys_tutorialHints_expiration) = -1;

GVAR(gm_sys_tutorialHints_hashmap) = createHashMap;





removeMissionEventHandler ["EachFrame", GVAR(gm_sys_tutorialHints_EH)];
GVAR(gm_sys_tutorialHints_EH) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused or {GVAR(missionState) > MACRO_ENUM_MISSION_LIVE}) exitWith {};

	private _time = time;
	if (_time < GVAR(gm_sys_tutorialHints_nextUpdate)) exitWith {};

	private _player = player;
	private _alive  = [_player] call FUNC(unit_isAlive);

	GVAR(gm_sys_tutorialHints_nextUpdate) = _time + MACRO_GM_SYS_TUTORIALHINTS_INTERVAL;

	// Hint deactivation
	if (
		_time > GVAR(gm_sys_tutorialHints_expiration)
		and {GVAR(gm_sys_tutorialHints_activeHint) != MACRO_ENUM_TUTORIALHINT_INVALID}
	) then {
		GVAR(gm_sys_tutorialHints_activeHint) = MACRO_ENUM_TUTORIALHINT_INVALID;
	};





	// Role-specific ability hints (upon respawn)
	#include "tutorialHints\subSys_roleAbilities.sqf";

	// Spawn menu toggling
	#include "tutorialHints\subSys_reopenSpawnMenu.sqf";

}];
