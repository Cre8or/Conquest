/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Applies a loadout onto a unit, based on the provided side and role.
		Requires that the loadouts have already been compiled (see fn_lo_compileLoadouts).
	Arguments:
		0:	<OBJECT>	The unit that should receive the loadout
		1:	<SIDE>		From which side to pull the loadout
		2:	<NUMBER>	The role's enumeration value (see macros.inc)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_unit", objNull, [objNull]],
	["_side", sideEmpty, [sideEmpty]],
	["_role", -1, [-1]]
];

if (!alive _unit) exitWith {};





// Apply the loadout onto the unit
_unit setUnitLoadout (missionNamespace getVariable [format [QGVAR(loadout_%1_%2), _side, _role], []]);

// Store the role on the entity for other components to check on
_unit setVariable [QGVAR(role), _role, true];
