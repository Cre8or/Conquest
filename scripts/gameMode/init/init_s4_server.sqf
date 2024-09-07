// Server component (stage 4)
diag_log "[CONQUEST] Server initialisation (stage 4) starting...";




// Initialise the sectors
private ["_sector", "_side", "_level"];
private ["_flag", "_spawnPoints", "_attackPoints", "_vehicleSpawns", "_vehicleTypes"];
private ["_spawnPoint", "_spawnData", "_typeData", "_vehSide", "_index", "_vehSpawn", "_sideX"];

{
	_sector = _x;
	_side   = _sector getVariable [QGVAR(sideInit), sideEmpty];
	_level  = [0, 1] select (_side != sideEmpty);
	_flag   = _sector getVariable [QGVAR(flagPole), objNull];

	// Initialise the sector (irreversibly modifies the mission state, so we can only do it once)
	if !(_sector getVariable [QGVAR(isInitialised), false]) then {

		_spawnPoints   = [];
		_attackPoints  = [];
		_vehicleSpawns = [];
		_vehicleTypes  = [];

		// Iterate through the sector's synchronised objects
		{
			switch (typeOf _x) do {

				// If it's a flag, link it
				case MACRO_CLASS_FLAG: {
					_flag = _x;
				};

				// If it's a unit spawnpoint, add it to the list
				case MACRO_CLASS_SPAWNPOINT_UNIT: {
					_spawnPoints pushBack _x;
					_x hideObjectGlobal true;
				};

				// If it's an attack point, add its position to the list
				case MACRO_CLASS_ATTACKPOINT: {
					_attackPoints pushBack (getPosWorld _x);
					deleteVehicle _x;
				};

				// If it's a vehicle spawnpoint, setup its spawn data
				case MACRO_CLASS_SPAWNPOINT_VEHICLE: {
					_spawnPoint = _x;
					_spawnData  = [];
					_typeData   = [];

					// Iterate through its synchronised objects
					{
						if (_x isKindOf "AllVehicles") then {
							_vehSide = _x getVariable [QGVAR(side), sideEmpty];
							_index   = GVAR(sides) find _vehSide;

							// If the side is valid, add an entry for this vehicle to the spawn data
							if (_index >= 0) then {
								_vehSpawn = [
									typeOf _x,                                                            // 0
									getPosWorld _x,                                                       // 1
									vectorDir _x,                                                         // 2
									vectorUp _x,                                                          // 3
									_x getVariable [QGVAR(respawnDelay), -1],                             // 4
									_x getVariable [QGVAR(playersOnly), false],                           // 5
									_x getVariable [QGVAR(forbiddenWeapons), []],                         // 6
									_x getVariable [QGVAR(forbiddenMagazines), []],                       // 7
									(_x getVariable [QGVAR(invincibleHitPoints), []]) apply {toLower _x}, // 8
									0.6 * (2 boundingBoxReal _x) # 2,                                     // 9 (bounding sphere radius)
									-1                                                                    // 10 (next respawn time)
								];

								// Add this vehicle spawn to the spawnpoint's data
								_spawnData set [_index, _vehSpawn];
								_typeData set [_index, typeOf _x];

								// Delete the vehicle once we're done
								deleteVehicle _x;
							};
						};
					} forEach synchronizedObjects _spawnPoint;

					if (_spawnData isNotEqualTo []) then {
						_vehicleSpawns pushBack _spawnData;
						_vehicleTypes pushBack _typeData;
					};

					deleteVehicle _spawnPoint;
				};
			};
		} forEach synchronizedObjects _sector;

		// Save the sector's shared variables
		_sector setVariable [QGVAR(flagPole), _flag, !isNull _flag];
		_sector setVariable [QGVAR(vehicleTypes), _vehicleTypes, _vehicleTypes isNotEqualTo []];
		_sector setVariable [QGVAR(attackPoints), _attackPoints, _attackPoints isNotEqualTo []];

		{
			_sideX = _x;

			if (_sideX != sideEmpty) then {
				_sector setVariable [
					format [QGVAR(spawnPoints_%1), _sideX],
					_spawnPoints select {[position _x, _sideX] call FUNC(ca_isInCombatArea)},
					true
				];
			};
		} forEach GVAR(sides);

		// Save the sector's server variables
		_sector setVariable [QGVAR(vehicleSpawns), _vehicleSpawns, false];
		_sector setVariable [QGVAR(isInitialised), true, false];

	} else {

		// Sector is already initialised; reset the vehicle spawn times
		_vehicleSpawns = _sector getVariable [QGVAR(vehicleSpawns), []];

		{
			_spawnData = _x;

			{
				_vehSpawn = _spawnData param [_forEachIndex, []];

				if (_vehSpawn isEqualTo []) then {
					continue;
				};

				_vehSpawn set [10, -1]; // Respawn time
			} forEach GVAR(sides);

		} forEach _vehicleSpawns;
	};

	// Set up the flag
	_flag setFlagAnimationPhase _level;
	_flag setFlagTexture ([_side] call FUNC(gm_getFlagTexture));

	// Save the sector's shared variables
	_sector setVariable [QGVAR(side), _side, true];
	_sector setVariable [QGVAR(sideCapturing), _side, true];
	_sector setVariable [QGVAR(level), _level, true];

	// Save the sector's server variables
	_sector setVariable [QGVAR(sideFlagLast), _side, true];
	_sector setVariable [QGVAR(lastUpdateTime), nil, false];
	_sector setVariable [QGVAR(levelLast), _level, false];
	_sector setVariable [QGVAR(levelNextScore), [MACRO_SECTOR_SCOREINTERVAL, 1 - MACRO_SECTOR_SCOREINTERVAL] select (_level > 0), false];

} forEach GVAR(allSectors);





// Prepare the AI identities
call FUNC(ai_generateIdentities);

// Start the server systems
call FUNC(ai_sys_handleRespawn);





diag_log "[CONQUEST] Server initialisation (stage 4) done.";
