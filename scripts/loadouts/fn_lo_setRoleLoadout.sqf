/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LA][GE]
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
	["_role", MACRO_ENUM_ROLE_INVALID, [MACRO_ENUM_ROLE_INVALID]]
];

if (!alive _unit or {!local _unit}) exitWith {};





// Apply the loadout onto the unit
private _loadout = missionNamespace getVariable [format [QGVAR(loadout_%1_%2), _side, _role], []];

// Fallback loadout on erroneous side data files
if (_loadout isEqualTo []) then {
	_loadout = [[],[],[],[],[],[],"","",[],["ItemMap","ItemGPS","","ItemCompass","ItemWatch",""]];
};

_unit setUnitLoadout _loadout;

// Store the role on the entity for other components to check on
_unit setVariable [QGVAR(role), _role, true];

// Invalidate the ammo cache (forces all machines to recompute it locally)
_unit setVariable [QGVAR(overallAmmo_isValid), false, true];

[_unit, true] call FUNC(unit_selectBestWeapon);
