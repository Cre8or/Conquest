/*
High-level plan:

	Squad leaders can give units direct orders (e.g. "move there", "regroup", "stop").

	Groups can have waypoints. These can apparently only be assigned by AI leaders. Assuming the unit
	has no direct order, move the group waypoint.
		- What happens when a unit has a direct order, and a group waypoint?
		- What if a unit is told to stop, but receives a group waypoint?
	--> Direct unit orders and group waypoints are equally important; whichever one is most recent
	should be used. This means a group waypoint can override a "stop" unit order, and vice versa.



	If any subsystems yielded a (scripted) move position, then that position has priority over unit
	orders and waypoints. The unit should follow the scripted move position, and upon completion,
	fall back to the previously issued move order (unit order or group waypoint).

	To enable this, we need to detect unit orders and group waypoints, and cache them, so that we
	may return to them later. Additionally, when issuing scripted move orders, we need to ensure
	that they don't get detected as unit orders.
	--> Whenever a unit order/group waypoint is detected, store its type and position (if necessary)
	on the unit

	The resulting priority is then (in decreasing order):
		- scripted move orders, THEN
		- direct unit orders / group waypoints

	TODO:
		- Differentiate between:
			- "Stop" unit order (halt / reached destination)
			- "Regroup" unit order (follow group leader)
			- "Move there" unit order / group waypoint
*/

// Define some macros
#define MACRO_DESTINATIONPOS_THRESHOLD 0.1
#define MACRO_ASSIGNEDVEHICLE_THRESHOLD 30

// Set up some variables
private _hasNewGoalPos = false;
private _prevGoalPos   = GVAR(ai_sys_unitControl_goalPosCache) param [_unitIndex, []];
private _goalPos       = [];





// Consume group waypoints
private _orderedMovePos = waypointPosition [_group, 1];
if (_orderedMovePos # 0 != 0 and {_orderedMovePos # 1 != 0}) then {

	// Ensure the last waypoint is always a "MOVE" waypoint
	private _waypoints     = waypoints _group;
	private _waypointsLast = count _waypoints - 1;
	private _curWaypoint   = _waypoints # _waypointsLast;
	private _waypointPos   = AGLtoASL waypointPosition _curWaypoint;
	if (waypointType _curWaypoint != "MOVE") then {
		_curWaypoint setWaypointType "MOVE";
	};

	// Always clean up all waypoints except the last one. This is how we detect change.
	for "_i" from _waypointsLast - 1 to 0 step -1 do {
		deleteWaypoint [_group, _i];
	};

	// Inform the group's units that a waypoint was detected
	{
		_x setVariable [QGVAR(ai_unitControl_planNextMovePos_waypointPos), _waypointPos, false];
	} forEach units _group;

	// Store the waypoint on the group (interfaces with ai_sys_commander)
	_group setVariable [QGVAR(ai_unitControl_waypointPos), _waypointPos, true];
};





// Initialisation: return to the previous goal (after respawning, or when moved into an AI driver group)
if !(_unit getVariable [QGVAR(ai_unitControl_planNextMovePos_init), false]) then {
	_hasNewGoalPos = true;

	if (_prevGoalPos isNotEqualTo []) then {
		_moveType = MACRO_ENUM_AI_MOVETYPE_GOAL;
		_goalPos  = _prevGoalPos;
	} else {
		if (_isLeaderPlayer) then {
			_moveType = MACRO_ENUM_AI_MOVETYPE_REGROUP;
		} else {
			_moveType = MACRO_ENUM_AI_MOVETYPE_GOAL;
			_goalPos  = _leader getVariable [QGVAR(ai_sys_unitControl_goalPos), []];
		};
	};

	_unit setVariable [QGVAR(ai_unitControl_planNextMovePos_init), true, false];
};





