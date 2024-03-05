/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Called whenever a projectile is fired by a unit.

		Only executed on the projectile owning machine.
	Arguments:
		0:	<OBJECT>	The projectile that was fired
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_projectile", objNull, [objNull]]
];

if (isNull _projectile) exitWith {};





if (getText (configFile >> "CfgAmmo" >> typeOf _projectile >> "submunitionAmmo") != "") then {
	_projectile setVariable [QGVAR(shotParents), getShotParents _projectile, false];

	_projectile addEventHandler ["SubmunitionCreated", {
		params ["_projectile", "_subProjectile"];

		_shotParents = _projectile getVariable [QGVAR(shotParents), [objNull, objNull]];
		[_subProjectile, _shotParents] remoteExecCall ["setShotParents", 2, false];  // No idea why ArmA doesn't already do this

		// Recursively do this on subsequent submunitions
		[_subProjectile] call FUNC(proj_onInit);
	}];
};
