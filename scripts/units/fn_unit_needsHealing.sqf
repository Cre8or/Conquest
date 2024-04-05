/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA]
		Returns whether or not a unit is in need of healing. Any unconscious or alive unit that is not at 100%
		health is considered to be in need of healing. Units inside of vehicles may not be healed, and as such
		are not considered to need healing, even if they are not at 100% health.
	Arguments:
		0:	<OBJECT>	The unit to be tested
	Returns:
			<BOOLEAN>	True if the unit needs healing, otherwise false
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_unit", objNull, [objNull]]
];





// Preliminary tests
if (
	!alive _unit
	or {!(_unit getVariable [QGVAR(isSpawned), false])}
	or {_unit != vehicle _unit}
) exitWith {false};

// Check health and consciousness
if (
	_unit getVariable [QGVAR(health), 0] < 1
	or {_unit getVariable [QGVAR(isUnconscious), false]}
) exitWith {true};





false;
