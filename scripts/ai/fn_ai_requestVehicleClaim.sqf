/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA][GE]
		Requests a specific role claim on a vehicle. This function handles the deconflicting of (potentially)
		multiple requests being sent for the same role of a vehicle. The decision is handled here by the
		server and broadcast to all machines.

		Only executed on the server.
	Arguments:
		0:	<OBJECT>	The requesting unit
		1:	<OBJECT>	The vehicle in question
		2:	<NUMBER>	The requested role enumeration
		3:	<ARRAY>		The requested turret path (optional, default: [])
		4:	<NUMBER>	The requested cargo index (optional, default: -1)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_unit", objNull, [objNull]],
	["_veh", objNull, [objNull]],
	["_role", MACRO_ENUM_VEHICLEROLE_INVALID, [MACRO_ENUM_VEHICLEROLE_INVALID]],
	["_turretPath", [], [[]]],
	["_cargoIndex", -1,[-1]]
];

if (!isServer or {!alive _veh} or {!alive _unit}) exitWith {};

//systemChat format ["(%1) %2 requested %3: %4", time, _unit, typeOf _veh, [_vehRole, _turretPath, _cargoIndex]];





// Check role availability
private _occupiedBy = [_veh, _role, _turretPath, _cargoIndex] call FUNC(veh_getUnitByRole);
if (alive _occupiedBy and {_unit != _occupiedBy}) exitWith {};

// Abort if the previous claimer is still alive and their claim hasn't expired
if (
	time < _veh getVariable [format [QGVAR(ai_unitControl_claimVehicle_nextUpdate_%1_%2_%3), _role, _turretPath, _cargoIndex], 0]
	and {[_veh getVariable [format [QGVAR(ai_unitControl_claimVehicle_unit_%1_%2_%3), _role, _turretPath, _cargoIndex], objNull]] call FUNC(unit_isAlive)}
) exitWith {};





// Grant the claim request
//systemchat format ["(%1) Granted vehicle claim (%2: %3 / %4)", time, _unit, typeOf _veh, [_vehRole, _turretPath, _cargoIndex]];
_this remoteExecCall [QFUNC(ai_processVehicleClaim), 0, false];
