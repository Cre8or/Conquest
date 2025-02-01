/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA]
		Called whenever a projectile is created.

		Only executed on the projectile owning machine.
	Arguments:
		0:	<OBJECT>	The projectile that was fired
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\res\macros\fnc_initVar.inc"

params [
	["_projectile", objNull, [objNull]]
];

if (isNull _projectile) exitWith {};

MACRO_FNC_INITVAR(GVAR(allThrowablesAmmoCache), createHashMap);





private _shotParents = getShotParents _projectile;
_shotParents params ["_vehicle", "_instigator"];

// Ignore fake projectiles (anything that doesn't have a valid instigator)
if (isNull _instigator) exitWith {};

//systemChat format ["(%1) proj_onInit: %2 (%3)", time, _projectile, _instigator];

// Handle vehicle-fired projectiles
if (_vehicle != _instigator) exitWith {
	//systemChat format ["Fired from vehicle (%1)", typeOf _vehicle];

	// Handle ownership of subprojectiles
	if (isServer and {getText (configFile >> "CfgAmmo" >> typeOf _projectile >> "submunitionAmmo") != ""}) then {
		_projectile setVariable [QGVAR(shotParents), _shotParents, false];

		_projectile addEventHandler ["SubmunitionCreated", {
			params ["_projectile", "_subProjectile"];

			private _shotParents = _projectile getVariable [QGVAR(shotParents), [objNull, objNull]];
			_subProjectile setShotParents _shotParents;  // No idea why ArmA doesn't already do this
		}];
	};
};

// Handle unit-fired projectiles

private _class = typeOf _projectile;
if (_class in GVAR(allThrowablesAmmoCache)) exitWith {
	//systemChat format ["Skipping throwable (%1)", _class];
};

private _muzzle    = currentMuzzle _instigator;
private _muzzleLUT = _instigator getVariable [QGVAR(muzzleLUT), createHashMap];
_muzzleLUT set [toLower _class, toLower _muzzle]; // Look-up from the projectile classname to the muzzle, so we can consider damage multipliers
_instigator setVariable [QGVAR(muzzleLUT), _muzzleLUT, false];
//systemChat format ["Fired from unit (%1) - best muzzle candidate: %2", name _instigator, _muzzle];
