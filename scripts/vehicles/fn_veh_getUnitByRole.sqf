/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA]
		Returns the unit inside the given vehicle at the specified role and turret path.

		NOTE: The cargo index is only required for cargo roles. Likewise, the turret path is only required for
		turret roles.
	Arguments:
		0:	<OBJECT>	The vehicle to be inspected
		1:	<NUMBER>	The vehicle role enumeration
		2:	<ARRAY>		The role's turret path (optional, default: [])
		3:	<NUMBER>	The role's cargo index (optional, default: -1)
	Returns:
			<OBJECT>	The unit object at the given role
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_veh", objNull, [objNull]],
	["_role", MACRO_ENUM_VEHICLEROLE_INVALID, [MACRO_ENUM_VEHICLEROLE_INVALID]],
	["_turretPath", [], [[]]],
	["_cargoIndex", -1, [-1]]
];

if (isNull _veh) exitWith {objNull};





// Fetch and return the corresponding unit
switch (_role) do {
	case MACRO_ENUM_VEHICLEROLE_DRIVER:    {driver _veh};
	case MACRO_ENUM_VEHICLEROLE_GUNNER:    {gunner _veh};
	case MACRO_ENUM_VEHICLEROLE_COMMANDER: {commander _veh};
	case MACRO_ENUM_VEHICLEROLE_TURRET:    {_veh turretUnit _turretPath};

	// Cargo seats don't have a direct command. Instead, we need to search via the turret path
	case MACRO_ENUM_VEHICLEROLE_CARGO: {
		_cargoSeats = fullCrew [_veh, "cargo", false];

		_cargoSeats param [_cargoSeats findIf {_x # 2 == _cargoIndex}, []] param [5, objNull];
	};

	default {objNull}
};
