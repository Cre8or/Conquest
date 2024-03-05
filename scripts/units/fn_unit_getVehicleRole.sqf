/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA]
		Returns the unit's current vehicle role data. If the unit is not in a vehicle, an invalid role is
		returned.
	Arguments:
		0:	<OBJECT>	The unit to be inspected
	Returns:
			<ARRAY>		The unit's vehicle role data in format [roleEnum, turretPath, cargoIndex]
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_unit", objNull, [objNull]]
];

private _result = [MACRO_ENUM_VEHICLEROLE_INVALID, [], -1];

if (isNull _unit) exitWith {_result};





// Check if the unit is in the vehicle
private _veh   = vehicle _unit;
private _crew  = fullCrew [_veh, "", false];
private _index = _crew findIf {_x # 0 == _unit};

if (_index < 0) exitWith {_result};

// Determine the unit's vehicle role
private _unitCrewData = _crew # _index;

switch (toLower (_unitCrewData # 1)) do {
	case "driver": {
		_result = [MACRO_ENUM_VEHICLEROLE_DRIVER, [], -1];
	};
	case "gunner": {
		_result = [MACRO_ENUM_VEHICLEROLE_GUNNER, [], -1];
	};
	case "commander": {
		_result = [MACRO_ENUM_VEHICLEROLE_COMMANDER, [], -1];
	};
	case "turret": {
		_result = [MACRO_ENUM_VEHICLEROLE_TURRET, _unitCrewData # 3, -1];
	};
	case "cargo": {
		_result = [MACRO_ENUM_VEHICLEROLE_CARGO, [], _unitCrewData # 2];
	};
};

_result;
