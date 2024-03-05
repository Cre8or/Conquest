/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles the execution of local commands on a client machine whenever the safestart status has changed.

		Remotely executed on all machines by the server.
	Arguments:
		0:	<BOOLEAN>	Whether safestart should be on or off
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"

params [
	"_enabled"				// No default parameter, so it MUST be specified
];





// Enforce side relations
if (isServer) then {
	if (_enabled or {MACRO_AI_PEACEFULMODE}) then {
		east setFriend [resistance, 1];
		east setFriend [west, 1];

		resistance setFriend [east, 1];
		resistance setFriend [west, 1];

		west setFriend [east, 1];
		west setFriend [resistance, 1];
	} else {
		east setFriend [resistance, 0];
		east setFriend [west, 0];

		resistance setFriend [east, 0];
		resistance setFriend [west, 0];

		west setFriend [east, 0];
		west setFriend [resistance, 0];

	};

	civilian setFriend [east, 1];
	civilian setFriend [resistance, 1];
	civilian setFriend [west, 1];
};

// Update all vehicles
{
	[_x, _enabled] call FUNC(safeStart_vehicle);
} forEach GVAR(allVehicles);

// Update the safeStart variable
GVAR(safeStart) = _enabled;
