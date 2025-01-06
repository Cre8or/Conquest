// Server component (stage 2)
diag_log "[CONQUEST] Server initialisation (stage 2) starting...";





// Define shared global variables
MACRO_FNC_INITVAR(GVAR(sides), []);
MACRO_FNC_INITVAR(GVAR(allSectors), []);
MACRO_FNC_INITVAR(GVAR(curatorModule), objNull);

GVAR(missionState) = MACRO_ENUM_MISSION_INIT;
GVAR(safeStart)    = false;
GVAR(ticketsEast)       = 0;
GVAR(ticketsResistance) = 0;
GVAR(ticketsWest)       = 0;

// Define global server variables
GVAR(AIUnits)  = [];
GVAR(sv_stats) = createHashMap;

MACRO_FNC_INITVAR(GVAR(sv_firstInit), true);

// NOTE: The index positions used in this array are fixed, and must always remain the same!
// This simplifies the lookup and handling of side-related data.
// If only two sides are to be used, the vacant entry remains as sideEmpty.
private _allSides = [east, resistance, west];

private _firstInit = GVAR(sv_firstInit);
GVAR(sv_firstInit) = false;

#ifdef MACRO_MISSION_USES_INDFOR
	private _sv_usesIndfor = true;
#else
	private _sv_usesIndfor = false;
#endif





