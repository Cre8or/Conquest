// Server component (stage 2)
diag_log "[CONQUEST] Server initialisation (stage 2) starting...";





// Define shared global variables
MACRO_FNC_INITVAR(GVAR(sides), []);
MACRO_FNC_INITVAR(GVAR(allSectors), []);
MACRO_FNC_INITVAR(GVAR(curatorModule), objNull);
GVAR(allVehicles) = [];

GVAR(missionState) = MACRO_ENUM_MISSION_INIT;
GVAR(safeStart)    = false;
GVAR(ticketsEast)       = 0;
GVAR(ticketsResistance) = 0;
GVAR(ticketsWest)       = 0;

// Define global server variables
GVAR(AIUnits) = [];

MACRO_FNC_INITVAR(GVAR(firstInit),true);





if (GVAR(firstInit)) then {
	GVAR(firstInit) = false;

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

	// NOTE: The index positions used in this array are fixed, and must always remain the same!
	// This simplifies the lookup and handling of side-related data.
	// If only two sides are to be used, the vacant entry remains as sideEmpty.
	GVAR(sides) = [east, resistance, west];

	// Validate the sides
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
publicVariable QGVAR(allVehicles);
publicVariable QGVAR(curatorModule);

publicVariable QGVAR(missionState);
publicVariable QGVAR(safeStart);
publicVariable QGVAR(ticketsEast);
publicVariable QGVAR(ticketsResistance);
publicVariable QGVAR(ticketsWest);

publicVariable QGVAR(respawn_east);
publicVariable QGVAR(respawn_resistance);
publicVariable QGVAR(respawn_west);





// Start the systems
call FUNC(gm_sys_tickets);
call FUNC(gm_sys_removeCorpses);

call FUNC(gm_sys_endConditions);
call FUNC(gm_sys_handleCurator);

call FUNC(gm_handleEntityDeaths);

// Start the safestart handler
if (!isNil QGVAR(handle_safeStart)) then {terminate GVAR(handle_safeStart)};
GVAR(handle_safeStart) = [] spawn FUNC(handleSafeStart);





diag_log "[CONQUEST] Server initialisation (stage 2) done.";
