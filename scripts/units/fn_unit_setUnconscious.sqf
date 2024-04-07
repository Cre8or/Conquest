/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LA][GE]
		Sets the unconscious state on the given unit to desired value. Unconscious units bleed out after a
		certain duration, unless they are revived in time by a friendly medic.
	Arguments:
		0:	<OBJECT>	The concerned unit
		1:	<BOOLEAN>	True to set the unit unconscious, false to wake them up (optional, default:
					true)
		2:	<NUMBER>	The revive state duration (optional, default: MACRO_GM_UNIT_REVIVEDURATION)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_unit", objNull, [objNull]],
	["_newState", true, [true]],
	["_reviveDuration", MACRO_GM_UNIT_REVIVEDURATION, [-1]]
];

if (!local _unit or {_newState != ([_unit] call FUNC(unit_isAlive))}) exitWith {};





// Remember the bleedout time
_unit setVariable [QGVAR(bleedoutTime), [-1, time + _reviveDuration] select _newState, false];

// Handle the unit's state
_unit setUnconscious _newState;
_unit setVariable [QGVAR(isUnconscious), _newState, true];
_unit setVariable [QGVAR(health), 0, true];

// Reset the unit's health to the lowest amount that can be given by a medic
if (!_newState) then {
	_unit setVariable [QGVAR(health), MACRO_ACT_HEALUNIT_AMOUNT, true];

	[_unit, true] call FUNC(unit_selectBestWeapon);
};
