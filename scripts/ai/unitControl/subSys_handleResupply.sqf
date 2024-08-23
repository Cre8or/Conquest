private _shouldStop = false;

// Only handle resupply actions if not already doing something else, including driving
if (!_isInVehicle and {_actionPos isEqualTo []}) then {

	// Set up some constants
	private _c_maxActionDistSqr    = MACRO_ACT_RESUPPLYUNIT_MAXDISTANCE ^ 2;
	private _c_maxResupplyDistSqr  = MACRO_AI_ROLEACTION_MAXDISTANCE_UNIT ^ 2;
	private _c_changeStanceDistSqr = MACRO_AI_ROLEACTION_CHANGESTANCEDISTANCE ^ 2;

	// Set up some variables
	private _ammo = [_unit] call FUNC(lo_getOverallAmmo);





	if (_role == MACRO_ENUM_ROLE_SUPPORT) then {
		private _recipient        = objNull;
		private _recipientDistSqr = _c_maxResupplyDistSqr;
		private _unitsLowAmmmo    = GVAR(ai_sys_unitControl_cache) getOrDefault [format ["unitsLowAmmo_%1", _side], []];
		private ["_distSqrX"];

		// Prioritise resupplying units who are low on ammo
		{
			_distSqrX = _x distanceSqr _unit;

			if (_distSqrX < _recipientDistSqr) then {
				_recipientDistSqr = _distSqrX;
				_recipient        = _x;
			};
		} forEach _unitsLowAmmmo;

		if (isNull _recipient) then {
			private _unitsNearFullAmmo = GVAR(ai_sys_unitControl_cache) getOrDefault [format ["unitsNearFullAmmo_%1", _side], []];
			_recipientDistSqr          = _c_maxActionDistSqr;

			// If no units are low on ammo, resupply nearby units that aren't fully resupplied
			{
				_distSqrX = _x distanceSqr _unit;

				if (_distSqrX < _recipientDistSqr) then {
					_recipientDistSqr = _distSqrX;
					_recipient        = _x;
				};
			} forEach _unitsNearFullAmmo;
		};

		// If no nearby units need resupplying, consider resupplying oneself
		if (isNull _recipient) then {

			if (_ammo < 1) then {
				_recipient = _unit;

			} else {
				// If not even the support unit needs ammo, exit the subsystem
				breakTo QGVAR(ai_sys_unitControl_loop_live);
			};
		};

		// Head to the recipients
		_actionPos = getPosWorld _recipient;

		// Match their stance
		if (_recipientDistSqr < _c_changeStanceDistSqr and {stance _recipient != "STAND"}) then {
			_unit setUnitPos "MIDDLE";
		};

		if (_recipientDistSqr < _c_maxActionDistSqr) then {
			[_unit, _recipient] call FUNC(act_tryResupplyUnit);
			_shouldStop = true;
		} else {
			_actionPos = _actionPos vectorAdd [1 - random 2, 1 - random 2, 0]; // Randomness to help the unit get close enough
		};

	} else {

		// If the unit is in the middle of being resupplied, stay put
		if (_time < _unit getVariable [QGVAR(ai_unitControl_handleResupply_stopTime), -1]) then {
			_shouldStop = true;
			breakTo QGVAR(ai_sys_unitControl_loop_live);
		};

		// Only look for a support when low on ammo
		if (_ammo > MACRO_UNIT_AMMO_THRESHOLDLOW) then {
			breakTo QGVAR(ai_sys_unitControl_loop_live);
		};

		private _support        = objNull;
		private _supportDistSqr = _c_maxResupplyDistSqr;
		private _unitsSupport   = GVAR(ai_sys_unitControl_cache) getOrDefault [format ["unitsSupport_%1", _side], []];
		private ["_distSqrX"];

		{
			_distSqrX = _unit distanceSqr _x;

			if (_distSqrX < _supportDistSqr) then {
				_supportDistSqr = _distSqrX;
				_support        = _x;
			};
		} forEach _unitsSupport;

		// If there is no support in the vicinity, exit the subsystem
		if (isNull _support) then {
			breakTo QGVAR(ai_sys_unitControl_loop_live);
		};

		// Head to the support
		_actionPos = getPosWorld _support;

		// Crouch while awaiting resupply
		if (_supportDistSqr < _c_changeStanceDistSqr and {stance _support != "STAND"}) then {
			_unit setUnitPos "MIDDLE";
		};

		if (_supportDistSqr < _c_maxActionDistSqr) then {
			_shouldStop = true;
		} else {
			_actionPos = _actionPos vectorAdd [1 - random 2, 1 - random 2, 0]; // Randomness to help the unit get close enough
		};
	};
};





// Handle stopping
[_shouldStop, MACRO_ENUM_AI_PRIO_RESUPPLY, _unit, ["PATH"], false] call FUNC(ai_toggleFeature);

if (_shouldStop) then {
	_unit setUnitPos "MIDDLE";
};
