/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA]
		Calculates the total health (as a percentage in range 0 .. 1) of a vehicle, based on the total damage to its
		hit points. Alternatively, a hashmap with hitpoint damage can be passed, for cases where the actual damage is
		not representative of the vehicle's state (e.g. when capped by HandleDamage calculations).
	Arguments:
		0:	<NUMBER>	The concerned vehicle
		1:	<HASHMAP>	Alternative reference hit points hashmap (optional, default: nil)
	Returns:
			<NUMBER>	The total vehicle health
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

params [
	["_veh", objNull, [objNull]],
	"_hashMap"
];

if (!alive _veh) exitWith {0};





private _damageAverage  = damage _veh;
private _damageCritical = _damageAverage;
private _hitPoints      = [];
private _damageValues   = [];
private _countAverage   = 1;
private _countCritical  = 1;

// Flatten the provided hitpoint hashmap, if there is one
if (!isNil "_hashMap" and {_hashMap isEqualType createHashMap}) then {
	private _hitPointData = _hashMap toArray true;

	_hitPoints    = (_hitPointsData param [0, []]) apply {toLower _x};
	_damageValues = _hitPointsData param [1, []];
} else {
	private _hitPointData = getAllHitPointsDamage _veh;

	_hitPoints    = (_hitPointData # 0) apply {toLower _x};
	_damageValues = _hitPointData # 2;

};





// Calculate the overall health
private ["_damageX"];
{
	_damageX = _damageValues param [_forEachIndex, 0];

	_damageAverage = _damageAverage + _damageX;
	_countAverage  = _countAverage + 1;

	// Count critical hitpoints separately
	switch (_x) do {
		case "hitbody";
		case "hithull";
		case "hitfuel";
		case "hitrotor";
		case "hitvrotor";
		case "hitengine";
		case "hitengine1";
		case "hitengine2";
		case "hitengine3": {
			_damageCritical = _damageCritical + _damageX;
			_countCritical  = _countCritical + 1;
			diag_log format ["[CONQUEST] CRIT %1: %2", _x, _damageX];
		};

		default {
			diag_log format ["[CONQUEST]      %1: %2", _x, _damageX];
		}
	};

} forEach _hitPoints;

_damageAverage  = _damageAverage / _countAverage;
_damageCritical = _damageCritical / _countCritical;

diag_log format ["[CONQUEST] %1 / %2", _damageAverage, _damageCritical];

// Damage to critical components should matter more than overall average damage.
private _damageMax = _damageAverage max _damageCritical;

// Convert damage to health
(1 - _damageMax);
