/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA][LE]
		Initialises the specified vehicle by adding gamemode-relevant event handlers.

		Executed on every machine whenever a vehicle is (re)spawned.
	Arguments:
		0:	<OBJECT>	The vehicle to initialise
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\res\macros\fnc_initVar.inc"

params [
	["_veh", objNull, [objNull]]
];

if (isNull _veh) exitWith {};

MACRO_FNC_INITVAR(GVAR(allVehicles), []);
MACRO_FNC_INITVAR(GVAR(gm_sys_monitorEntityDamage_vehicles), []);





// Update the list of active vehicles
GVAR(allVehicles) = GVAR(allVehicles) select {!isNull _x};
GVAR(allVehicles) pushBackUnique _veh;





// Shared data
_veh removeAllEventHandlers "HandleDamage"; // Removes any modded event handlers (e.g. ACE3)
_veh addEventHandler ["HandleDamage", FUNC(veh_onHandleDamage)];

_veh removeAllEventHandlers "Killed";
_veh addEventHandler ["Killed", {
	_this params ["_veh"];

	GVAR(gm_sys_monitorEntityDamage_vehicles) pushBackUnique _veh;
}];

// Clear the vehicle's cargo locally
clearWeaponCargo _veh;
clearMagazineCargo _veh;
clearItemCargo _veh;
clearBackpackCargo _veh;

// Player specific
if (hasInterface) then {
	group player reveal _veh;
};

private _hitPoints = (getAllHitPointsDamage _veh) param [0, []] apply {toLower _x};
private _hasHull   = "hithull" in _hitPoints;

_veh setVariable [QGVAR(hasHitPoints), _hitPoints isNotEqualTo [], false];
_veh setVariable [QGVAR(hasHullHitPoint), _hasHull, false];




/*
	// Remove the forbidden weapons
	if !(_forbiddenWeapons isEqualTo []) then {
		{
			_veh removeWeaponGlobal _x;
		} forEach _forbiddenWeapons;
	};

	// Remove the forbidden magazines
	if !(_forbiddenMagazines isEqualTo []) then {
		private ["_turretPath"];
		{
			_turretPath = _x;
			{
				_veh removeMagazinesTurret [_x, _turretPath];
			} forEach _forbiddenMagazines;
		} forEach allTurrets [_veh, false];
	};
*/





if (isServer) then {
	GVAR(curatorModule) addCuratorEditableObjects [[_veh], false];
};
