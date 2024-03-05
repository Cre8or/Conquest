/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles damage of a vehicle by attaching an EH and filtering out damage dealt to the specified
		hitpoints.
	Arguments:
		0:	<OBJECT>	The vehicle to handle damage for
		1:	<ARRAY>		An array of hitpoint names that should be invincible
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_veh", objNull, [objNull]],
	["_invincibleHitPoints", [], [[]]]
];

// If the vehicle is dead, or no hitpoints were specified, exit
if (!alive _veh or {_invincibleHitPoints isEqualTo []}) exitWith {};





// Save the blacklisted hitpoints onto the vehicle
_veh setVariable [QGVAR(invincibleHitPoints), _invincibleHitPoints, false];

// Add a Hit eventhandler to the vehicle
_veh addEventHandler ["HandleDamage", {
	params ["_veh", "", "", "", "", "", "", "_hitPoint"];

	if (_hitPoint in (_veh getVariable [QGVAR(invincibleHitPoints), []])) then {
		0;
	};
}];
