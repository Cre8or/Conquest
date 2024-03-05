// Set up some variables
private _prevInCombatArea = _unit getVariable [QGVAR(ai_unitControl_combatArea_inCA), true];
private _inCombatArea     = [_unitPos, _side] call FUNC(ca_isInCombatArea);





if (!_inCombatArea) then {

	// If the unit just left the combat area, determine the punish time
	if (_prevInCombatArea) then {
		_unit setVariable [QGVAR(ai_unitControl_combatArea_punishTime), _time + MACRO_CA_DELAYUNTILDEATH, false];
	};

	private _punishTime = _unit getVariable [QGVAR(ai_unitControl_combatArea_punishTime), 0];

	if (_time > _punishTime) then {
		_unit setDamage 1;
		[_unit, _unit] remoteExecCall [QFUNC(ui_processKillFeedEvent), 0, false];

		// Don't handle any other subsystems
		breakTo QGVAR(ai_sys_unitControl_loop);
	};
};

_unit setVariable [QGVAR(ai_unitControl_combatArea_inCA), _inCombatArea, false];
