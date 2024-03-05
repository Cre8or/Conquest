/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles the execution of mission post-initialisation code across all machines. To ensure correct order of
		execution, this function calls the server, client and shared components in sequential order. This
		addresses the edge case of locally hosted servers, while maintaining compatibility with traditional
		multiplayer server/client separation.

		Only executed once by all machines upon post-initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "\a3\ui_f\hpp\defineDIKCodes.inc"

#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"

#include "..\..\res\macros\fnc_initVar.inc"

// Enforce unscheduled environment
if (canSuspend) exitWith {
	isNil {
		call (missionNamespace getVariable _fnc_scriptName)
	};
};






// Server component (init)
if (isServer) then {
	#include "init\init_server.sqf"
};

// Client component (init)
if (hasInterface) then {
	#include "init\init_client.sqf"
};





// Shared component (postInit)
#include "init\postInit_shared.sqf"
