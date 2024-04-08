// Set up some variables
private _respawnTime = GVAR(ai_sys_handleRespawn_respawnTimes) param [_unitIndex, -1];





// The unit should be able to respawn, but is still unconscious
if (_time > _respawnTime) then {

	// If there are no medics nearby, give up
	private _c_maxMedicalDistSqr = MACRO_AI_MEDICAL_MAXACTIONDISTANCE ^ 2;
	private _medics              = GVAR(ai_sys_unitControl_cache) getOrDefault [format ["unitsMedic_%1", _side], []];

	if (_medics findIf {_x distanceSqr _unit < _c_maxMedicalDistSqr} < 0) then {
		_unit setDamage 1;

		breakTo QGVAR(ai_sys_unitControl_loop_local);
	};

	// Enforce bleed-out
	private _bleedoutTime = _unit getVariable [QGVAR(bleedoutTime), -1];
	if (_time > _bleedoutTime) then {
		_unit setDamage 1;

		breakTo QGVAR(ai_sys_unitControl_loop_local);
	};
};
