// Set up some variables
private _respawnTime = _unit getVariable [QGVAR(ai_unitControl_unconsciousState_respawnTime), -1];





// Enforce bleed-out
private _bleedoutTime = _unit getVariable [QGVAR(bleedoutTime), -1];
if (_time > _bleedoutTime) then {
	_unit setDamage 1;

	breakTo QGVAR(ai_sys_unitControl_loop_local);

};

// Allow the unit to give up prematurely if it can respawn, hasn't bled out yet, and has no medics nearby
if (_time > _respawnTime) then {
	private _c_maxMedicalDistSqr = MACRO_AI_ROLEACTION_MAXDISTANCE_UNIT ^ 2;
	private _medics              = GVAR(ai_sys_unitControl_cache) getOrDefault [format ["unitsMedic_%1", _side], []];

	if (_medics findIf {_x distanceSqr _unit < _c_maxMedicalDistSqr} < 0) then {
		_unit setDamage 1;

		breakTo QGVAR(ai_sys_unitControl_loop_local);
	};
};
