/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA]
		Returns true if the given vehicle is operable. This includes most basic checks, including damage,
		fuel and mobility.
	Arguments:
		0:	<OBJECT>	The vehicle to be tested
	Returns:
			<BOOLEAN>	True if the vehicle is operable, otherwise false
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_veh", objNull, [objNull]]
];





// Basic checks
if !(
	alive _veh
	and {canMove _veh}
	and {fuel _veh > 0}
	and {_veh isKindOf "AllVehicles"}
) exitWith {false};

true;
