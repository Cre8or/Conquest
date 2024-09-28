/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA][LE]
		Prevents the unit from opening any inventories. This ensures that there exist no means of resupplying without
		support roles, and to ensure units never take any gear/clothing/equipment that does not suit their role.
	Arguments:
		0:	<OBJECT>	The concerned unit
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_unit", objNull, [objNull]]
];

if (isNull _unit) exitWith {};





// Remove the existing event handler, if there is one
private _EH = _unit getVariable [QGVAR(unit_disableInventory_EH), -1];

_unit removeEventHandler ["InventoryOpened", _EH];



#ifdef MACRO_DEBUG_GM_ALLOWINVENTORY
	if (true) exitWith {};
#endif

_EH = _unit addEventHandler ["InventoryOpened", {true}];

_unit setVariable [QGVAR(unit_disableInventory_EH), _EH, false];
