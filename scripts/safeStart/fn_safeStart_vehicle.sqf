#include "..\..\res\common\macros.inc"

// Fetch our params
params [
	["_veh", objNull, [objNull]],
	"_enabled"				// No default parameter, so it MUST be specified
];

// If no vehicle was provided, exit
if (!alive _veh) exitWith {};





// Turn safeStart on
if (_enabled) then {
	_veh lock true;
	_veh setFuel 0;
	_veh allowDamage false;

// Turn safeStart off
} else {
	_veh lock false;
	_veh setFuel 1;
	_veh allowDamage true;
};
