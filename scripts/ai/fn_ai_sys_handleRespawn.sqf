/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles the (re)spawning of all AI units. Requires the AI identities to be generated in order to work.

		Only executed once by the server upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"

#include "..\..\res\macros\fnc_initVar.inc"

if (!isServer) exitWith {};





// Define some macros
#define MACRO_SYS_UNITSPAWNINTERVAL 0.1 // The interval, in seconds, between two consecutive unit spawns (to prevent lag)

// Set up some variables
MACRO_FNC_INITVAR(GVAR(EH_ai_sys_handleRespawn), -1);

MACRO_FNC_INITVAR(GVAR(ai_sys_handleRespawn_groups_east), []);
MACRO_FNC_INITVAR(GVAR(ai_sys_handleRespawn_groups_resistance), []);
MACRO_FNC_INITVAR(GVAR(ai_sys_handleRespawn_groups_west), []);

GVAR(ai_sys_handleRespawn_nextUpdate)        = -1;
GVAR(ai_sys_handleRespawn_newSpawns)         = [];
GVAR(ai_sys_handleRespawn_queue)             = [];
GVAR(ai_sys_handleRespawn_respawnTimes)      = []; // Interfaces with unit_onKilled





removeMissionEventHandler ["EachFrame", GVAR(EH_ai_sys_handleRespawn)];
GVAR(EH_ai_sys_handleRespawn) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	private _time = time;

	// Check if we may spawn an AI in this frame
	if (GVAR(missionState) <= MACRO_ENUM_MISSION_LIVE and {_time > GVAR(ai_sys_handleRespawn_nextUpdate)}) then {

		private ["_unit", "_identity"];
		private ["_side", "_sideIndex"];
		private ["_unitIndex", "_unitSide", "_sideGroups", "_group", "_groupID", "_sector", "_spawnableSectors", "_leader", "_leaderIsPlayer", "_claimableVehicles", "_sectorX", "_groupWP", "_spawnableSectors_sorted", "_leaderPos", "_spawnPoint", "_unitClass"];

		// Check up on the recently spawned units that don't have an identity yet
		for "_i" from count GVAR(ai_sys_handleRespawn_newSpawns) - 1 to 0 step -1 do {
			_unit = GVAR(ai_sys_handleRespawn_newSpawns) # _i;

			// Once the game assigned the default identity to this unit, we may override it
			if (name _unit != "") then {
				_identity = GVAR(sv_AIIdentities) param [_unit getVariable [QGVAR(unitIndex), -1], []];

				// Apply the AI identity to the unit (and broadcast the change over the network)
				if !(_identity isEqualTo []) then {
					[
						_unit,
						_identity param [MACRO_ENUM_AIIDENTITY_NAME, ""],
						_identity param [MACRO_ENUM_AIIDENTITY_FACE, ""],
						_identity param [MACRO_ENUM_AIIDENTITY_SPEAKER, ""]
					] remoteExecCall [QFUNC(unit_setIdentityLocal), 0, format [QGVAR(ai_identity_%1), _i]];
				};

				// Remove this unit from the list
				GVAR(ai_sys_handleRespawn_newSpawns) deleteAt _i;
			};
		};



		if (GVAR(ai_sys_handleRespawn_queue) isEqualTo []) then {

			private _AICounts     = [];
			private _playerCounts = [];

			// Determine the AI and player counts on each side
			{
				_side = _x;

				_AICounts pushBack (
					({_x # MACRO_ENUM_AIIDENTITY_SIDEINDEX == _forEachIndex} count GVAR(sv_AIIdentities)) + (_AICounts param [_forEachIndex - 1, 0])
				);
				_playerCounts pushBack (
					{_x getVariable [QGVAR(side), sideEmpty] == _side} count allPlayers
				);
			} forEach GVAR(sides);
			systemChat str _AICounts;

			for "_i" from 0 to GVAR(param_AI_maxCount) - 1 do {
				_unit = GVAR(AIUnits) param [_i, objNull];

				// If this unit isn't spawned, check why
				if (!alive _unit and {_time > GVAR(ai_sys_handleRespawn_respawnTimes) param [_i, -1]}) then {
					_identity  = GVAR(sv_AIIdentities) param [_i, [sideEmpty]];
					_sideIndex = _identity # MACRO_ENUM_AIIDENTITY_SIDEINDEX;

					if ([_sideIndex] call FUNC(gm_isSidePlayable)) then {

						if (GVAR(param_AI_includePlayers)) then {
							// Only add the unit to the queue if no players are blocking it, and if its side is still playable
							if (_i < _AICounts # _sideIndex - _playerCounts # _sideIndex) then {
								GVAR(ai_sys_handleRespawn_queue) pushBack _i;
							};
						} else {
							GVAR(ai_sys_handleRespawn_queue) pushBack _i;
						};
					};
				};
			};
		};

		// Fetch the next unit from the queue
		_unitIndex = floor random count GVAR(ai_sys_handleRespawn_queue);
		_unitIndex = GVAR(ai_sys_handleRespawn_queue) deleteAt _unitIndex; // If the queue is empty, _unitIndex will be nil
		if (!isNil "_unitIndex") then {

			_identity = GVAR(sv_AIIdentities) param [_unitIndex, []];
			_identity params [
				"",                       // MACRO_ENUM_AIIDENTITY_UNITINDEX (not used here)
				["_sideIndex", 0],        // MACRO_ENUM_AIIDENTITY_SIDEINDEX
				["_unitGroupIndex", 0],   // MACRO_ENUM_AIIDENTITY_GROUPINDEX
				["_unitIsLeader", false], // MACRO_ENUM_AIIDENTITY_ISLEADER
				["_unitRole", -1]         // MACRO_ENUM_AIIDENTITY_ROLE
			];
			_unitSide = GVAR(sides) # _sideIndex;

			// Fetch the group from the list
			_sideGroups = switch (_unitSide) do {
				case east:		{GVAR(ai_sys_handleRespawn_groups_east)};
				case resistance:	{GVAR(ai_sys_handleRespawn_groups_resistance)};
				case west:		{GVAR(ai_sys_handleRespawn_groups_west)};
				default			{[]};
			};
			_group = _sideGroups param [_unitGroupIndex, grpNull];

			// If the group is null, create it
			if !(_group getVariable [QGVAR(isValid), false]) then {
				deleteGroup _group;

				_group = createGroup _unitSide;
				_group deleteGroupWhenEmpty false;
				_group setVariable [QGVAR(isValid), true, true];

				// Set the group's callsign (based on the index)
				_groupID = MACRO_AI_GROUP_CALLSIGNS param [_unitGroupIndex, ""];
				_group setGroupIdGlobal [_groupID];

				// Error checking
				if (groupId _group != _groupID) then {
					diag_log format ["[CONQUEST] ERROR: AI Group ID %1 (%2) is already taken!", _groupID, _unitSide];
					_group setGroupIdGlobal [format ["ERR_GROUPID_%1_TAKEN___(%2)", _unitGroupIndex, diag_frameNo]];
				};

				// Save the AI identity IDs that will be present in this group
				_group setVariable [QGVAR(group_AIIdentities),
					GVAR(sv_AIIdentities) select {_x # 1 == _sideIndex and {_x # 2 == _unitGroupIndex}} apply {_x # 0}
				, true];

				// Broadcast the group variable (for global fetching)
				missionNamespace setVariable [format [QGVAR(AIGroup_%1_%2), _unitSide, _unitGroupIndex], _group, true];

				_sideGroups set [_unitGroupIndex, _group];
			};

			// Fetch all spawnable sectors that this side owns
			_spawnableSectors = GVAR(allSectors) select {
				_unitSide == _x getVariable [QGVAR(side), sideEmpty]
				and {(_x getVariable [format [QGVAR(spawnPoints_%1), _unitSide], []]) isNotEqualTo []}
			};
			_leader         = leader _group;
			_leaderIsPlayer = isPlayer _leader;
			_sector         = objNull;

			// If the group leader is alive...
			if (alive _leader and {!_unitIsLeader}) then {

				// If the leader isn't a player, the unit may roll to respawn on a sector that has a claimable vehicle
				if (!_leaderIsPlayer and {GVAR(param_AI_allowVehicles)} and {random 1 <= MACRO_AI_CHANCE_RESPAWN_CLAIMVEHICLE}) then {

					_claimableVehicles = GVAR(allVehicles) select {
						!alive driver _x
						and {!(_x getVariable [QGVAR(playersOnly), false])}
						and {_x getVariable [QGVAR(side), sideEmpty] == _unitSide}
						and {canMove _x}
						and {fuel _x > 0}
					};

					// Pick a (random) sector that has a claimable vehicle within distance of it
					_sector = selectRandom (_spawnableSectors select {
						_sectorX = _x;

						(_claimableVehicles findIf {
							_x distanceSqr _sectorX < MACRO_AI_MAXDIST_RESPAWN_CLAIMABLE ^ 2
						}) >= 0;
					});

					// Validate the sector
					if (isNil "_sector") then {
						_sector = objNull;
/*					// DEBUG
					} else {
						systemChat format ["Respawning %1 %2 on %3 (might claim a vehicle)", _unitSide, _identity # MACRO_ENUM_AIIDENTITY_NAME, _sector getVariable [QGVAR(letter), "???"]];
*/
					};
				};

				// If it failed to claim a vehicle, respawn near the leader
				if (isNull _sector) then {
					_leaderPos = getPosATL _leader;

					_spawnableSectors_sorted = _spawnableSectors apply {[_x distanceSqr _leaderPos, _x]};
					_spawnableSectors_sorted sort true;

					_sector = (_spawnableSectors_sorted param [0, []]) param [1, objNull];
				};

			// Otherwise, try to spawn near the group's waypoint
			} else {
				_groupWP = waypoints _group param [currentWaypoint _group, []];

				// If the group doesn't have a waypoint, pick a random sector
				if (_groupWP isEqualTo []) then {
					_sector = selectRandom _spawnableSectors;

				// Otherwise, pick the closest sector to the waypoint
				} else {
					_groupWP = waypointPosition _groupWP;
					_spawnableSectors_sorted = _spawnableSectors apply {[_x distanceSqr _groupWP, _x]};
					_spawnableSectors_sorted sort true;

					_sector = (_spawnableSectors_sorted param [0, []]) param [1, objNull];
				};
			};

			// If this sector is valid, spawn on it
			_spawnPoint = selectRandom (_sector getVariable [format [QGVAR(spawnPoints_%1), _unitSide], []]);
			if (!isNil "_spawnPoint") then {

				// Determine the unit class (affects the spotting callouts used by AI)
				_unitClass = format ["%1_%2",
					switch (_unitSide) do {
						case east:		{"O"};
						case resistance:	{"I"};
						case west:		{"B"};
						default			{"UNKNOWN_SIDE"};
					},
					switch (_unitRole) do {
						case MACRO_ENUM_ROLE_SPECOPS:		{"spotter_F"};
						case MACRO_ENUM_ROLE_SNIPER:		{"sniper_F"};
						case MACRO_ENUM_ROLE_ASSAULT:		{"Soldier_GL_F"};
						case MACRO_ENUM_ROLE_SUPPORT:		{"Soldier_AR_F"};
						case MACRO_ENUM_ROLE_ENGINEER:		{"engineer_F"};
						case MACRO_ENUM_ROLE_MEDIC:		{"medic_F"};
						case MACRO_ENUM_ROLE_ANTITANK:		{"Soldier_LAT_F"};
						default					{"UNKNOWN_ROLE"};
					}
				];

				_unit = _group createUnit [_unitClass, [0,0,0], [], 0, "CAN_COLLIDE"];
				GVAR(AIUnits) set [_unitIndex, _unit];
				_unit setPosWorld getPosWorld _spawnPoint;
				_unit setDir getDir _spawnPoint;

				// Add the unit to the list of newly spawned units, so that it may receive an identity
				GVAR(ai_sys_handleRespawn_newSpawns) pushBack _unit;

				// If the unit is normally a squad leader, make him take control over the group (unless the leader is a player)
				if (_unitIsLeader and {!_leaderIsPlayer}) then {
					[_group, _unit] remoteExecCall ["selectLeader", _group, false];
				};

				// Apply the role loadout to the unit
				[_unit, _unitSide, _unitRole] remoteExecCall [QFUNC(lo_setRoleLoadout), _unit, false];

				GVAR(curatorModule) addCuratorEditableObjects [[_unit], false];

				// Save the unit's shared variables
				_unit setVariable [QGVAR(side), _unitSide, true];
				_unit setVariable [QGVAR(unitIndex), _unitIndex, true];
				_unit setVariable [QGVAR(isLeader), _unitIsLeader, true];
				_unit setVariable [QGVAR(groupIndex), _unitGroupIndex, true];

				// Broadcast the new unit variable (for global fetching)
				missionNamespace setVariable [format [QGVAR(AIUnit_%1), _unitIndex], _unit, true];

				[_unit] remoteExecCall [QFUNC(unit_onInit), 0, false];

				// DEBUG
				if (_unitIndex == 0) then {guy1 = _unit; _unit setVehicleVarName "guy1"};
				if (_unitIndex == 1) then {guy2 = _unit; _unit setVehicleVarName "guy2"};
			};
		};

		GVAR(ai_sys_handleRespawn_nextUpdate) = _time + MACRO_SYS_UNITSPAWNINTERVAL;
	};
}];
