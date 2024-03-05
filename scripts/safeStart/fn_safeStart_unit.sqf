#include "..\..\res\common\macros.inc"

// Fetch our params
params [
	["_unit", objNull, [objNull]],
	"_enabled"				// No default parameter, so it MUST be specified
];

// If no vehicle was provided, exit
if (!alive _unit) exitWith {};





// Attach an EH to the unit that detects when it is firing
if !(_unit getVariable [QGVAR(safeStart_hasEH), false]) then {
	_unit setVariable [QGVAR(safeStart_hasEH), true, false];

	_unit addEventHandler ["FiredMan", {
		params ["_unit", "", "", "", "", "", "_projectile"];

		// If safeStart is on, remove the projectile
		if (GVAR(safeStart)) then {
			deleteVehicle _projectile;
		};
	}];
};

_unit allowDamage (!_enabled);
