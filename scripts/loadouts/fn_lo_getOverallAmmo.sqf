/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LA]
		Returns the unit's overall ammo, expressed as a fraction of its starting ammo (as per the unit's loadout).
		The returned value is in range [0, 1].
		For the sake of performance, the overall ammo count is cached. This result is invalidated once the unit depletes
		its loaded magazine, or reloads.
	Arguments:
		0:	<OBJECT>	The unit in question
	Returns:
			<NUMBER>	The unit's overall ammo, in range [0, 1]
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_unit", objNull, [objNull]]
];

if (!local _unit) exitWith {0};





// Check if the unit's ammo is cached, and if it isn't, update it
if !(_unit getVariable [QGVAR(overallAmmo_isValid), true]) then {
	[_unit] call FUNC(lo_updateOverallAmmo);
};

_unit getVariable [QGVAR(overallAmmo_cache), 1];
