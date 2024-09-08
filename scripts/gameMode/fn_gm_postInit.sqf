/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles the execution of initialisation code across all machines. To ensure correct order of execution,
		this function is divided into stages, which can either be shared, or server/client-specific. This
		handles the edge case of locally hosted servers, while maintaining compatibility with traditional
		multiplayer server/client separation.

		Only executed once by all machines upon initialisation.
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





// Shared component (stage 1)
#include "init\init_s1_shared.sqf"





// Server component (stage 2)
if (isServer) then {
	#include "init\init_s2_server.sqf"
};

// Client component (stage 2)
if (hasInterface) then {
	#include "init\init_s2_client.sqf"
};





// Shared component (stage 3)
#include "init\init_s3_shared.sqf"
