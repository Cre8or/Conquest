/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA][LE]
		Forfeits a vehicle claim. This resets the relevant variables for vehicle claims, and opens up the
		previously claimed role in the vehicle for other units to claim.
	Arguments:
		0:	<OBJECT>	The requesting unit
		1:	<BOOLEAN>	Whether the unit's vehicle claim cooldown should be reset (optional, default:
					false)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_unit", objNull, [objNull]],
	["_resetCooldown", false, [false]]
];

if (isNull _unit) exitWith {};





// Fetch the unit's vehicle claim data
private _veh = _unit getVariable [QGVAR(ai_unitControl_claimVehicle_veh), objNull];

if (!alive _veh) exitWith {};





(_unit getVariable [QGVAR(ai_unitControl_claimVehicle_role), []]) params [
	["_role", MACRO_ENUM_VEHICLEROLE_INVALID],
	["_turretPath", []],
	["_cargoIndex", -1]
];
private _claimUnit = _veh getVariable [format [QGVAR(ai_unitControl_claimVehicle_unit_%1_%2_%3), _role, _turretPath, _cargoIndex], objNull];

// Ensure we're not overriding newer data
if (_unit == _claimUnit) then {
	_veh setVariable [format [QGVAR(ai_unitControl_claimVehicle_nextUpdate_%1_%2_%3), _role, _turretPath, _cargoIndex], 0, false];
	_veh setVariable [format [QGVAR(ai_unitControl_claimVehicle_unit_%1_%2_%3), _role, _turretPath, _cargoIndex], objNull, false];
};

// If the claimed vehicle's driver is local, ensure the unit is dropped from his drivers mount-up queue
if (local _veh and {!isPlayer driver _veh}) then {
	private _mountUpQueue = _veh getVariable [QGVAR(ai_sys_driverControl_mountUpQueue), []];

	if (_mountUpQueue isNotEqualTo []) then {
		_mountUpQueue = _mountUpQueue - [_unit];
		_veh setVariable [QGVAR(ai_sys_driverControl_mountUpQueue), _mountUpQueue, false];
	};
};

//systemChat format ["(%1) %2 forfeit %3: %4", time, _unit, typeOf _veh, [_role, _turretPath, _cargoIndex]];





// Clear the unit's claim data
_unit setVariable [QGVAR(ai_unitControl_claimVehicle_veh), objNull, false];
_unit setVariable [QGVAR(ai_unitControl_claimVehicle_role), [], false];

if (_resetCooldown) then {
	_unit setVariable [QGVAR(ai_unitControl_claimVehicle_nextUpdate), 0, false];
};
