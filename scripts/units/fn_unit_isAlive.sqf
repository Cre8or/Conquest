/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA]
		Returns true if the given unit is considered to be alive according to the gamemode rules.
		This handles custom features such as the incapacitated state (where the unit is revivable, but not
		combat effective), aswell as scenarios where players have been respawned by the engine, but are still
		in the spawn menu, or waiting to be respawned by the framework.
	Arguments:
		0:	<OBJECT>	The unit to be tested
	Returns:
			<BOOLEAN>	True if the unit is alive, otherwise false
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_unit", objNull, [objNull]]
];





// Simple case for AI
if (!isPlayer _unit) exitWith {alive _unit};

// Advanced cases for players
if (
	!alive _unit
	or {!(_unit getVariable [QGVAR(isSpawned), false])}
	or {(_unit getVariable [QGVAR(health), 0] <= 0)}
//	or {_unit getVariable [QGVAR(unconscious), false]}	// TODO: To be implemented once the custom medical system is done
) exitWith {false};





true;
