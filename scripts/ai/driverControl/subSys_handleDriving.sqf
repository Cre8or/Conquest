// Set up some variables
private _speed     = speed _veh;
private _velLength = vectorMagnitude _vehVel;
private _c_maxAvoidanceDistSqr = MACRO_AI_DRIVER_AVOIDANCE_MAXDISTANCE ^ 2;

#define MACRO_VEHICLE_STUCK_DURATION 3
#define MACRO_VEHICLE_UNSTUCK_DURATION 2





// Edge case: prevent tracked vehicles from reversing uncontrollably
if (_hasTracks and {!_shouldHalt}) then {
	if (_speed < 0) then {
		private _reverseTime = _unit getVariable [QGVAR(ai_sys_driverControl_reverseTime), -1];
		_shouldHalt = (_time < _reverseTime);

		if (_reverseTime < 0) then {
			_reverseTime = _time;
			_unit setVariable [QGVAR(ai_sys_driverControl_reverseTime), _reverseTime, false];
		};

		if (_time - _reverseTime > MACRO_VEHICLE_STUCK_DURATION) then {
			_unit setVariable [QGVAR(ai_sys_driverControl_reverseTime), _time + MACRO_VEHICLE_UNSTUCK_DURATION, false];
			_unit setVariable [QGVAR(ai_sys_driverControl_prevMoveDir), 1, false]; // Forward
		};
	} else {
		_unit setVariable [QGVAR(ai_sys_driverControl_reverseTime), -1, false];
	};
};