// Scripted moves (actions)
if (_actionPos isNotEqualTo []) then {

	_moveType = MACRO_ENUM_AI_MOVETYPE_ACTION;

	//systemChat format ["(%1) %2: New action @ %3", _time, _unit, _actionPos apply {(round (_x * 10)) / 10}];

// Engine-level moves (goals)
} else {

	// Goal 1: group waypoints
	if (!_hasNewGoalPos) then {
		private _waypointPos = _unit getVariable [QGVAR(ai_unitControl_planNextMovePos_waypointPos), []];

		if (_waypointPos isNotEqualTo []) then {
			_hasNewGoalPos = true;
			_moveType      = MACRO_ENUM_AI_MOVETYPE_GOAL;
			_goalPos       = _waypointPos;

			_unit setVariable [QGVAR(ai_unitControl_planNextMovePos_waypointPos), [], false];
			_unit setVariable [QGVAR(ai_unitControl_moveToPos_nextUpdate), 0, false]; // Force a route update
		};
	};
/*
	NOTE: The following expectedDestination trickery is the root of all evil.

	I spent far too many hours trying to allow every player-AI-interaction to occur, while also
	allowing the subsystem to override behaviour where necessary - and it was excruciatingly painful.
	It is no exaggeration when I say that it cost me more than an entire *week* to get this (mostly)
	working, and it is still far from perfect.

	If you're reading this, and are asking yourself why I've implemented anything below the way that
	it's implemented: I honestly couldn't tell you. I spent far too long working out what works and what
	doesn't, that I couldn't be bothered to keep track of my findings. Eventually, I ended up with this
	implementation, and it gets the job done.
*/
	// Goal 2: direct orders
	if (!_hasNewGoalPos) then {
		(expectedDestination _unit) params ["_destinationPos", "_destinationKind"];
		private _prevDestinationPos = _unit getVariable [QGVAR(ai_unitControl_planNextMovePos_destinationPos), _unitPos];

		switch (toUpper _destinationKind) do {
			case "LEADER DIRECT";
			case "LEADER PLANNED";
			case "VEHICLE PLANNED:": {

				// AI squad leaders don't give their units orders, so we only need to consider players.
				// Additionally, when units seek cover (in combat), that gets detected as an order (which it isn't!).
				if (_isLeaderPlayer) then {
					private _assignedVeh = assignedVehicle _unit;

					if (
						_isInVehicle
						or {_destinationPos distanceSqr ASLtoAGL getPosWorld _assignedVeh > MACRO_ASSIGNEDVEHICLE_THRESHOLD ^ 2}
					) then {
						_hasNewGoalPos = vectorMagnitudeSqr (_destinationPos vectorDiff _prevDestinationPos) > MACRO_DESTINATIONPOS_THRESHOLD ^ 2;
						_moveType      = MACRO_ENUM_AI_MOVETYPE_GOAL;
						_goalPos       = AGLtoASL _destinationPos;

						if (!_isInVehicle) then {
							unassignVehicle _unit;
						};
					} else {
						_hasNewGoalPos = (_prevGoalPos isNotEqualTo []);
						_moveType      = MACRO_ENUM_AI_MOVETYPE_GOAL;
					};
				};
			};

			case "FORMATION PLANNED";
			case "DONOTPLANFORMATION": {
				if (_isLeaderPlayer) then {
					if (!_isInVehicle) then {
						unassignVehicle _unit;
					};

					private _leaderPos = getPosWorld _leader;
					_moveType          = MACRO_ENUM_AI_MOVETYPE_REGROUP;

					if (_isDriver) then {
						private _prevLeaderPos = _unit getVariable [QGVAR(ai_unitControl_planNextMovePos_leaderPos), _unitPos];

						_hasNewGoalPos = (vectorMagnitudeSqr (_leaderPos vectorDiff _prevLeaderPos) > MACRO_DESTINATIONPOS_THRESHOLD ^ 2);
						_goalPos       = _leaderPos;

						_unit setVariable [QGVAR(ai_unitControl_planNextMovePos_leaderPos), _leaderPos, false];
					} else {
						_hasNewGoalPos = (_prevGoalPos isNotEqualTo []);

						if (formLeader _unit != _leader) then {
							_unit doFollow _leader;
						};
					};

				} else {
					if (_isLeader) then {
						if (_isDriver) then {
							_hasNewGoalPos = (_moveType != MACRO_ENUM_AI_MOVETYPE_GOAL);
							_moveType      = MACRO_ENUM_AI_MOVETYPE_GOAL;
						} else {
							_hasNewGoalPos = (_moveType != MACRO_ENUM_AI_MOVETYPE_HALT);
							_moveType      = MACRO_ENUM_AI_MOVETYPE_HALT;
						};
					} else {
						// Regroup on the AI leader if they've halted and are on foot
						if (
							vehicle _leader == _leader
							and {_leader getVariable [QGVAR(ai_sys_unitControl_moveType), MACRO_ENUM_AI_MOVETYPE_HALT] == MACRO_ENUM_AI_MOVETYPE_HALT}
						) then {
							_hasNewGoalPos = (_moveType != MACRO_ENUM_AI_MOVETYPE_REGROUP);
							_moveType      = MACRO_ENUM_AI_MOVETYPE_REGROUP;
						};
					};
				};
			};

			case "DONOTPLAN": {
				// Filter out false-positives. Issuing the "Stop" order as group leader resets the destination,
				// while simply reaching the destination does not (evne though the kind ends up as DoNotPlan).
				if (!_isDriver and {_destinationPos # 0 == 0} and {_destinationPos # 1 == 0}) then {
					_hasNewGoalPos = (_moveType != MACRO_ENUM_AI_MOVETYPE_HALT);
					_moveType      = MACRO_ENUM_AI_MOVETYPE_HALT;
				};
			};
		};

		_unit setVariable [QGVAR(ai_unitControl_planNextMovePos_destinationPos), _destinationPos, false];
	};

	// Fallback 1: when coming out of a scripted action, return to the "GOAL" movetype
	if (_moveType == MACRO_ENUM_AI_MOVETYPE_ACTION) then {
		_moveType = MACRO_ENUM_AI_MOVETYPE_GOAL;
	};





	// Validate the new goal position
	if (_hasNewGoalPos) then {

		if (_goalPos isNotEqualTo []) then {
			_goalPos = ([_goalPos, _side] call FUNC(ca_getValidPos));
		};

		//systemChat format ["(%1) %2: New goal: %3 @ %4", _time, _unit, _moveType, _goalPos apply {(round (_x * 10)) / 10}];

		// Cache the new move data (as default value for respawned units)
		GVAR(ai_sys_unitControl_goalPosCache) set [_unitIndex, _goalPos];

		private _shouldBroadcastGoalPos = _isLeader or {_isInVehicle}; // Drivers and group leaders broadcast their goalPos (interfaces with ai_sys_commander on remote machines)
		_unit setVariable [QGVAR(ai_sys_unitControl_goalPos), _goalPos, _shouldBroadcastGoalPos];
	};
};

_unit setVariable [QGVAR(ai_sys_unitControl_moveType), _moveType, false];





#ifdef MACRO_DEBUG_AI_MOVEPOS
	private _debug_movePos = (switch (_moveType) do {
		case MACRO_ENUM_AI_MOVETYPE_HALT:   {_unitPos};
		case MACRO_ENUM_AI_MOVETYPE_ACTION: {_actionPos};
		default                             {_unit getVariable [QGVAR(ai_sys_unitControl_goalPos), []]};
	});

	if (_debug_movePos isNotEqualTo []) then {
		GVAR(debug_ai_unitControl_planNextMovePos_data) set [_unitIndex, [
			_unit,
			ASLtoAGL _debug_movePos,
			switch (_moveType) do {
				case MACRO_ENUM_AI_MOVETYPE_REGROUP: {[0, 1, 1, 1]},
				case MACRO_ENUM_AI_MOVETYPE_GOAL:    {[1, 1, 0, 1]},
				case MACRO_ENUM_AI_MOVETYPE_ACTION:  {[0, 1, 0, 1]},
				default                              {[0, 0, 1, 1]}
			},
			_moveType
		]];
	} else {
		GVAR(debug_ai_unitControl_planNextMovePos_data) set [_unitIndex, nil];
	};

#endif
