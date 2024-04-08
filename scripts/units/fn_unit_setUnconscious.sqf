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

if (!local _unit or {_newState == _unit getVariable [QGVAR(isUnconscious), false]}) exitWith {};





// Remember the bleedout time
private _time = time;
_unit setVariable [QGVAR(bleedoutTime), [-1, _time + _reviveDuration] select _newState, false];

// Handle the unit's state
_unit setUnconscious _newState;
_unit setVariable [QGVAR(isUnconscious), _newState, true];
_unit setVariable [QGVAR(health), 0, true];

if (_newState) then {
	// Edge case 1: on the server, update the respawn time on AI units
	if (isServer) then {
		private _unitIndex = _unit getVariable [QGVAR(unitIndex), -1];

		if (_unitIndex >= 0 and {_unitIndex < GVAR(param_ai_maxCount)}) then {
			GVAR(ai_sys_handleRespawn_respawnTimes) set [_unitIndex, _time + GVAR(param_gm_unit_respawnDelay)];
		};
	};

} else {
	// Reset the unit's health to the lowest amount that can be given by a medic
	_unit setVariable [QGVAR(health), MACRO_ACT_HEALUNIT_AMOUNT, true];

	[_unit, true] call FUNC(unit_selectBestWeapon);
};

// Edge case 1: if the concerned unit is the player, force a respawn state transition check
if (_unit == player) then {
	GVAR(gm_sys_handlePlayerRespawn_respawnTime) = _time + GVAR(param_gm_unit_respawnDelay);
	GVAR(gm_sys_handlePlayerRespawn_nextUpdate)  = -1;

	// Pre-emptively reset the give-up action (prevents sticky keys)
	GVAR(kb_act_pressed_giveUp) = false;
};
