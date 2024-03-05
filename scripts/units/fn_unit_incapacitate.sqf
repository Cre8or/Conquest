/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Incapacitates the given unit and puts them into an unconscious state. If not healed in time by a
		friendly medic, the unit is killed and may respawn again.
		If the unit is a player, they may opt to respawn manually.
	Arguments:
		0:	<OBJECT>	The unit to be incapacitated
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

// Fetch our params
params [
	["_unit", objNull, [objNull]]
];

if (!local _unit or {!([_unit] call FUNC(unit_isAlive))}) exitWith {};





//
_unit setUnconscious true;
