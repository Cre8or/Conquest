/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA]
		Checks whether a vehicle is claimable by the given unit.
	Arguments:
		0:	<OBJECT>	The vehicle to be claimed
		1:	<OBJECT>	The unit requesting the claim
	Returns:
			<BOOLEAN>	True if the vehicle is claimable by the unit, otherwise false
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_veh", objNull, [objNull]],
	["_unit", objNull, [objNull]]
];

if (!alive _veh or {!alive _unit}) exitWith {false};





if (
	_unit distanceSqr _veh > MACRO_AI_CLAIMVEHICLE_MAXDIST ^ 2
	or {_unit getVariable [QGVAR(side), sideEmpty] != _veh getVariable [QGVAR(side), sideEmpty]}
	or {_veh getVariable [QGVAR(playersOnly), false]}
	or {vectorMagnitudeSqr velocity _veh > MACRO_AI_CLAIMVEHICLE_MAXSPEED_MOUNT ^ 2}
	or {(getPosATL _veh select 2) > MACRO_AI_CLAIMVEHICLE_MAXALTITUDE}
	or {!([_veh] call FUNC(veh_isOperable))}
) exitWith {false};

true;
