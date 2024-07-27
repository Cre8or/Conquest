/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LA][LE]
		Resets the AI unit's death time state to the machine's current time, which is different per-machine. This
		ensures correct respawn times across locality transitions.

		Either called on unit unconsciousness, or death (if not already unconscious).
	Arguments:
		0:	<OBJECT>	The concerned unit
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_unit", objNull, [objNull]]
];

if (isNull _unit or {isPlayer _unit}) exitWith {};





// Set up some variables
private _time = time;





// Interface with unitControl to allow unconscious units to give up and bleed out
if ([_unit, true] call FUNC(unit_isAlive)) then {
	_unit setVariable [QGVAR(ai_unitControl_unconsciousState_respawnTime), _time + GVAR(param_gm_unit_respawnDelay), false];
};

// Special case: the server is in charge of respawning units, and uses additional variables.
if (isServer) then {
	private _unitIndex = _unit getVariable [QGVAR(unitIndex), -1];

	if (_unitIndex >= 0 and {_unitIndex < GVAR(param_ai_maxCount)}) then {
		GVAR(ai_sys_handleRespawn_respawnTimes) set [_unitIndex, _time + GVAR(param_gm_unit_respawnDelay)];
	};
};
