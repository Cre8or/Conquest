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
		1:	<BOOLEAN>	Whether unconsciousness should be considered as being alive (optional, default:
					false)
	Returns:
			<BOOLEAN>	True if the unit is alive, otherwise false
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_unit", objNull, [objNull]],
	["_includeUnconscious", false, [false]]
];





// Preliminary tests
if (
	!alive _unit
	or {!(_unit getVariable [QGVAR(isSpawned), false])}
) exitWith {false};

// Check health and consciousness
if (
	_unit getVariable [QGVAR(health), 0] > 0
	or {_includeUnconscious and {_unit getVariable [QGVAR(isUnconscious), false]}}
) exitWith {true};





false;
