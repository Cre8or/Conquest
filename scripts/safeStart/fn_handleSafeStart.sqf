/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles the safestart countdown upon mission initialisation. Changes are broadcasted across the network
		and JIP synchronised.
		Only executed once upon server init.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"





// Begin the safestart countdown
GVAR(missionState) = MACRO_ENUM_MISSION_SAFESTART;

// Turn safestart on globally
[true] remoteExecCall [QFUNC(setSafeStart), 0, QGVAR(safeStart)];

// Wait until the safestart countdown ends
systemChat format ["Beginning safestart countdown... (%1 seconds)", GVAR(Param_GM_SafeStartDuration)];
sleep GVAR(Param_GM_SafeStartDuration);





// Start the mission
GVAR(missionState) = MACRO_ENUM_MISSION_LIVE;
publicVariable QGVAR(missionState);
systemChat "Safestart ended - mission is now live!";

// Turn safestart off globally
[false] remoteExecCall [QFUNC(setSafeStart), 0, QGVAR(safeStart)];

// Broadcast the round start radio message
[MACRO_ENUM_RADIOMSG_ROUNDSTART] remoteExecCall [QFUNC(gm_playRadioMsg), 0, false];
