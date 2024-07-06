/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[S][GA]
		Resets the AI unit's death time state to the server's current time (which is where AI respawning is being
		handled).

		Either called on a local AI unit's death, or remotely on unit unconsciousness.
	Arguments:
		0:	<OBJECT>	The concerned unit
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_unit", objNull, [objNull]]
];

if (!isServer or {isNull _unit}) exitWith {};





private _unitIndex = _unit getVariable [QGVAR(unitIndex), -1];

if (_unitIndex >= 0 and {_unitIndex < GVAR(param_ai_maxCount)}) then {
	GVAR(ai_sys_handleRespawn_respawnTimes) set [_unitIndex, time + GVAR(param_gm_unit_respawnDelay)];
};
