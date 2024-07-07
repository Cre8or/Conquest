// Setup some variables
private _groupIndex                  = _unit getVariable [QGVAR(groupIndex), -1];
private _originalGroup               = missionNamespace getVariable [format [QGVAR(AIGroup_%1_%2), _side, _groupIndex], grpNull];
private _isOriginalGroupLeaderPlayer = isPlayer leader _originalGroup;





// Create a new vehicle group for the driver.
// This is necessary to stop dismounted AI squad leaders from interfering with scripted commands,
// such as setDriveOnPath (as used by ai_sys_driverControl).
if (_isDriver and {!_isOriginalGroupLeaderPlayer}) then {

	if (
		!(_group getVariable [QGVAR(isVehicleGroup), false])
		and {{alive _x} count units _group > 1}
	) then {
		private _driverGroup = createGroup [_side, true];

		if (!isNull _driverGroup) then {
			_driverGroup setVariable [QGVAR(isVehicleGroup), true, true];
			_driverGroup setGroupIDGlobal [groupID _originalGroup + " Vic " + str (_unit getVariable [QGVAR(unitIndex), 0])];

			[_unit] joinSilent _driverGroup;
			_driverGroup selectLeader _unit;
			//systemChat format ["%1 creating driver group: %2", _unit, groupID _driverGroup];

			_group          = _driverGroup;
			_leader         = _unit;
			_isLeader       = true;
			_isLeaderPlayer = false;

			// Carry over the previous goal position as a new group waypoint
			private _goalPos = _unit getVariable [QGVAR(ai_sys_unitControl_goalPos), []];
			if (_goalPos isNotEqualTo []) then {
				_group addWaypoint [ASLtoATL _goalPos, 0];
			};
		};
	};

// Return to the previous group and delete the driver group
} else {

	if (_group getVariable [QGVAR(isVehicleGroup), false] and {!isNull _originalGroup}) then {
		[_unit] joinSilent _originalGroup;
		deleteGroup _group;
		//systemChat format ["%1 Returning to group: %2", _unit, groupID _originalGroup];

		// Handle leadership
		if (!_isOriginalGroupLeaderPlayer and {_unit getVariable [QGVAR(isLeader), false]}) then {
			_originalGroup selectLeader _unit;
		};

		_group          = group _unit; // Don't assign to _originalGroup, as joinSilent can fail
		_leader         = leader _group;
		_isLeader       = (_unit == _leader);
		_isLeaderPlayer = isPlayer _leader;

		// Reapply the group leader's waypoint onto the unit
		_unit setVariable [QGVAR(ai_unitControl_planNextMovePos_init), false, false];
	};
};
