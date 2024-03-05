// Set up some variables
_mountUpQueue        = _veh getVariable [QGVAR(ai_sys_driverControl_mountUpQueue), []];
_mountUpAccumulator  = _veh getVariable [QGVAR(ai_sys_driverControl_mountUpAccumulator), 0];
_mountUpCooldownTime = _veh getVariable [QGVAR(ai_sys_driverControl_mountUpCooldownTime), -1];





// Check if the unit is waiting for passengers to mount up
if (_time < _mountUpCooldownTime) then {
	_mountUpAccumulator = 0;

	if (_mountUpQueue isNotEqualTo []) then {
		_mountUpQueue = [];
		_veh setVariable [QGVAR(ai_sys_driverControl_mountUpQueue), _mountUpQueue, false];
	};

} else {
	if (_mountUpQueue isNotEqualTo []) then {
		_shouldHalt         = true;
		_mountUpAccumulator = _mountUpAccumulator + MACRO_AI_DRIVERCONTROL_INTERVAL;

		// To prevent vehicles from remaining idle for too long while waiting for units to mount up, enter
		// a cool-down period once the time accumulator is full, and ignore any further requests for transport.
		if (_mountUpAccumulator > MACRO_AI_DRIVER_MOUNT_DURATION) then {
			_mountUpQueue        = [];
			_mountUpCooldownTime = _time + MACRO_AI_DRIVER_MOUNT_COOLDOWN;

			_veh setVariable [QGVAR(ai_sys_driverControl_mountUpQueue), _mountUpQueue, false];
			_veh setVariable [QGVAR(ai_sys_driverControl_mountUpCooldownTime), _mountUpCooldownTime, false];
		};

		// Process the mount-up queue
		private "_unitX";
		for "_i" from count _mountUpQueue - 1 to 0 step -1 do {
			_unitX = _mountUpQueue # _i;

			if (
				_unitX != vehicle _unitX
				or {_unitX distanceSqr _veh > MACRO_AI_CLAIMVEHICLE_MAXDIST ^ 2}
				or {!([_unitX] call FUNC(unit_isAlive))}
			) then {
				_mountUpQueue deleteAt _i;
			};
		};

	// No requests; decrease the accumulator
	} else {
		_mountUpAccumulator = _mountUpAccumulator - (MACRO_AI_DRIVERCONTROL_INTERVAL * MACRO_AI_DRIVER_MOUNT_DURATION / MACRO_AI_DRIVER_MOUNT_COOLDOWN) max 0;
	};
};

_veh setVariable [QGVAR(ai_sys_driverControl_mountUpAccumulator), _mountUpAccumulator, false];
