/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LA][GE]
		Recalculates the unit's overall ammo, and caches the result for reuse.
	Arguments:
		0:	<OBJECT>	The unit in question
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_unit", objNull, [objNull]]
];

// Always invalidate the overall ammo on start
_unit setVariable [QGVAR(overallAmmo_isValid), false, false];

if (!local _unit or {!([_unit, true] call FUNC(unit_isAlive))}) exitWith {};





// Set up some variables
private _overallAmmo      = 0;
private _side             = _unit getVariable [QGVAR(side), sideEmpty];
private _role             = _unit getVariable [QGVAR(role), MACRO_ENUM_ROLE_INVALID];
private _defaultMagazines = missionNamespace getVariable [format [QGVAR(magazinesCache_%1_%2), _side, _role], []];
private _ammoCountCache   = createHashMapFromArray (_defaultMagazines apply {[_x, 0]});
private _loadedAmmoCache  = +_ammoCountCache;
private _missingAmmoQueue = [];

// Determine the total ammo count for each magazine classname
{
	_x params ["_magazine", "_ammoCount", "_isLoaded"];
	_magazine = toLower _magazine;

	// Ignore any magazines that did not come with the loadout (safeguarding)
	if (_magazine in _defaultMagazines) then {

		// Keep track of loaded magazines so we can deduct their count from the missing ammo queue
		if (_isLoaded) then {
			_loadedAmmoCache set [_magazine, (_loadedAmmoCache get _magazine) + _ammoCount];
		};

		// Add to the total
		_ammoCountCache set [_magazine, (_ammoCountCache get _magazine) + _ammoCount];
	};
} forEach magazinesAmmoFull _unit;

// Determine the unit's overall ammo.
private _numUniqueMagazines = 1 max count _defaultMagazines;
private ["_currentAmmoCount", "_defaultAmmoCount", "_baseWeight"];
{
	_currentAmmoCount = _ammoCountCache get _x;
	_defaultAmmoCount = (_y # 0) * (_y # 1); // Ammo per magazine * magazine count

	_overallAmmo = _overallAmmo + (_currentAmmoCount / _defaultAmmoCount);

	if (_currentAmmoCount < _defaultAmmoCount) then {
		// NOTE: _baseWeight is the same for every magazine, but shipping it in the same array
		// where it is used saves us from having to declare a separate variable elsewhere.
		// Plus, it means we keep the option of assigning magazine-specific weights in the future.
		_baseWeight = 1 / _numUniqueMagazines;
		_missingAmmoQueue pushBack [_x, _currentAmmoCount, _defaultAmmoCount, _y # 0, _loadedAmmoCache get _x, _baseWeight];
	};
} forEach _defaultMagazines;

// Each unique magazine class has the same weight (as in "importance"). This count-based approach works because we
// also deduplicated the magazines cache in gm_compileSidesData.
_overallAmmo = _overallAmmo / _numUniqueMagazines;

// Special case: while reloading, the magazine being loaded cannot be detected via scripting commands, making it
// impossible to return an accurate reading. Since support units can then resupply the unit, it is possible to
// achieve an overall ammo of *more* than 100%.
// Since that would seem wrong, we simply cap the ammo count at 100% and choose to ignore the implications of having
// an extra magazine.
_overallAmmo = _overallAmmo min 1;





// Cache the results
_unit setVariable [QGVAR(overallAmmo), _overallAmmo, true];
_unit setVariable [QGVAR(overallAmmo_isValid), true, false];
_unit setVariable [QGVAR(overallAmmo_queue), _missingAmmoQueue, false];

systemChat format ["%1 overallAmmo: %2%3", name _unit, floor (_overallAmmo * 100), "%"];