// Handle halting
if (_shouldHalt) then {
	_veh limitSpeed 0.0001;

	// Restore the brakes
	if (brakesDisabled _veh) then {
		_veh disableBrakes false;
	};

	if (_hasTracks and {abs _speed > 0.1}) then {
		_veh setDriveOnPath [_vehPos, _vehPos vectorAdd [0,0,50]]; // Needed to actually stop tracked vehicles from driving (otherwise they keep rolling, even with limited speed!)
	};

	_unit setVariable [QGVAR(ai_sys_driverControl_reverseTime), -1, false];
	_unit setVariable [QGVAR(ai_sys_driverControl_stuckStartTime), -1, false];
	_unit setVariable [QGVAR(ai_sys_driverControl_tryUnstuckTime), -1, false];



// Handle driving
} else {
	private _tryUnstuckTime = _unit getVariable [QGVAR(ai_sys_driverControl_tryUnstuckTime), -1];
	private _isStuck = (_time < _tryUnstuckTime);

	// Detect when the vehicle is stuck
	if (!_isStuck) then {
		if (isTouchingGround _veh and {abs _speed < 3}) then {
			private _stuckStartTime = _unit getVariable [QGVAR(ai_sys_driverControl_stuckStartTime), -1];

			if (_stuckStartTime < 0) then {
				_stuckStartTime = _time;
				_unit setVariable [QGVAR(ai_sys_driverControl_stuckStartTime), _stuckStartTime, false];
			};

			if (_time - _stuckStartTime > MACRO_VEHICLE_STUCK_DURATION) then {
				_isStuck = true;
				private _prevMoveDir = _unit getVariable [QGVAR(ai_sys_driverControl_prevMoveDir), 1];

				_unit setVariable [QGVAR(ai_sys_driverControl_tryUnstuckTime), _time + MACRO_VEHICLE_UNSTUCK_DURATION, false];
				_unit setVariable [QGVAR(ai_sys_driverControl_stuckStartTime), -1, false];
				_unit setVariable [QGVAR(ai_sys_driverControl_prevMoveDir), [-1, 1] select (_prevMoveDir < 0), false];
			};

		// Reset the stuck time
		} else {
			_unit setVariable [QGVAR(ai_sys_driverControl_prevMoveDir), [-1, 1] select (_speed > 0), false];
			_unit setVariable [QGVAR(ai_sys_driverControl_stuckStartTime), -1, false];
		};
	};

	// Disable the brakes when stuck
	private _disableBrakes = (abs _speed < 1 or {_isStuck});

	if (_disableBrakes != brakesDisabled _veh) then {
		_veh disableBrakes _disableBrakes;
	};

	// Push the vehicle when stuck
	if (_isStuck) then {
		private _prevMoveDir = _unit getVariable [QGVAR(ai_sys_driverControl_prevMoveDir), 1];
		_veh addForce [vectorDir _veh vectorMultiply (_prevMoveDir * 5 * MACRO_AI_DRIVERCONTROL_INTERVAL * getMass _veh), getCenterOfMass _veh];
	};



	// Set up coordinate systems around the route
	private _prevRoutePos       = _pathRoute param [_pathIndex - 1, _vehPos];
	private _vecRouteForward    = _prevRoutePos vectorFromTo _routePos;
	private _vecRouteRight      = _vecRouteForward vectorCrossProduct [0, 0, 1];
	private _vecVehRouteForward = _vehPos vectorFromTo _routePos;
	private _vecVehRouteRight   = _vecVehRouteForward vectorCrossProduct [0, 0, 1];

	// Avoid other vehicles and wreckages using a simulated repulsion force to alter the route position
	private _avoidanceForce = [0, 0, 0];
	private _avoidanceMul   = 1;
	private ["_radiusX", "_maxRadius", "_avoidanceForceX"];
	{
		if (_x == _veh) then {
			continue;
		};

		_radiusX   = 0.6 * (2 boundingBoxReal _x) # 2;
		_maxRadius = 1.5 * (_vehRadius max _radiusX); // Slightly more radius as an extra safety margin

		_avoidanceForceX = [_vehPos, getPosWorld _x, _vehVel, velocity _x, _maxRadius, 1] call FUNC(veh_getAvoidanceForce);
		_avoidanceForce  = _avoidanceForce vectorAdd _avoidanceForceX;
		_avoidanceMul    = 0 max _avoidanceMul * (1 - vectorMagnitude _avoidanceForceX);

	} forEach (GVAR(allVehicles) select {_x distanceSqr _veh < _c_maxAvoidanceDistSqr});



	// Add a corrective force to pull the vehicle back onto its current node segment (scales with distance and speed)
	private _distFromRoute = (_routePos vectorDiff _vehPos) vectorDotProduct _vecRouteRight;
	private "_prevDistFromRoute";

	if (_routeIndexChanged) then {
		_prevDistFromRoute = _distFromRoute;
	} else {
		_prevDistFromRoute = _unit getVariable [QGVAR(ai_sys_driverControl_prevDistFromRoute), _distFromRoute];
	};

 	// Coefficients determined empirically (by testing at various speeds)
	private _deltaDistFromRoute = (_distFromRoute - _prevDistFromRoute) / MACRO_AI_DRIVERCONTROL_INTERVAL;
	private _routeAlignForce    = _vecRouteRight vectorMultiply ((_distFromRoute * 1.3 + _deltaDistFromRoute) * MACRO_AI_DRIVER_FORCEMUL_ROUTEALIGN / (10 + _velLength));

	_unit setVariable [QGVAR(ai_sys_driverControl_prevDistFromRoute), _distFromRoute, false];



	// Determine the target speed based on route curvature and remaining distance
	private ["_lookAheadIndex", "_lookAheadIteration", "_posX_0", "_posX_1", "_lookAheadDist", "_maxLookAheadDist", "_mulDot", "_worstTurnMul", "_distX", "_posX_2", "_radiusX", "_mulDotX", "_dotX"];
	_lookAheadIndex     = _pathIndex;
	_lookAheadIteration = 0;
	_posX_0             = _vehPos;
	_posX_1             = _routePos; // _pathRoute # _lookAheadIndex;
	_lookAheadDist      = 0;
	_maxLookAheadDist   = (_velLength ^ 2 / 8) + _velLength * 4 + 20;
	_mulDot             = (vectorDir _veh) vectorDotProduct _vecVehRouteForward;
	_worstTurnMul       = (_mulDot ^ 3) max 0;

	scopeName QGVAR(ai_sys_driverControl_drive);

	if (_mulDot > 0) then {
		while {_lookAheadIteration < MACRO_AI_DRIVER_LOOKAHEAD_MAXITERATIONS} do {
			_distX              = _posX_0 distance2D _posX_1;
			_lookAheadDist      = _lookAheadDist + _distX;
			_lookAheadIteration = _lookAheadIteration + 1;
			_lookAheadIndex     = _pathIndex + _lookAheadIteration;

			if (
				_lookAheadDist > MACRO_AI_DRIVER_LOOKAHEAD_MAXDIST
				or {_lookAheadIndex > _pathIndexLast}
			) then {
				_lookAheadDist = _lookAheadDist min MACRO_AI_DRIVER_LOOKAHEAD_MAXDIST;
				breakTo QGVAR(ai_sys_driverControl_drive);
			};

			_posX_2  = _pathRoute # _lookAheadIndex;
			_radiusX = _pathRadii # _lookAheadIndex;
			_mulDotX = (_maxLookAheadDist - _radiusX - _lookAheadDist) / _maxLookAheadDist;

			if (_mulDotX > 0) then {
				_dotX = (1 - _mulDotX) + _mulDotX * (([_posX_0, _posX_1, _posX_1, _posX_2 vectorDiff _vehVel, true] call FUNC(math_dot2D)) max 0);
			} else {
				_dotX = 1;
			};

			_worstTurnMul = _worstTurnMul min _dotX;
			_posX_0       = _posX_1;
			_posX_1       = _posX_2;
		};
	};

	_worstTurnMul     = _worstTurnMul ^ 2;
	_distRemainingMul = (_lookAheadDist / _maxLookAheadDist) min 1;

	_targetSpeed = 10 + MACRO_AI_DRIVER_MAXSPEED * (_avoidanceMul min _worstTurnMul min _distRemainingMul);
	_targetSpeed = 0.001; // DEBUG

	private _routeAttractionForce = _vecVehRouteForward;
	private _sumOfForces = _avoidanceForce vectorAdd _routeAlignForce vectorAdd _routeAttractionForce;

	// Remap the sum of forces to always be 100 units long
	private _sumOfForcesRemapped = (vectorNormalized _sumOfForces) vectorMultiply 100;
	_veh setDriveOnPath [_vehPos, _vehPos vectorAdd _sumOfForcesRemapped];

	#ifdef MACRO_DEBUG_AI_DRIVER
		GVAR(debug_ai_driverControl_data) set [_unitIndex, [_veh, _sumOfForces vectorMultiply _vehRadius, ASLtoAGL _routePos, _targetSpeed]];

		private _str = "<t size='0.75' font='EtelkaMonospacePro'><t color='#00aaff'>ai_sys_driverControl</t><br/>";
		_str = _str + "<br/>";
		_str = _str + format ["<t align='left' color='#e06c75'>pathIndex:</t> <t align='right' color='#%a3d87d'>%1</t><br/>", _pathIndex];
		_str = _str + format ["<t align='left' color='#e06c75'>pathIndexLast:</t> <t align='right' color='#%a3d87d'>%1</t><br/>", _pathIndexLast];
		_str = _str + "<t align='center' color='#888888'>-----------------------------------</t><br/>";
//		_str = _str + format ["<t align='left' color='#e06c75'>lookAheadIndex:</t> <t align='right' color='#%a3d87d'>%1</t><br/>", _lookAheadIndex];
//		_str = _str + format ["<t align='left' color='#e06c75'>lookAheadDist:</t> <t align='right' color='#%a3d87d'>%1</t><br/>", round (_lookAheadDist * 10) / 10];
//		_str = _str + format ["<t align='left' color='#e06c75'>maxLookAheadDist:</t> <t align='right' color='#%a3d87d'>%1</t><br/>", round (_maxLookAheadDist * 10) / 10];
		_str = _str + format ["<t align='left' color='#e06c75'>distRemainingMul:</t> <t align='right' color='#%a3d87d'>%1</t><br/>", round (_distRemainingMul * 1000) / 1000];
		_str = _str + format ["<t align='left' color='#e06c75'>avoidanceMul:</t> <t align='right' color='#%a3d87d'>%1</t><br/>", round (_avoidanceMul * 1000) / 1000];
		_str = _str + format ["<t align='left' color='#e06c75'>worstTurnMul:</t> <t align='right' color='#%a3d87d'>%1</t><br/>", round (_worstTurnMul * 1000) / 1000];
		_str = _str + "<t align='center' color='#888888'>-----------------------------------</t><br/>";
		_str = _str + format ["<t align='left' color='#e06c75'>speed:</t> <t align='right' color='#%a3d87d'>%1</t><br/>", round (_speed * 10) / 10];
		_str = _str + format ["<t align='left' color='#e06c75'>targetSpeed:</t> <t align='right' color='#%a3d87d'>%1</t><br/>", ceil _targetSpeed];
		_str = _str + "<t align='center' color='#888888'>-----------------------------------</t><br/>";
		_str = _str + format ["<t align='left' color='#e06c75'>hasTracks:</t> <t align='right' color='#%a3d87d'>%1</t><br/>", _hasTracks];
		_str = _str + format ["<t align='left' color='#e06c75'>isStuck:</t> <t align='right' color='#%a3d87d'>%1</t><br/>", _isStuck];
		_str = _str + "<t/>";
		hintSilent parseText _str;
	#endif

	_veh forceSpeed -1;
	_veh limitSpeed _targetSpeed;
};
