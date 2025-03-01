/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA]
		Calculates the total health (as a percentage in range 0 .. 1) of a vehicle, based on the total damage to its
		hit points (with the hull hitpoint acting as the primary damage indicator).
	Arguments:
		0:	<NUMBER>	The concerned vehicle
	Returns:
			<NUMBER>	The total vehicle health
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

params [
	["_veh", objNull, [objNull]]
];

if (!alive _veh) exitWith {0};





private _damageAverage = damage _veh;
private _hitPointData  = getAllHitPointsDamage _veh;
private _damageValues  = _hitPointData param [2, []];
private _countAverage  = 1;

// Calculate the overall damage
{
	_damageAverage = _damageAverage + _x;
	_countAverage  = _countAverage + 1;
} forEach _damageValues;

_damageAverage = _damageAverage / _countAverage;

private ["_damageMax"];
if (_veh getVariable [QGVAR(hasHullHitPoint), false]) then {
	private _damageHull = (_veh getHitPointDamage "hithull") / MACRO_VEHICLE_HEALTH_MAXHITPOINTDAMAGE;

	// Damage to the hull should matter more than average damage
	_damageMax = (_damageAverage / 100) max _damageHull;
} else {
	_damageMax = _damageAverage;
};

// Convert damage to health
(1 - _damageMax);
