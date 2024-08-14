private _shouldStop = false;

// Only handle medical actions if not already doing something else, including driving
if (!_isInVehicle and {_actionPos isEqualTo []}) then {

	// Set up some constants
	private _c_maxActionDistSqr    = MACRO_ACT_HEALUNIT_MAXDISTANCE ^ 2;
	private _c_maxMedicalDistSqr   = MACRO_AI_ROLEACTION_MAXDISTANCE_UNIT ^ 2;
	private _c_changeStanceDistSqr = MACRO_AI_ROLEACTION_CHANGESTANCEDISTANCE ^ 2;

	// Set up some variables
	private _health = _unit getVariable [QGVAR(health), 1];





	if (_role == MACRO_ENUM_ROLE_MEDIC) then {
		private _patient        = objNull;
		private _patientDistSqr = 0;
		private _selfHealTime   = _unit getVariable [QGVAR(ai_unitControl_handleMedical_selfHealTime), -1];

		// Prioritise self-care
		if (_health < 1) then {

			if (_selfHealTime < 0) then {
				_selfHealTime = _time + MACRO_AI_MEDICAL_SELFHEALCOOLDOWN;
				_unit setVariable [QGVAR(ai_unitControl_handleMedical_selfHealTime), _selfHealTime, false];
			};
			if (_time > _selfHealTime) then {
				_patient = _unit;
			};

		} else {
			if (_selfHealTime > 0) then {
				_unit setVariable [QGVAR(ai_unitControl_handleMedical_selfHealTime), -1, false];
			};
		};

		if (isNull _patient) then {
			// Look for nearby injured units to heal, while priorising unconscious units over wounded ones
			private _unitsInjured     = GVAR(ai_sys_unitControl_cache) getOrDefault [format ["unitsInjured_%1", _side], []];
			private _unitsUnconscious = GVAR(ai_sys_unitControl_cache) getOrDefault [format ["unitsUnconscious_%1", _side], []];
			_patientDistSqr           = _c_maxMedicalDistSqr;
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
					_distSqrX = _unit distanceSqr _x;

					if (_distSqrX < _patientDistSqr and {_unit != _x} and {_x getVariable [QGVAR(health), 1] > 0}) then {
						_patientDistSqr = _distSqrX;
						_patient        = _x;
					};
				} forEach _unitsInjured;
			};
		};

		if (isNull _patient) then {
			breakTo QGVAR(ai_sys_unitControl_loop_live);
		};

		// If we found a patient, head to them and try to heal them
		_actionPos = getPosWorld _patient;

		if (
			_patientDistSqr < _c_changeStanceDistSqr
			and {_patient getVariable [QGVAR(isUnconscious), false] or {stance _patient != "STAND"}}
		) then {
			_unit setUnitPos "MIDDLE";
		};

		if (_patientDistSqr < _c_maxActionDistSqr) then {
			[_unit, _patient] call FUNC(act_tryHealUnit);
			_shouldStop = true;
		} else {
			_actionPos = _actionPos vectorAdd [1 - random 2, 1 - random 2, 0]; // Randomness to help the unit get close enough
		};

	} else {

		// If the unit is healthy enough, nothing needs to be done
		if (_health >= MACRO_UNIT_HEALTH_THRESHOLDLOW) then {

			// If the unit is in the middle of being healed, stop a little long
			if (_health < 1 and {_time < _unit getVariable [QGVAR(ai_unitControl_handleMedical_stopTime), -1]}) then {
				_shouldStop = true;
			};

			breakTo QGVAR(ai_sys_unitControl_loop_live);
		};

		private _medic        = objNull;
		private _medicDistSqr = _c_maxMedicalDistSqr;
		private ["_distSqrX"];

		{
			_distSqrX = _unit distanceSqr _x;

			if (_distSqrX < _medicDistSqr) then {
				_medicDistSqr = _distSqrX;
				_medic        = _x;
			};
		} forEach (GVAR(ai_sys_unitControl_cache) getOrDefault [format ["unitsMedic_%1", _side], []]);

		if (isNull _medic) then {
			breakTo QGVAR(ai_sys_unitControl_loop_live);
		};

		// If we found a nearby medic, head towards them
		_actionPos = getPosWorld _medic;

		if (_medicDistSqr < _c_changeStanceDistSqr and {stance _medic != "STAND"}) then {
			_unit setUnitPos "MIDDLE";
		};

		if (_medicDistSqr < _c_maxActionDistSqr) then {
			_shouldStop = true;
		} else {
			_actionPos = _actionPos vectorAdd [1 - random 2, 1 - random 2, 0]; // Randomness to help the unit get close enough
		};
	};
};





// Handle stopping
[_shouldStop, MACRO_ENUM_AI_PRIO_MEDICAL, _unit, ["PATH"], false] call FUNC(ai_toggleFeature);
