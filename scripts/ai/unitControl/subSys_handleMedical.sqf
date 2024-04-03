// Only handle medical actions if not already doing something else
if (_actionPos isEqualTo []) then {

	// Set up some constants
	private _c_maxActionDistSqr = MACRO_AI_MEDICAL_MAXACTIONDISTANCE ^ 2;

	// Set up some variables
	private _health = _unit getVariable [QGVAR(health), 1];





	if (_role == MACRO_ENUM_ROLE_MEDIC) then {

		private _patient        = objNull;
		private _patientDistSqr = 0;

		// Prioritise self-care
		if ([_unit] call FUNC(unit_needsHealing)) then {
			_patient = _unit;

		} else {
			// Look for nearby injured units to heal, while priorising unconscious units over wounded ones
			private _unitsInjured     = GVAR(ai_sys_unitControl_cache) getOrDefault [format ["unitsInjured_%1", _side], []];
			private _unitsUnconscious = GVAR(ai_sys_unitControl_cache) getOrDefault [format ["unitsUnconscious_%1", _side], []];
			_patientDistSqr           = _c_maxActionDistSqr;
			private ["_distSqrX"];

			{
				_distSqrX = _x distanceSqr _unit;

				if (_distSqrX < _patientDistSqr) then {
					_patientDistSqr = _distSqrX;
					_patient        = _x;
				};
			} forEach _unitsUnconscious;

			if (isNull _patient) then {
				{
					_distSqrX = _x distanceSqr _unit;

					if (_distSqrX < _patientDistSqr) then {
						_patientDistSqr = _distSqrX;
						_patient        = _x;
					};
				} forEach _unitsInjured;
			};
		};

		// If we found a patient, head to them and try to heal them
		if (alive _patient) then {
			_actionPos = getPosWorld _patient;

			if (_patientDistSqr < MACRO_ACT_HEALUNIT_MAXDISTANCESQR) then {
				[_unit, _patient] call FUNC(act_tryHealUnit);
			} else {
				_actionPos = _actionPos vectorAdd [1 - random 2, 1 - random 2, 0]; // Randomness to help the unit get close enough
			};
		};

	} else {

		// If the unit is healthy, nothing needs to be done
		if !([_unit] call FUNC(unit_needsHealing)) then {
			breakTo QGVAR(ai_sys_unitControl_loop_live);
		};

	};
};
