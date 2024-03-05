/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles the execution of mission pre-initialisation code across all machines.

		Only executed once by all machines upon pre-initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

// Enforce unscheduled environment
if (canSuspend) exitWith {
	isNil {
		call (missionNamespace getVariable _fnc_scriptName)
	};
};





// Shared component (preInit)
#include "init\preInit_shared.sqf"
