/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA][LE]
		Processes a vehicle claim. This handles all the local data management necessary to keep track of
		claim requests, for further decision making by the claimVehicle AI subsystem. This function is called
		on all machines (by the server, via remoteExecCall) in response to a vehicle claim request.
	Arguments:
		0:	<OBJECT>	The requesting unit
		1:	<OBJECT>	The vehicle in question
		2:	<NUMBER>	The claimed role enumeration
		3:	<ARRAY>		The claimed turret path (optional, default: [])
		4:	<NUMBER>	The claimed cargo index (optional, default: -1)
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

if (!alive _veh or {!alive _unit} or {_role == MACRO_ENUM_VEHICLEROLE_INVALID}) exitWith {};





// Unlink the previous unit from the vehicle, if there is one
private _prevUnit = _veh getVariable [format [QGVAR(ai_unitControl_claimVehicle_unit_%1_%2_%3), _role, _turretPath, _cargoIndex], objNull];
if (alive _prevUnit and {local _prevUnit} and {_unit != _prevUnit}) then {
	[_prevUnit, true] call FUNC(ai_forfeitVehicleClaim); // Eexecute locally, as ai_processVehicleClaim already gets called globally
};

// Link the requesting unit to the vehicle (forward lookup)
private _time = time;
_unit setVariable [QGVAR(ai_unitControl_claimVehicle_veh), _veh, false];
_unit setVariable [QGVAR(ai_unitControl_claimVehicle_role), [_role, _turretPath, _cargoIndex], false];
_unit setVariable [QGVAR(ai_unitControl_claimVehicle_nextUpdate), _time + MACRO_AI_CLAIMVEHICLE_COOLDOWN, false];

// Link the vehicle to the unit (reverse lookup)
_veh setVariable [format [QGVAR(ai_unitControl_claimVehicle_unit_%1_%2_%3), _role, _turretPath, _cargoIndex], _unit, false];
_veh setVariable [format [QGVAR(ai_unitControl_claimVehicle_nextUpdate_%1_%2_%3), _role, _turretPath, _cargoIndex], _time + MACRO_AI_CLAIMVEHICLE_COOLDOWN, false]; // Cooldown only applies to units, not vehicles

//systemChat format ["(%1) %2 claimed %3: %4", _time, _unit, typeOf _veh, [_role, _turretPath, _cargoIndex]];





// Add the unit to the vehicle's mount-up queue, instructing the AI driver to halt temporarily
if (local _veh and {!isPlayer driver _veh}) then {
	private _mountUpQueue = _veh getVariable [QGVAR(ai_sys_driverControl_mountUpQueue), []];
	_mountUpQueue pushBackUnique _unit;
	_veh setVariable [QGVAR(ai_sys_driverControl_mountUpQueue), _mountUpQueue, false];
};
