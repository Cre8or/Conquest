if (
	!_isLeaderPlayer
) then {

	// Set up some variables
	private _unitVehRoleData = [_unit] call FUNC(unit_getVehicleRole);
	private _unitVehRole     = _unitVehRoleData # 0;
	private _curGoalPos      = _unit getVariable [QGVAR(ai_sys_unitControl_goalPos), []];
	private _maxDistSqr      = MACRO_AI_CLAIMVEHICLE_MAXDIST ^ 2;
	private _distToGoalSqr   = 0;
	private ["_driver", "_driverGoalPos"];

	if (_curGoalPos isNotEqualTo []) then {
		_distToGoalSqr = _unitPos distanceSqr _curGoalPos;
	};

	scopeName QGVAR(subSys_claimVehicle);





	if (
		_time > _unit getVariable [QGVAR(ai_unitControl_claimVehicle_nextUpdate), 0]
		and {_actionPos isEqualTo []}
	) then {

		private ["_candidateVehicles", "_vehX", "_occupiedBy"];

		// Determine candidate vehicles
		if (_isInVehicle) then {
			_candidateVehicles = [[0, _unitVeh]];

		} else {
			_candidateVehicles = [];

			if (GVAR(param_ai_allowVehicles)) then {
				{
					_vehX = _x;

					if ([_vehX, _unit] call FUNC(veh_isClaimable)) then {
						_candidateVehicles pushBack [_unit distanceSqr _vehX, _vehX];
					};
				} forEach GVAR(allVehicles);

				_candidateVehicles sort true;
			};
		};

		// Inspect the candidates
		{
			_vehX  = _x # 1;

			{
				_x params ["_vehRole", "_turretPath", "_cargoIndex"];

				// Only consider vehicle roles that are "better" than the current one (or any if we don't have one yet)
				if !(
					_unitVehRole == MACRO_ENUM_VEHICLEROLE_INVALID
					or {_vehRole < _unitVehRole}
				) then {
					continue;
				};

				// Skip the role if it is occupied
				_occupiedBy = [_vehX, _vehRole, _turretPath, _cargoIndex] call FUNC(veh_getUnitByRole);
				if (alive _occupiedBy) then {
					continue;
				};

				// Skip the role if it cannot be reclaimed
				if (
					_time < _vehX getVariable [format [QGVAR(ai_unitControl_claimVehicle_nextUpdate_%1_%2_%3), _vehRole, _turretPath, _cargoIndex], 0]
					and {[_vehX getVariable [format [QGVAR(ai_unitControl_claimVehicle_unit_%1_%2_%3), _vehRole, _turretPath, _cargoIndex], objNull]] call FUNC(unit_isAlive)}
				) then {
					continue;
				};

				// Allow cargo seats when far from the goal position
				// Only allow this when the vehicle has an AI driver whose goal is close to the unit's goal
				if (_vehRole == MACRO_ENUM_VEHICLEROLE_CARGO) then {

					// Ensure the unit has a valid goal position
					if (_distToGoalSqr < _maxDistSqr) then {
						continue;
					};

					_driver        = driver _vehX;
					_driverGoalPos = _driver getVariable [QGVAR(ai_sys_unitControl_goalPos), []];

					if (
						isPlayer _driver
						or {_driverGoalPos isEqualTo []}
						or {_distToGoalSqr < _maxDistSqr} // Unit distance to its own goalPos
						or {_curGoalPos distanceSqr _driverGoalPos > _maxDistSqr} // Whether the driver's goal pos roughly matches the unit's goal pos
						or {getPosWorld _vehX distanceSqr _driverGoalPos < _maxDistSqr} // Vehicle distance to its own goalPos
					) then {
						continue;
					};
				};

				// Submit a request and exit
				[_unit, _vehX, _vehRole, _turretPath, _cargoIndex] remoteExecCall [QFUNC(ai_requestVehicleClaim), 2, false];

				breakTo QGVAR(subSys_claimVehicle);

			} forEach ([_vehX] call FUNC(veh_getRoles));

		} forEach _candidateVehicles;

		_unit setVariable [QGVAR(ai_unitControl_claimVehicle_nextUpdate), _time + MACRO_AI_CLAIMVEHICLE_INTERVAL, false];
	};





	// Check if any request came through (via ai_processVehicleClaim)
	private _claimedVeh         = _unit getVariable [QGVAR(ai_unitControl_claimVehicle_veh), objNull];
	private _claimedVehRoleData = _unit getVariable [QGVAR(ai_unitControl_claimVehicle_role), []];
	private _isClaimedVehValid  = (alive _claimedVeh);
	_claimedVehRoleData params [
		["_claimedVehRole", MACRO_ENUM_VEHICLEROLE_INVALID, [MACRO_ENUM_VEHICLEROLE_INVALID]],
		["_turretPath", [], [[]]],
		["_cargoIndex", -1, [-1]]
	];

	// Validate the vehicle claim
	if (_isClaimedVehValid) then {

		if (
			_claimedVehRole == MACRO_ENUM_VEHICLEROLE_INVALID
			or {!([_claimedVeh, _unit] call FUNC(veh_isClaimable))}
		) then {
			_isClaimedVehValid = false;
			breakTo QGVAR(subSys_claimVehicle);
		};

		private _occupiedBy = [_claimedVeh, _claimedVehRole, _turretPath, _cargoIndex] call FUNC(veh_getUnitByRole);
		if (alive _occupiedBy and {_unit != _occupiedBy}) then {
			_isClaimedVehValid = false;
		};
	};





	// Handle in-vehicle behaviour
	if (_isInVehicle) then {

		if (!isNull _claimedVeh) then {
			[_unit] remoteExecCall [QFUNC(ai_forfeitVehicleClaim), 0, false];
		};

		// If necessary, switch roles
		if (_unitVehRole != _claimedVehRole and {_claimedVehRole != MACRO_ENUM_VEHICLEROLE_INVALID}) then {
			//systemChat format ["Switching from %1 to %2", _unitVehRole, _claimedVehRole];

			moveOut _unit;
			switch (_claimedVehRole) do {
				case MACRO_ENUM_VEHICLEROLE_DRIVER:    {_unit moveInDriver _claimedVeh};
				case MACRO_ENUM_VEHICLEROLE_GUNNER:    {_unit moveInGunner _claimedVeh};
				case MACRO_ENUM_VEHICLEROLE_COMMANDER: {_unit moveInCommander _claimedVeh};
				case MACRO_ENUM_VEHICLEROLE_TURRET:    {_unit moveInTurret [_claimedVeh, _turretPath]};
				case MACRO_ENUM_VEHICLEROLE_CARGO:     {_unit moveInCargo [_claimedVeh, _cargoIndex]};
			};

			breakTo QGVAR(ai_sys_unitControl_loop_live);
		};

		if (_unitVehRole == MACRO_ENUM_VEHICLEROLE_CARGO) then {
			_driver        = driver _unitVeh;
			_driverGoalPos = _driver getVariable [QGVAR(ai_sys_unitControl_goalPos), []];

			if (
				vectorMagnitude velocity _unitVeh <= MACRO_AI_CLAIMVEHICLE_MAXSPEED_DISMOUNT
				and {
					isPlayer _driver
					or {_curGoalPos isEqualTo []}
					or {_driverGoalPos isEqualTo []}
					or {_distToGoalSqr < _maxDistSqr} // Unit distance to its own goalPos
					or {_curGoalPos distanceSqr _driverGoalPos > _maxDistSqr} // Whether the driver's goal pos roughly matches the unit's goal pos
					or {!([_unitVeh] call FUNC(veh_isOperable))} // The vehicle is no longer operable
				}
			) then {
				_unit action ["getOut", _unitVeh];
				[_unit] orderGetIn false;

				// Update the unit's state
				_unitVeh        = vehicle _unit;
				_isInVehicle    = (_unit != _unitVeh);
				_changedVehicle = (_isInVehicle != _unit getVariable [QGVAR(ai_sys_unitControl_isInVehicle), _isInVehicle]);
				_isDriver       = (_isInVehicle and {_unit == driver _unitVeh});

				//systemChat format ["%1 Dismounting from %2", _unit, _unitVeh];
			};
		};

	// Handle on-foot behaviour
	} else {

		if (_isClaimedVehValid) then {

			// Custom action: move to the claimed vehicle
			_actionPos = getPosWorld _claimedVeh;
			_actionPos = _actionPos vectorAdd [1 - random 2, 1 - random 2, 0]; // Randomness to help the unit get close enough

			// Mount up
			if (_unitPos distanceSqr _actionPos < MACRO_AI_CLAIMVEHICLE_MAXDIST_MOUNT ^ 2) then {
				//systemChat format ["Mounting up into %1 (%2)", _claimedVeh, _claimedVehRole];

				switch (_claimedVehRole) do {
					case MACRO_ENUM_VEHICLEROLE_DRIVER:    {_unit moveInDriver _claimedVeh};
					case MACRO_ENUM_VEHICLEROLE_GUNNER:    {_unit moveInGunner _claimedVeh};
					case MACRO_ENUM_VEHICLEROLE_COMMANDER: {_unit moveInCommander _claimedVeh};
					case MACRO_ENUM_VEHICLEROLE_TURRET:    {_unit moveInTurret [_claimedVeh, _turretPath]};
					case MACRO_ENUM_VEHICLEROLE_CARGO:     {_unit moveInCargo [_claimedVeh, _cargoIndex]};
/*
					case MACRO_ENUM_VEHICLEROLE_DRIVER:    {_unit action ["getInDriver", _claimedVeh]};
					case MACRO_ENUM_VEHICLEROLE_GUNNER:    {_unit action ["getInGunner", _claimedVeh]};
					case MACRO_ENUM_VEHICLEROLE_COMMANDER: {_unit action ["getInCommander", _claimedVeh]};
					case MACRO_ENUM_VEHICLEROLE_TURRET:    {_unit action ["getInTurret", _claimedVeh, _turretPath]};
					case MACRO_ENUM_VEHICLEROLE_CARGO:     {_unit action ["getInCargo", _claimedVeh, _cargoIndex]};
*/
				};

				// Update the unit's state
				_unitVeh        = vehicle _unit;
				_isInVehicle    = (_unit != _unitVeh);
				_changedVehicle = (_isInVehicle != _unit getVariable [QGVAR(ai_sys_unitControl_isInVehicle), _isInVehicle]);
				_isDriver       = (_isInVehicle and {_unit == driver _unitVeh});
			} else {

				// Allows switching to careless mode in order to move
				_switchToCareless = !_isInVehicle;
			};


		} else {
			// Invalidate the currently claimed vehicle
			if (!isNull _claimedVeh) then {
				[_unit] remoteExecCall [QFUNC(ai_forfeitVehicleClaim), 0, false];
				//systemChat format ["(%1) %2 claim expired: %3: %4", time, _unit, typeOf _claimedVeh, [_claimedVehRole, _turretPath, _cargoIndex]];
			};

			[_unit] orderGetIn false;
		};
	};
};
