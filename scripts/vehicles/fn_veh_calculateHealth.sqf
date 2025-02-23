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
private _hitPoints     = (_hitPointData param [0,[]]) apply {toLower _x};
private _damageValues  = _hitPointData param [2, []];
private _countAverage  = 1;

// Calculate the overall damage
private ["_damageX"];
{
	_damageX = _damageValues param [_forEachIndex, 0];

	_damageAverage = _damageAverage + _damageX;
	_countAverage  = _countAverage + 1;
} forEach _hitPoints;

_damageHull    = (_veh getHitPointDamage "hithull") / MACRO_VEHICLE_HEALTH_MAXHITPOINTDAMAGE;
_damageAverage = _damageAverage / _countAverage;

// Damage to the hull should matter more than average damage
private _damageMax = (_damageAverage / 100) max _damageHull;

// Convert damage to health
(1 - _damageMax);
