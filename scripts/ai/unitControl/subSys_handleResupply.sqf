private _shouldStop = false;

// Only handle resupply actions if not already doing something else, including driving
if (!_isInVehicle and {_actionPos isEqualTo []}) then {

	// Set up some constants
	private _c_maxActionDistSqr    = MACRO_ACT_RESUPPLYUNIT_MAXDISTANCE ^ 2;
	private _c_maxMedicalDistSqr   = MACRO_AI_ROLEACTION_MAXDISTANCE_UNIT ^ 2;
	private _c_changeStanceDistSqr = MACRO_AI_ROLEACTION_CHANGESTANCEDISTANCE ^ 2;

	// Set up some variables
	private _ammo = [_unit] call FUNC(lo_getOverallAmmo);




	// TODO: Implement AI support logic
	if (_role == MACRO_ENUM_ROLE_SUPPORT) then {

	} else {

	};
};





// Handle stopping
[_shouldStop, MACRO_ENUM_AI_PRIO_RESUPPLY, _unit, ["PATH"], false] call FUNC(ai_toggleFeature);
