/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LA]
		Called whenever a local unit's "FiredMan" EH is executed.
		Handles gamemode specific code, such as the broadcasting of weapons and ammo associations for usage in
		the kill feed.
	Arguments:
		(see https://community.bistudio.com/wiki/Arma_3:_Event_Handlers#FiredMan)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

// Passed by the engine
params [
	"_unit",
	"_weapon",
	"_muzzle",
	"",
	"_ammoType",
	"_magazine",
	"_projectile",
	"_veh"
];

if (!local _unit) exitWith {};





// Initialise the projectile
[_projectile] call FUNC(proj_onInit);

// Fetch the lookup table
private _LUT = _unit getVariable [QGVAR(ammoLUT), locationNull];
if (isNull _LUT) then {
	_LUT = createLocation ["NameVillage", [0,0,0], 0, 0];
	_unit setVariable [QGVAR(ammoLUT), _LUT, false];
};

private _inVehicle   = _veh != _unit;
private _iconClass   = currentWeapon _unit;
private _classKind   = MACRO_ENUM_CLASSKIND_WEAPON;
private _ammoData    = [];
private _ammoDataLUT = _LUT getVariable [_ammoType, []];

// Generate the ammo data
if (_inVehicle) then {
	private _turretPath   = _veh unitTurret _unit;
	private _vehCurWeapon = toLower (_veh currentWeaponTurret _turretPath);
	private _vehWeapons   = (_veh weaponsTurret _turretPath) apply {toLower _x};

	if (_vehCurWeapon != "" and {_vehCurWeapon in _vehWeapons}) then {
		_iconClass = typeOf _veh;
		_classKind = MACRO_ENUM_CLASSKIND_VEHICLE;
	};
};

// Throwables
if (_weapon == "Throw") then {
	_iconClass = _magazine;
	_classKind = MACRO_ENUM_CLASSKIND_MAGAZINE;
};

_ammoData = [
	_classKind,
	_iconClass
];





// Disable spawn protection (only applicable for players)
if (_unit == player) then {
	GVAR(gm_sys_handlePlayerRespawn_protectionTime) = 0;
};





// Interface with lo_getOverallAmmo
private _curWeapon = currentWeapon _unit;
if (_weapon == _curWeapon) then {

	// To prevent network saturation, only invalidate the cache on the last bullet of the magazine.
	private _curAmmo = _unit ammo _muzzle;
	if (_curAmmo <= 0) then {
		_unit setVariable [QGVAR(overallAmmo_isValid), false, false];
		[_unit] call FUNC(lo_updateOverallAmmo);
	};
} else {
	// For thrown weapons, the "Reloaded" does not trigger on the last grenade.
	// As such, we only need to react to the very last grenade to invalidate the ammo cache.
	if (_weapon == "Throw" and {!(_magazine in magazines _unit)}) then {
		_unit setVariable [QGVAR(overallAmmo_isValid), false, false];
		[_unit] call FUNC(lo_updateOverallAmmo);
	};
};





// If the cached weapon data does not match the computed data, broadcast it
if (_ammoData isNotEqualTo _ammoDataLUT) then {
	_unit setVariable [format [QGVAR(ammoData_%1), _ammoType], _ammoData, true];
	_LUT setVariable [_ammoType, _ammoData];

/*	// DEBUG
	if (_unit == player) then {
		systemChat format ["Broadcasting: %1 --> %2", _ammoType, _ammoData];
	};
*/
};
