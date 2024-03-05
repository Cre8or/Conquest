#include "..\..\res\common\macros.inc"





// Loop
while {true} do {

	private _time = time;
	private _group = grpNull;

	// Wait until the mission has started
	if (GVAR(missionState) == MACRO_ENUM_MISSION_LIVE) then {

		private ["_side", "_sectorsToCapture", "_posLeader", "_sector", "_attackPoints", "_commanderWP", "_waypoints"];

		// Loop through all AI groups
		{
			// Escape scheduled environment
			isNil {
				// Only continue if the group is not null
				if (!isNull _x) then {
					_group = _x;
					_group setBehaviour "AWARE";

					// Pick a random sector that hasn't been captured yet
					_side = side _group;
					_sectorsToCapture = GVAR(allSectors) select {
						!(_x getVariable [QGVAR(isLocked), false])				// Sector must not be locked
						and {
							_side != _x getVariable [QGVAR(side), sideEmpty]		// Include sectors not owned by the group's side
							or {(_x getVariable [QGVAR(level), 0]) < 0.8}		// Include sectors with a cap level of under 80% (e.g. owned flags being attacked by the enemy)
						}
					};

					// If there are any such sectors...
					if !(_sectorsToCapture isEqualTo []) then {

						// Find the closest uncaptured sector to the leader
						_posLeader = getPosATL leader _group;
						_sectorsToCapture = _sectorsToCapture apply {
							[
								(_posLeader distance getPosATL _x) / (_x getVariable [QGVAR(strategicValue), 1]),
								_x
							]
						};
						_sectorsToCapture sort true;
						_sector = _sectorsToCapture # 0 # 1;

						// Check if the group is already attacking this sector
						if (_sector != _group getVariable [QGVAR(commanderSector), objNull]) then {

							// Fetch the sector's attack points
							_attackPoints = _sector getVariable [QGVAR(attackPoints), []];
							_commanderWP = selectRandom _attackPoints;
							if (_attackPoints isEqualTo []) then {
								_commanderWP = getPosWorld _sector;
							};

							// Remove all existing waypoints from the group
							_waypoints = waypoints _group;
							for "_i" from 1 to (count _waypoints) - 1 do {
								deleteWaypoint [_group, _i];
							};;

							// Assign a new waypoint to the group
							_group addWaypoint [_commanderWP, -1, 1];

							// Save the destination onto the group
							//_x setVariable [QGVAR(commanderWP), _commanderWP, false];
							_x setVariable [QGVAR(commanderSector), _sector, false];

							//systemChat format ["(%1) - Commanded to %2 (%3m - %4)", _x, _sector getVariable [QGVAR(letter), "???"], round ((leader _x) distance _commanderWP), _commanderWP];
						};
					};
				};
			};

			sleep 0.05;
		} forEach (GVAR(AIInfGroups_east) + GVAR(AIInfGroups_resistance) + GVAR(AIInfGroups_west));
	};

	sleep 0.5;
};
