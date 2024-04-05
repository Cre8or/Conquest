/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA]
		Returns true if the given unit is currently reloading any of its weapons, otherwise returns false.
	Arguments:
		0:	<OBJECT>	The unit to be tested
	Returns:
			<BOOLEAN>	True if the unit is reloading, otherwise false
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_unit", objNull, [objNull]]
];

if (!alive _unit) exitWith {false};




// Set up some variables
private _result = false;

scopeName QGVAR(unit_isReloading);

// Test all weapons
{

	if (_x == "") then {
		continue;
	};

	if ((_unit weaponState _x) # 6 > 0) then {
		_result = true;
		breakTo QGVAR(unit_isReloading);
	};

} forEach [
	primaryWeapon _unit,
	handgunWeapon _unit,
	secondaryWeapon _unit
];





_result;
