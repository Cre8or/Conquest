/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA][LE]
		Initialises the specified vehicle by adding gamemode-relevant event handlers.

		Executed on every machine whenever a vehicle is (re)spawned.
	Arguments:
		0:	<OBJECT>	The vehicle to initialise
		1:	<SIDE>		The side the vehicle belongs to
		2:	<BOOLEAN>	Whether or not the vehicle is restricted to players (optional, default: false)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\res\macros\fnc_initVar.inc"

params [
	["_veh", objNull, [objNull]],
	["_side", sideEmpty, [sideEmpty]],
	["_playersOnly", false, [false]]
];

if (isNull _veh) exitWith {};

MACRO_FNC_INITVAR(GVAR(allVehicles), []);





// Update the list of active vehicles
GVAR(allVehicles) = GVAR(allVehicles) select {!isNull _x};
GVAR(allVehicles) pushBackUnique _veh;

// Shared data
_veh setVariable [QGVAR(side), _side, false];
_veh setVariable [QGVAR(playersOnly), _playersOnly, false];





if (local _veh) then {

	// Clear the vehicle's cargo
	clearWeaponCargoGlobal _veh;
	clearMagazineCargoGlobal _veh;
	clearItemCargoGlobal _veh;
	clearBackpackCargoGlobal _veh;

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

	// If any hitpoints should be invincible, we need to add a Hit EH
	if !(_invincibleHitPoints isEqualTo []) then {
		[_veh, _invincibleHitPoints] remoteExec [QFUNC(veh_handleDamage), 0, false];	// TODO: Find a way to make this JIP compatible without cluttering the JIP queue up with messages!
	};
*/
};





if (isServer) then {
	GVAR(curatorModule) addCuratorEditableObjects [[_veh], false];
};
