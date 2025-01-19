/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[S][GE]
		Handles the safestart countdown upon mission initialisation. Changes are broadcasted across the network
		and JIP synchronised.

		Only executed once upon server init.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"





// Begin the safestart countdown
GVAR(missionState) = MACRO_ENUM_MISSION_SAFESTART;

[true] remoteExecCall [QFUNC(gm_onSafeStartChanged), 0, QGVAR(safeStart)];

// Wait until the safestart countdown ends
systemChat format ["Beginning safestart countdown... (%1 seconds)", GVAR(param_gm_safeStartDuration)];
sleep GVAR(param_gm_safeStartDuration);





// Start the mission
GVAR(missionState) = MACRO_ENUM_MISSION_LIVE;
publicVariable QGVAR(missionState);
systemChat "Safestart ended - mission is now live!";

[false] remoteExecCall [QFUNC(gm_onSafeStartChanged), 0, QGVAR(safeStart)];

// Broadcast the round start radio message
[MACRO_ENUM_RADIOMSG_ROUNDSTART] remoteExecCall [QFUNC(gm_playRadioMsg), 0, false];
