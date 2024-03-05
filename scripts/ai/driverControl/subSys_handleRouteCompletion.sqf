// Set up some variables
private _loopThroughRoute = (_pathIndex <= _pathIndexLast);





if (_loopThroughRoute) then {
	private _vehPosPredicted = _vehPos vectorAdd (_vehVel vectorMultiply 0.35);
	private ["_completionRadius", "_nodeID"];

	// Select the current node along the route
	while {_loopThroughRoute} do {

		_loopThroughRoute = false;
		_routePos         = _pathRoute param [_pathIndex, []];
		_completionRadius = _pathRadii param [_pathIndex, MACRO_NM_DEFAULTRADIUS_VEH ^ 2];
		_nodeID           = _pathNodes param [_pathIndex, objNull] getVariable [QGVAR(nodeID), -1];

		// Node completion
		if (_vehPosPredicted distanceSqr _routePos < (_completionRadius max _vehRadius) ^ 2) then {
			//systemchat format ["(%1) Completed node %2/%3 (%4)", _time, _pathIndex, _pathIndexLast, sqrt _completionRadius];

			_pathIndex         = _pathIndex + 1;
			_loopThroughRoute  = (_pathIndex <= _pathIndexLast);
			_routeIndexChanged = true;

			// No more nodes
			if (!_loopThroughRoute) then {
				_routePos   = [];

				_unit setVariable [QGVAR(ai_unitControl_moveToPos_finished), true, false];
			};

			_unit setVariable [QGVAR(ai_unitControl_moveToPos_pathIndex), _pathIndex, false];
		};
	};

	_unit setVariable [QGVAR(ai_driverControl_currentNodeID), _nodeID, false];

// No Road Left :chefkiss:
} else {
	_routePos = [];

	_unit setVariable [QGVAR(ai_driverControl_currentNodeID), -1, false];
};



// If no route is left, halt the vehicle
_shouldHalt = _shouldHalt or {_routePos isEqualTo []};