if (_firstInit) then {

	private _str_sectorCondition = str {[thisTrigger, thisList] call FUNC(sector_handleServer); true}; // Must return true for the statements to run
	private _triggerStatements   = [_str_sectorCondition select [1, (count _str_sectorCondition) - 2], "", ""];

	private _isValid_east       = false;
	private _isValid_resistance = false;
	private _isValid_west       = false;
	private ["_sector", "_side", "_isLocked", "_strategicValue"];

	// Look for valid sectors
	{
		_sector = missionNamespace getVariable [format ["sector_%1", _x], objNull];

		// If the sector variable exists...
		if (!isNull _sector) then {

			// Add it to the list of sectors
			GVAR(allSectors) pushBack _sector;

			_side           = sideEmpty;
			_isLocked       = false;
			_strategicValue = 1;

			// Parse the sector's activation data
			switch (triggerActivation _sector # 0) do {
				case "EAST":        {_side = east;       _isLocked = true};
				case "GUER":        {_side = resistance; _isLocked = true};
				case "WEST":        {_side = west;       _isLocked = true};

				case "EAST SEIZED": {_side = east};
				case "GUER SEIZED": {_side = resistance};
				case "WEST SEIZED": {_side = west};
			};

			// Revert to the empty side if the mission doesn't support INDFOR
			if (_side == resistance and {!_sv_usesIndfor}) then {
				_side     = sideEmpty;
				_isLocked = false;
			};

			// If the sector is not locked, determine its strategic value (set via trigger condition)
			if (!_isLocked) then {
				call compile ((triggerStatements _sector) # 0);
			};

			// Save the sector's shared variables
			_sector setVariable [QGVAR(letter), _x, true];
			_sector setVariable [QGVAR(name), triggerText _sector, true];
			_sector setVariable [QGVAR(isLocked), _isLocked, true];
			_sector setVariable [QGVAR(strategicValue), _strategicValue max 0.000001, true];

			// Save the sector's server variables
			_sector setVariable [QGVAR(sideInit), _side, false];

			// Flag the corresponding side as valid
			switch (_side) do {
				case east:       {_isValid_east       = true};
				case resistance: {_isValid_resistance = true};
				case west:       {_isValid_west       = true};
			};

			// Set up the sector's trigger parameters
			_sector setTriggerType "NONE";
			_sector setTriggerActivation ["ANY", "PRESENT", true];
			_sector setTriggerStatements _triggerStatements;
			_sector setTriggerInterval MACRO_SECTOR_TRIGGERINTERVAL;
		};
	} forEach ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"];

	// Validate the sides
	GVAR(sides) = +_allSides;
	if (!_isValid_east) then {
		GVAR(sides) set [0, sideEmpty];
	};
	if (!_isValid_resistance) then {
		GVAR(sides) set [1, sideEmpty];
	};
	if (!_isValid_west) then {
		GVAR(sides) set [2, sideEmpty];
	};

	// Find the curator module
	GVAR(curatorModule) = allCurators param [0, objNull];
};

// Reset the starting tickets
{
	switch (_x) do {
		case east:       {GVAR(ticketsEast)       = GVAR(param_gm_startingTickets)};
		case resistance: {GVAR(ticketsResistance) = GVAR(param_gm_startingTickets)};
		case west:       {GVAR(ticketsWest)       = GVAR(param_gm_startingTickets)};
	};
} forEach GVAR(sides);





// DEBUG - Remove all AI units
private ["_veh"];
{
	if (_x isKindOf "CAManBase") then {
		if (_x getVariable [QGVAR(canCaptureSectors), false]) then {
			deleteVehicle _x;
		};
	} else {
		_veh = _x;
		deleteVehicleCrew _veh;
		deleteVehicle _veh;
	};
} forEach (allUnits + allDead + allDeadMen);

// DEBUG - Remove all conquest vehicles
{
	if (sideEmpty != _x getVariable [QGVAR(side), sideEmpty]) then {
		_veh = _x;
		deleteVehicleCrew _veh;
		deleteVehicle _veh;
	};
} forEach vehicles;

// DEBUG - Remove all groups
{
	deleteGroup _x;
	_x setVariable [QGVAR(isValid), false, true];
	_x setGroupId [format ["DEBUG_OLD_GRP_%1", _forEachIndex]];
} forEach allGroups;

// DEBUG - Remove all mines
{
	deleteVehicle _x;
} forEach allMines;





// Initialise the detected sectors
private _time = time;
private ["_sector", "_side", "_level", "_flag", "_attackPointsInf", "_attackPointsVeh", "_spawnPointsInf", "_spawnPointsVeh", "_sideX", "_initialSpawnDelay"];
if (_firstInit) then {
	{
		_sector = _x;
		_side   = _sector getVariable [QGVAR(sideInit), sideEmpty];
		_level  = [0, 1] select (_side != sideEmpty);
		_flag   = _sector getVariable [QGVAR(flagPole), objNull];

		_attackPointsInf = [];
		_attackPointsVeh = [];
		_spawnPointsInf  = [];
		_spawnPointsVeh  = [];

		// Iterate through the sector's synchronised objects
		{
			switch (typeOf _x) do {

				case MACRO_CLASS_FLAG: {
					_flag = _x;
					_flag setFlagTexture ([_side] call FUNC(gm_getFlagTexture));
				};

				case MACRO_CLASS_ATTACKPOINT_INF: {
					_attackPointsInf pushBack (getPosWorld _x);
					_x hideObjectGlobal true;
				};

				case MACRO_CLASS_ATTACKPOINT_VEH: {
					_attackPointsVeh pushBack (getPosWorld _x);
					_x hideObjectGlobal true;
				};

				case MACRO_CLASS_SPAWNPOINT_INF: {
					_spawnPointsInf pushBack _x;
					_x hideObjectGlobal true;
				};

				case MACRO_CLASS_SPAWNPOINT_VEH: {
					_spawnPointsVeh pushBack _x; // [_allSides find _side, _x]; // [index, spawnPoint]
					_x hideObjectGlobal true;
				};
			};
		} forEach synchronizedObjects _sector;

		// Shared data
		_sector setVariable [QGVAR(flagPole), _flag, !isNull _flag];
		_sector setVariable [QGVAR(attackPointsInf), _attackPointsInf, _attackPointsInf isNotEqualTo []];
		_sector setVariable [QGVAR(attackPointsVeh), _attackPointsVeh, _attackPointsVeh isNotEqualTo []];
		_sector setVariable [QGVAR(side), _side, true];
		_sector setVariable [QGVAR(sideCapturing), _side, true];
		_sector setVariable [QGVAR(level), _level, true];

		// Server data
		_sector setVariable [QGVAR(sideFlagLast), sideEmpty, true];
		_sector setVariable [QGVAR(lastUpdateTime), nil, false];
		_sector setVariable [QGVAR(levelLast), _level, false];
		_sector setVariable [QGVAR(levelNextScore), [MACRO_SECTOR_SCOREINTERVAL, 1 - MACRO_SECTOR_SCOREINTERVAL] select (_level > 0), false];

		{
			_sideX = _x;
			if (_sideX == sideEmpty) then {continue};

			_sector setVariable [
				format [QGVAR(spawnPoints_%1), _sideX],
				_spawnPointsInf select {[position _x, _sideX] call FUNC(ca_isInCombatArea)},
				true
			];
		} forEach GVAR(sides);

		// Server data
		_sector setVariable [QGVAR(sv_spawnPointsVeh), _spawnPointsVeh, false];
	} forEach GVAR(allSectors);

	// Separately initialise the vehicle definitions on each sector.
	// This can't be folded into the previous loop, as the spawnpoints must be sorted by captured, then
	// then uncapted sectors. As such the order of the sectors is different for each side.
	private ["_sectorsOwned", "_sectorsNeutral", "_sectorsHostile", "_spawnDataVeh", "_spawnPoint", "_enums", "_definition", "_veh", "_radius", "_respawnTime"];
	{
		_side = _x;
		if (_side == sideEmpty) then {continue};

		_sectorsOwned   = [];
		_sectorsNeutral = [];
		_sectorsHostile = [];
		{
			switch (_x getVariable [QGVAR(sideInit), sideEmpty]) do {
				case _side:     {_sectorsOwned pushBack _x};
				case sideEmpty: {_sectorsNeutral pushBack _x};
				default         {_sectorsHostile pushBack _x};
			};
		} forEach GVAR(allSectors);

		// Process sectors in order
		{
			_sector       = _x;
			_spawnDataVeh = [];

			{
				_spawnPoint = _x;
				_enums      = (_spawnPoint getVariable [QGVAR(enums), []]) apply {toUpper _x};

				_enums findIf {
					_definition = [_side, _x] call FUNC(veh_getNextDefinition);
					(_definition isNotEqualTo []); // Stop at the first valid result
				};

				if (_definition isEqualTo []) then {continue};

				// Figure out the size of the concerned vehicle
				_veh = (_definition # 0) createVehicleLocal [0, 0, 0];
				_veh enableSimulation false;
				_radius = MACRO_FNC_BOUNDINGRADIUS(_veh);
				deleteVehicle _veh;

				// Determine the initial respawn time
				_initialSpawnDelay = _spawnPoint getVariable [QGVAR(initialSpawnDelay), -1];
				if (_initialSpawnDelay > 0) then {
					_respawnTime = _time + GVAR(param_gm_safeStartDuration) + _initialSpawnDelay;
				} else {
					_respawnTime = -1;
				};

				_definition insert [1, [
					_respawnTime,                                        // 1
					getPosWorld _spawnPoint,                             // 2
					vectorDir _spawnPoint,                               // 3
					vectorUp _spawnPoint,                                // 4
					_spawnPoint getVariable [QGVAR(respawnDelay), -1],   // 5
					_spawnPoint getVariable [QGVAR(playersOnly), false], // 6
					_initialSpawnDelay,                                  // 7
					_radius                                              // 8
				]];

				_spawnDataVeh pushBack _definition;
				//diag_log format ["[CONQUEST] (%1) Storing definition for %2 (%3): %4", _sector getVariable [QGVAR(letter), "???"], _side, _enums, _definition];

			} forEach (_sector getVariable [QGVAR(sv_spawnPointsVeh), []]);

			// Client data
			_sector setVariable [format [QGVAR(cl_spawnDataVeh_%1), _side], _spawnDataVeh apply {_x # 0}, false];

			// Server data
			_sector setVariable [format [QGVAR(sv_spawnDataVeh_%1), _side], _spawnDataVeh, false];

		} forEach (_sectorsOwned + _sectorsNeutral + _sectorsHostile);

	} forEach GVAR(sides);

} else {

	// Reset the sector data
	{
		_sector = _x;
		_side   = _sector getVariable [QGVAR(sideInit), sideEmpty];
		_level  = [0, 1] select (_side != sideEmpty);
		_flag   = _sector getVariable [QGVAR(flagPole), objNull];

		// Rehicle respawn times
		{
			if (_x == sideEmpty) then {continue};
			{
				_initialSpawnDelay = _x # 7;

				if (_initialSpawnDelay < 0) then {
					_x set [1, -1]; // Respawn time
				} else {
					_x set [1, _time + GVAR(param_gm_safeStartDuration) + _initialSpawnDelay];
				};
			} forEach (_sector getVariable [format [QGVAR(sv_spawnDataVeh_%1), _x], []]);
		} forEach GVAR(sides);

		// Set up the flag
		_flag setFlagAnimationPhase _level;
		_flag setFlagTexture ([_side] call FUNC(gm_getFlagTexture));

		// Shared data
		_sector setVariable [QGVAR(side), _side, true];
		_sector setVariable [QGVAR(sideCapturing), _side, true];
		_sector setVariable [QGVAR(level), _level, true];

		// Server data
		_sector setVariable [QGVAR(sideFlagLast), sideEmpty, true];
		_sector setVariable [QGVAR(lastUpdateTime), nil, false];
		_sector setVariable [QGVAR(levelLast), _level, false];
		_sector setVariable [QGVAR(levelNextScore), [MACRO_SECTOR_SCOREINTERVAL, 1 - MACRO_SECTOR_SCOREINTERVAL] select (_level > 0), false];
	} forEach GVAR(allSectors);
};





// Set up the respawn objects
private "_obj";
{
	deleteVehicle (missionNamespace getVariable [_x, objNull]);

	_obj = "Sign_Arrow_Direction_Cyan_F" createVehicle [0,0,0];
	_obj setPosASL [_forEachIndex * 200, 0, 10];
	missionNamespace setVariable [_x, _obj, false];
} forEach [
	QGVAR(respawn_east),
	QGVAR(respawn_resistance),
	QGVAR(respawn_west)
];

// Remove all other player units in singleplayer
if (!isMultiplayer) then {
	{
		deleteVehicle _x;
	} forEach switchableUnits;
};





// Broadcast shared global variables
publicVariable QGVAR(sides);
publicVariable QGVAR(allSectors);
publicVariable QGVAR(curatorModule);

publicVariable QGVAR(missionState);
publicVariable QGVAR(safeStart);
publicVariable QGVAR(ticketsEast);
publicVariable QGVAR(ticketsResistance);
publicVariable QGVAR(ticketsWest);

publicVariable QGVAR(respawn_east);
publicVariable QGVAR(respawn_resistance);
publicVariable QGVAR(respawn_west);





// Prepare the AI identities
call FUNC(ai_generateIdentities);

// Start the systems
call FUNC(ai_sys_handleRespawn);

call FUNC(acre_sys_assignChannels);

call FUNC(gm_sys_endConditions);
call FUNC(gm_sys_handleCurator);
call FUNC(gm_sys_handleEntityDeaths);
call FUNC(gm_sys_handleServerStats);
call FUNC(gm_sys_removeCorpses);
call FUNC(gm_sys_tickets);

// Start the safestart handler
if (!isNil QGVAR(handle_safeStart)) then {terminate GVAR(handle_safeStart)};
GVAR(handle_safeStart) = [] spawn FUNC(handleSafeStart);





diag_log "[CONQUEST] Server initialisation (stage 2) done.";
