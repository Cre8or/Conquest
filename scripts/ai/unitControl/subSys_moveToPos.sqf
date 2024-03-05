// Define some macros
#define MACRO_DELTAMOVEPOS_RATIO_THRESHOLD 0.1 // Threshold ratio between the unit-movePos distance and the delta of the new movePos, beyond which a path is recalculated

// Set up some variables
private _movePos = (switch (_moveType) do {
	case MACRO_ENUM_AI_MOVETYPE_REGROUP;
	case MACRO_ENUM_AI_MOVETYPE_GOAL:   {_unit getVariable [QGVAR(ai_sys_unitControl_goalPos), []]};
	case MACRO_ENUM_AI_MOVETYPE_ACTION: {_actionPos};
	default                             {[]}; // No move order
});
private _pathData = _unit getVariable [QGVAR(ai_unitControl_moveToPos_pathData), []];





if (
	_movePos isNotEqualTo []
	and {!_isInVehicle or {_isDriver}} // Only allow infantry and vehicle drivers to request paths
) then {
	private _prevMovePos      = _unit getVariable [QGVAR(ai_unitControl_moveToPos_movePos), _movePos];
	private _distMovePos      = 0.1 max (_unitPos distance _movePos);
	private _distDeltaMovePos = vectorMagnitude (_movePos vectorDiff _prevMovePos);

	if (
		_changedVehicle
		or {_distDeltaMovePos / _distMovePos > MACRO_DELTAMOVEPOS_RATIO_THRESHOLD}
		or {
			_time > _unit getVariable [QGVAR(ai_unitControl_moveToPos_nextUpdate), 0]
			and {!(_unit getVariable [QGVAR(ai_unitControl_moveToPos_finished), false])}
		}
	) then {
		private _curNodeID = -1;

		// Special case for drivers: when processing a new route, try to stay on the current route by
		// enforcing the first node to be the one the driver was currently headed to.
		// However, if the route's current node is too far away from the vehicle, discard it and start
		// a new search from scratch.
		if (_isDriver and {speed _unitVeh > 15}) then {
			_pathData           = _unit getVariable [QGVAR(ai_unitControl_moveToPos_pathData), []];
			private _route      = _pathData param [0, []];
			private _curNodePos = _route param [_unit getVariable [QGVAR(ai_unitControl_moveToPos_pathIndex), -1], _unitPos];

			if (_unitPos distanceSqr _curNodePos < MACRO_NM_SEARCHRADIUS_NODES_VEH ^ 2) then {
				_curNodeID = _unit getVariable [QGVAR(ai_driverControl_currentNodeID), -1];
			};
		};

		//systemChat format ["(%1) %2: Calculating route: %3 (%4 / %5)", _time, _unit, _movePos apply {(round (_x * 10)) / 10}, _distDeltaMovePos, _distMovePos];
		_pathData = [_unit, _movePos, _isInVehicle, !_isDriver, _curNodeID] call FUNC(nm_findPath);

		// Reset the route data
		_unit setVariable [QGVAR(ai_unitControl_moveToPos_movePos), _movePos, false];
		_unit setVariable [QGVAR(ai_unitControl_moveToPos_nextUpdate), _time + ([MACRO_AI_PATHFINDINTERVAL_INF, MACRO_AI_PATHFINDINTERVAL_VEH] select _isInVehicle), false];
		_unit setVariable [QGVAR(ai_unitControl_moveToPos_pathData), _pathData, false];
		_unit setVariable [QGVAR(ai_unitControl_moveToPos_pathIndex), 1, false]; // Node #0 is the unit's position (for reference), so we ignore it
		_unit setVariable [QGVAR(ai_unitControl_moveToPos_pathIndexLast), count (_pathData # 0) - 1, false];
		_unit setVariable [QGVAR(ai_unitControl_moveToPos_nextMoveTime), 0, false];
		_unit setVariable [QGVAR(ai_unitControl_moveToPos_finished), false, false];
	};

} else {
	if (_pathData isNotEqualTo []) then {
		_pathData = [];

		_unit setVariable [QGVAR(ai_unitControl_moveToPos_pathData), _pathData, false];
		_unit setVariable [QGVAR(ai_unitControl_moveToPos_pathIndex), 0, false];
		_unit setVariable [QGVAR(ai_unitControl_moveToPos_pathIndexLast), -1, false];
	};
};





// Infantry only: move along the route
// Vehicle movement is performed in ai_sys_driverControl
if (!_isInVehicle) then {
	private _pathIndex         = _unit getVariable [QGVAR(ai_unitControl_moveToPos_pathIndex), 0];
	private _pathIndexLast     = _unit getVariable [QGVAR(ai_unitControl_moveToPos_pathIndexLast), 0];
	private _newDestinationPos = [];
	private _continueLoop      = (_pathIndex <= _pathIndexLast);
	private ["_routePos", "_completionRadiusSqr"];

	// Check if we have a route to follow
	while {_continueLoop} do {

		_continueLoop = false; // Default behaviour: exit after one iteration
		_pathData params ["_pathRoute", "_pathRadii"];

		_routePos            = _pathRoute param [_pathIndex, []];
		_completionRadiusSqr = _pathRadii param [_pathIndex, MACRO_NM_DEFAULTRADIUS_INF ^ 2];

		// Check for node completion
		if (_unitPos distanceSqr _routePos < _completionRadiusSqr) then {
			//systemchat format ["Completed node %1/%2 (%3)", _pathIndex, _pathIndexLast, sqrt _completionRadiusSqr];

			_pathIndex    = _pathIndex + 1;
			_continueLoop = (_pathIndex <= _pathIndexLast);

			// No more nodes
			if (!_continueLoop) then {
				_unit setVariable [QGVAR(ai_unitControl_moveToPos_finished), true, false];
			};

			_unit setVariable [QGVAR(ai_unitControl_moveToPos_pathIndex), _pathIndex, false];
			_unit setVariable [QGVAR(ai_unitControl_moveToPos_nextMoveTime), 0, false];

		// If outside of the completion radius, move towards the position
		} else {
			if (_time > _unit getVariable [QGVAR(ai_unitControl_moveToPos_nextMoveTime), 0]) then {
				_newDestinationPos = ASLtoATL _routePos;
			};
		};
	};

	// Send the unit to the new destination. Only do this once per frame.
	// NOTE: doMove orders the unit to go to the position, and prevents AI squad leaders from tampering with the unit.
	// It does not, however, update the expectedDestination. As such, we *also* need moveTo to update that data.
	// This may seem strange, but that's how the AI currently works (v2.13.150296).
	if (_newDestinationPos isNotEqualTo []) then {
		_unit doMove _newDestinationPos;
		_unit moveTo _newDestinationPos;

		_unit setVariable [QGVAR(ai_unitControl_moveToPos_nextMoveTime), _time + MACRO_AI_DOMOVEINTERVAL, false];
		_unit setVariable [QGVAR(ai_unitControl_planNextMovePos_destinationPos), _newDestinationPos, false];
	};
};







#ifdef MACRO_DEBUG_AI_MOVEPOS
	if (
		_movePos isEqualTo []
		or {_moveType == MACRO_ENUM_AI_MOVETYPE_HALT}
		or {_isInVehicle and {!_isDriver}}
	) then {
		GVAR(debug_ai_unitControl_moveToPos_route) set [_unitIndex, nil];
	} else {
		private _debug_route         = [];
		private _debug_pathIndex     = _unit getVariable [QGVAR(ai_unitControl_moveToPos_pathIndex), 0];
		private _debug_pathIndexLast = _unit getVariable [QGVAR(ai_unitControl_moveToPos_pathIndexLast), 0];
		private _debug_pathData      = _unit getVariable [QGVAR(ai_unitControl_moveToPos_pathData), []];
		_debug_pathData              = ([_unitPos] + ((_debug_pathData # 0) select [_debug_pathIndex, _debug_pathIndexLast + 1])) apply {ASLtoATL _x vectorAdd [0, 0, 0.5]};
		for "_i" from 0 to count _debug_pathData - 2 do {
			_debug_route pushBack [
				_debug_pathData # _i,
				_debug_pathData # (_i + 1),
				[1,1,0,1]
			];
		};
		GVAR(debug_ai_unitControl_moveToPos_route) set [_unitIndex, _debug_route];
	};
#endif
