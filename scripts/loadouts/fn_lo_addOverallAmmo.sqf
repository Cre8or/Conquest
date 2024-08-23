/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LA][GE]
		Resupplies the unit with respect to the specified amount and the unit loadout's default ammunition count.

		NOTE: Because of how loadouts work, sometimes it is not possible to add exactly the specified amount of ammo.
		Sometimes it can be more, or less than the intended amount. In places where this matters (e.g. score handling),
		it is advised to use the return value (rather than the passed argument), as it represents the real amount of
		ammo that was added.
	Arguments:
		0:	<OBJECT>	The unit in question
		1:	<NUMBER>	How much ammo to add, in range [0, 1] (optional, default: MACRO_ACT_RESUPPLYUNIT_AMOUNT)
	Returns:
			<NUMBER>	How much overall ammo was actually added (range [0, 1))
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_unit", objNull, [objNull]],
	["_supplies", MACRO_ACT_RESUPPLYUNIT_AMOUNT, [MACRO_ACT_RESUPPLYUNIT_AMOUNT]]
];

if (!local _unit) exitWith {};





// Check if the unit's ammo is cached, and if it isn't, update it
if !(_unit getVariable [QGVAR(overallAmmo_isValid), true]) then {
	[_unit] call FUNC(lo_updateOverallAmmo);
};

// Ensure the overall ammo is now valid
if !(_unit getVariable [QGVAR(overallAmmo_isValid), true]) exitWith {};

scopeName QGVAR(lo_addOverallAmmo_main);

private _overallAmmo      = _unit getVariable [QGVAR(overallAmmo), 1];
private _prevOverallAmmo  = _overallAmmo;
private _missingAmmoQueue = _unit getVariable [QGVAR(overallAmmo_queue), []];
private _firstRun         = true;
private ["_ammoDiff", "_curWeight", "_cost", "_finalAmmoCount", "_finalAmmoCountMinusLoaded", "_fullMagazinesCount", "_partialAmmo"];

for "_i" from (count _missingAmmoQueue) - 1 to 0 step -1 do {
	(_missingAmmoQueue # _i) params ["_magazine", "_currentAmmoCount", "_defaultAmmoCount", "_ammoPerMagazine", "_loadedAmmo", "_baseWeight"];
	_ammoDiff       = _defaultAmmoCount - _currentAmmoCount;
	_curWeight      = (1 - _currentAmmoCount / _defaultAmmoCount) * _baseWeight;
	_cost           = _supplies min _curWeight;
	_finalAmmoCount = _currentAmmoCount + _ammoDiff * (_cost / _curWeight);

	if (_firstRun) then {
		_finalAmmoCount = ceil _finalAmmoCount; // Always guarantee an increase of one ammo unit per run
	} else {
		_finalAmmoCount = round _finalAmmoCount;
	};

	// If we don't have enough supplies remaining to resupply this magazine, skip to the next one
	if (_finalAmmoCount == _currentAmmoCount) then {
		continue;
	};

	// Figure out how many magazines we need to add, considering there may be a loaded magazine that we cannot manipulate
	_finalAmmoCountMinusLoaded = _finalAmmoCount - _loadedAmmo;
	_fullMagazinesCount        = floor (_finalAmmoCountMinusLoaded / _ammoPerMagazine);
	//systemChat format ["ammoDiff: %1 - cost: %2 / %3 -> final: %4", _ammoDiff, _cost, _curWeight, _finalAmmoCount];

	// Re-add the magazines
	_unit removeMagazines _magazine;

	if (_fullMagazinesCount > 0) then {
		_unit addMagazines [_magazine, _fullMagazinesCount];
	};

	_partialAmmo = round (_finalAmmoCountMinusLoaded - (_fullMagazinesCount * _ammoPerMagazine));
	if (_partialAmmo > 0) then {
		_unit addMagazine [_magazine, _partialAmmo];
	};

	// Once this magazine type is refilled, remove it from the list
	if (_finalAmmoCount >= _defaultAmmoCount) then {
		_missingAmmoQueue deleteAt _i;

	// Otherwise, update the current ammo count for future runs
	} else {
		_missingAmmoQueue set [_i, [_magazine, _finalAmmoCount, _defaultAmmoCount, _ammoPerMagazine, _loadedAmmo, _baseWeight]];
	};

	// Update the ammo counter and supplies according to what was *actually* added
	_ammoDiff    = _finalAmmoCount - _currentAmmoCount;
	_cost        = (_ammoDiff / _defaultAmmoCount) * _baseWeight;
	_supplies    = _supplies - _cost;
	_overallAmmo = _overallAmmo + _cost;

	// Stop when we can no longer add any ammo
	if (_supplies <= 0) then {
		breakTo QGVAR(lo_addOverallAmmo_main);
	};

	_firstRun = false;
};

// To prevent rounding errors from cumulative increments, force the overall ammo to 1 when no magazines are missing
if (_missingAmmoQueue isEqualTo []) then {
	_overallAmmo = 1;
};





// Update the cached results, without calling lo_updateOverallAmmo
_unit setVariable [QGVAR(overallAmmo), _overallAmmo, true];
_unit setVariable [QGVAR(overallAmmo_queue), _missingAmmoQueue, false];

//systemChat format ["%1 overallAmmo: %2%3", name _unit, floor (_overallAmmo * 100), "%"];

// Return the amount of ammo that was actually added
(_overallAmmo - _prevOverallAmmo) max 0;
