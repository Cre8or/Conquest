/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA]
		Compiles a list of all crew roles that this vehicle has (driver, gunner, commander, turret and cargo).
		Results are saved on a global namespace object (using the vehicle classname as key) in format:
		[role, <optional> turretPath].
	Arguments:
		0:	<OBJECT>	The vehicle to be inspected
	Returns:
			<ARRAY>		A nested array consisting of all available vehicle roles in format
					[roleEnum, turretPath, cargoIndex]
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_veh", objNull, [objNull]]
];





// Fetch the roles array from the namespace
private _namespace = missionNamespace getVariable [QGVAR(veh_getRoles_namespace), locationNull];
private _class = typeOf _veh;
private _roles = _namespace getVariable _class;

// If it doesn't exist yet, determine it
if (isNil "_roles") then {

	// Ensure that the namespace exists
	if (isNull _namespace) then {
		_namespace = createLocation ["NameVillage", [0,0,0], 0, 0];
		missionNamespace setVariable [QGVAR(veh_getRoles_namespace), _namespace, false];
	};

	// Fetch the vehicle's roles
	_roles = [];
	private _rolesTurret = [];
	private _rolesCargo = [];
	{
		_x params ["", "_role", "_cargoIndex", "_turretPath"];

		switch (toLower _role) do {
			case "driver":		{_roles pushBack MACRO_ENUM_VEHICLEROLE_DRIVER};
			case "gunner":		{_roles pushBack MACRO_ENUM_VEHICLEROLE_GUNNER};
			case "commander":	{_roles pushBack MACRO_ENUM_VEHICLEROLE_COMMANDER};
			case "turret":		{_rolesTurret pushBack _turretPath};
			case "cargo":		{_rolesCargo pushBack _cargoIndex};
		};
	} forEach fullCrew [_veh, "", true];

	// Sort and merge the 3 arrays
	_roles sort true;
	_rolesTurret sort true;
	_rolesCargo sort true;
	_roles = _roles apply {[_x, [], -1]};
	_roles append (_rolesTurret apply {[MACRO_ENUM_VEHICLEROLE_TURRET, _x, -1]});
	_roles append (_rolesCargo apply {[MACRO_ENUM_VEHICLEROLE_CARGO, [], _x]});

	// Save the roles array onto the namespace
	_namespace setVariable [_class, _roles];
};

_roles;
