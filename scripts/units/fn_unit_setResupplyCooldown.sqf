/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA]
		Sets the resupply cooldown of the unit via to the machine's local time.

		Called on every machine via unit_onResupplyUnit.
	Arguments:
		0:	<OBJECT>	The unit that was resupplied
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_unit", objNull, [objNull]]
];

if (isNull _unit) exitWith {};





_unit setVariable [QGVAR(resupplyCooldown), time + MACRO_UNIT_AMMO_RESUPPLYCOOLDOWN, false];
