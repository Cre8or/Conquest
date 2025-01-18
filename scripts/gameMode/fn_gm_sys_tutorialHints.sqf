/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Generates context-dependant tutorial tips to be shown to the player, depending on the current game state.

		Only executed once by the client upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"
#include "..\..\res\macros\fnc_addHTMLColour.inc"

if (!hasInterface) exitWith {};





MACRO_FNC_INITVAR(GVAR(gm_sys_tutorialHints_EH), -1);

GVAR(gm_sys_tutorialHints_nextUpdate) = -1;
GVAR(gm_sys_tutorialHints_hashmap_roleAbilities) = createHashMap;





removeMissionEventHandler ["EachFrame", GVAR(gm_sys_tutorialHints_EH)];
GVAR(gm_sys_tutorialHints_EH) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	private _time = time;
	if (_time < GVAR(gm_sys_tutorialHints_nextUpdate)) exitWith {};

	private _player = player;
	private _alive  = [_player] call FUNC(unit_isAlive);

	GVAR(gm_sys_tutorialHints_nextUpdate) = _time + MACRO_GM_SYS_TUTORIALHINTS_INTERVAL;

	scopeName QGVAR(gm_sys_tutorialHints);





	// Role-specific ability hints (upon respawn)
	#include "tutorialHints\subSys_roleAbilities.sqf";

}];
