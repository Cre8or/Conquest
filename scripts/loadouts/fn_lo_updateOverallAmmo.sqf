/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LA]
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

if (!local _unit) exitWith {};





// Set up some variables
private _overallAmmo = 0;

if ([_unit] call FUNC(unit_isAlive)) then {
	private _side            = _unit getVariable [QGVAR(side), sideEmpty];
	private _role            = _unit getVariable [QGVAR(role), MACRO_ENUM_ROLE_INVALID];
	private _defaultMagazines = missionNamespace getVariable [format [QGVAR(magazinesCache_%1_%2), _side, _role], []];
	private _ammoCountCache   = createHashMapFromArray (_defaultMagazines apply {[_x, 0]});

	// Determine the total ammo count for each magazine classname
	{
		_x params ["_magazine", "_ammoCount", "_isLoaded"];
		_magazine = toLower _magazine;

		// Ignore any magazines that did not come with the loadout (safeguarding)
		if (_magazine in _defaultMagazines) then {

			// Count loaded magazines as either full or empty (no partials)
			if (_isLoaded and {_ammoCount > 0}) then {
				_ammoCount = (_defaultMagazines get _magazine) param [0, 1]; // Ammo per magazine
			};

			// Add to the total
			_ammoCountCache set [_magazine, (_ammoCountCache get _magazine) + _ammoCount];
		};
	} forEach magazinesAmmoFull _unit;

	// Determine the unit's overall ammo
	private ["_currentAmmoCount", "_defaultAmmoCount"];
	{
		_currentAmmoCount = _ammoCountCache get _x;
		_defaultAmmoCount = (_y # 0) * (_y # 1); // Ammo per magazine * magazine count

		_overallAmmo  = _overallAmmo + (_currentAmmoCount / _defaultAmmoCount);
	} forEach _defaultMagazines;

	// Averaging out by the amount of unique magazines. This works because we deduplicated the magazines cache in gm_compileSidesData.
	_overallAmmo = _overallAmmo / (1 max count _defaultMagazines);

	// Special case: while reloading, the magazine being loaded cannot be detected via scripting commands, making it
	// impossible to return an accurate reading. Since support units can then resupply the unit, it is possible to
	// achieve an overall ammo of *more* than 100%.
	// Since that would seem wrong, we simply cap the ammo count at 100% and choose to ignore the implications of having
	// an extra magazine.
	_overallAmmo = _overallAmmo min 1;
};





// Cache the results
_unit setVariable [QGVAR(overallAmmo_cache), _overallAmmo, false];
_unit setVariable [QGVAR(overallAmmo_isValid), true, false];

systemChat format ["%1 overallAmmo: %2%3", name _unit, floor (_overallAmmo * 100), "%"];
