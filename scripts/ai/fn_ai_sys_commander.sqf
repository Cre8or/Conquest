/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles the high-level commanding of local AI groups (attack/defend objectives) using waypoints.

		Only executed once by all machines upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"





// Set up some variables
MACRO_FNC_INITVAR(GVAR(ai_sys_commander_EH), -1);
MACRO_FNC_INITVAR(GVAR(ai_sys_commander_EH_draw3D_debug), -1);
MACRO_FNC_INITVAR(GVAR(ai_sys_commander_sectorLookup), locationNull);

GVAR(ai_sys_commander_nextUpdate) = 0;
GVAR(ai_sys_commander_side_index) = -1;
GVAR(ai_sys_commander_side)       = sideEmpty;
GVAR(ai_sys_commander_groups)     = [];
GVAR(ai_sys_commander_sectors)    = [];
GVAR(ai_sys_commander_groupData)  = [];
GVAR(ai_sys_commander_count)      = 0;
GVAR(ai_sys_commander_index)      = -1;

#ifdef MACRO_DEBUG_AI_COMMANDER
	GVAR(debug_ai_commander_data) = [];
#endif

// Reset all groups' states
{
	_x setVariable [QGVAR(ai_unitControl_waypointPos), [0,0,0], false];
	_x setVariable [QGVAR(ai_sys_commander_nextUpdate), 0, false];
	_x setVariable [QGVAR(ai_sys_commander_sector), objNull, false];
} forEach allGroups;





removeMissionEventHandler ["EachFrame", GVAR(ai_sys_commander_EH)];
GVAR(ai_sys_commander_EH) = addMissionEventHandler ["EachFrame", {

	#ifdef MACRO_DEBUG_AI_COMMANDER_DISABLED
		if (true) exitWith {};
	#endif

	if (isGamePaused or {GVAR(missionState) != MACRO_ENUM_MISSION_LIVE}) exitWith {};

	private _time = time;

	// Update candidate groups
	private _allGroupsPolled = false;
	private ["_group", "_units", "_leader","_count", "_centerPos", "_totalWeight", "_weight", "_groupData", "_distScore", "_inheritedGoalPos", "_leaderVeh", "_crew", "_passenger", "_groupX"];
	for "_groupIndex" from GVAR(ai_sys_commander_index) to 0 step -1 do {

		scopeName QGVAR(ai_sys_commander_loop);

		// Exit early if no more groups may be handled this frame (balances the load over multiple frames)
		if (_groupIndex < ((GVAR(ai_sys_commander_nextUpdate) - _time) * GVAR(ai_sys_commander_count) / MACRO_AI_COMMANDER_INTERVAL)) then {
			breakOut QGVAR(ai_sys_commander_loop);
		};

		_group = GVAR(ai_sys_commander_groups) param [_groupIndex, grpNull];

		if (
			!isNull _group
			and {local _group}
		) then {
			_units  = units _group select {[_x] call FUNC(unit_isAlive)};
			_leader = leader _group;

			// Ignore groups with no alive units, or with a player leader
			if (_units isEqualTo [] or {isPlayer _leader}) then {
				breakTo QGVAR(ai_sys_commander_loop);
			};

			_count       = count _units;
			_centerPos   = [];
			_totalWeight = 0;
			if !(_leader in _units) then {
				_leader = objNull;
			};

			// Get the center position of the group (average of all units, with extra weight for the leader)
			{
				if (_x == _leader) then {
					_weight = _count - 1 max 1;
					_totalWeight = _totalWeight + _weight;
					_centerPos   = _centerPos vectorAdd (getPosWorld _x vectorMultiply _weight);
				} else {
					_totalWeight = _totalWeight + 1;
					_centerPos = _centerPos vectorAdd getPosWorld _x;
				};
			} forEach _units;

			_centerPos = _centerPos vectorMultiply (1 / _totalWeight);
			_groupData = [];
			_distScore = 0;

			// AI drivers copy their crew's waypoints, if there is one
			_inheritedGoalPos = [];

			if ([_leader] call FUNC(unit_isAlive) and {_group getVariable [QGVAR(isVehicleGroup), false]}) then {
				_leaderVeh = vehicle _leader;
				_crew      = (fullCrew [_leaderVeh, "cargo", false]) apply {_x # 0};
				_passenger = _crew param [_crew findIf {
					_groupX = group _x;

					(_groupX != _group
					and {alive _x} // Ignore dead units
					and {!isPlayer _x}) // Ignore players
				}, objNull];

				_inheritedGoalPos = _passenger getVariable [QGVAR(ai_sys_unitControl_goalPos), []];
			};
			_group setVariable [QGVAR(ai_sys_commander_inheritedGoalPos), _inheritedGoalPos, false];

			if (_inheritedGoalPos isEqualTo []) then {

				// Make a list of the group's candidate sectors, sorted by distance
				_groupData = GVAR(ai_sys_commander_sectors) apply {_centerPos distance getPosWorld _x};
				{
					_distScore = _distScore + _x; // Distance score (lower is better)
					_groupData set [_forEachIndex, [_x, _forEachIndex]];
				} forEach _groupData;
				_groupData sort true;
			};

			// Insert the group's candidate sectors data with its distance score as the first entry (used for sorting later)
			GVAR(ai_sys_commander_groupData) pushBack [_distScore, _group, _centerPos, _groupData];
		};

		if (_groupIndex > 0) then {
			GVAR(ai_sys_commander_index) = _groupIndex - 1;
		} else {
			GVAR(ai_sys_commander_index) = -1;
			_allGroupsPolled = true;
		};
	};



	// All groups have been polled, now we crunch the sector data and dispatch orders
	if (_allGroupsPolled) then {
		private _strategicValues = GVAR(ai_sys_commander_sectors) apply {_x getVariable [QGVAR(strategicValue), 1]};
		private ["_sector", "_indexBest", "_canReceiveOrders", "_distBest", "_attackPoints", "_waypointPos", "_newWaypointPos"];

		#ifdef MACRO_DEBUG_AI_COMMANDER
			GVAR(debug_ai_commander_data) set [GVAR(ai_sys_commander_side_index), []];
		#endif

		// Process groups in order of increasing distance to the nearest candidate sector.
		// This prioritises groups that are already close to candidate sectors.
		GVAR(ai_sys_commander_groupData) sort true;

		{
			_x params ["", "_group", "_centerPos", "_groupData"];

			_inheritedGoalPos = _group getVariable [QGVAR(ai_sys_commander_inheritedGoalPos), []];
			_sector           = _group getVariable [QGVAR(ai_sys_commander_sector), objNull];
			_indexBest        = -1;
			_canReceiveOrders = (
				_time > _group getVariable [QGVAR(ai_sys_commander_nextUpdate), 0] // Cooldown expired
				or {!(GVAR(ai_sys_commander_sectorLookup) getVariable [str _sector, false])} // Sector is no longer a candidate
			);

			if (_canReceiveOrders) then {
				_distBest  = 1e38;

				// Pick the best candidate sector, factoring in strategic value, and how many other groups are already headed there
				{
					_x params ["_dist", "_index"];
					_dist = _dist / (_strategicValues # _index);

					if (_dist <= _distBest) then {
						_indexBest = _index;
						_distBest  = _dist;
					};
				} forEach _groupData;

			} else {
				_indexBest = GVAR(ai_sys_commander_sectors) find _sector;
			};

			// Order the group to the best candidate sector
			if (_indexBest >= 0 or {_inheritedGoalPos isNotEqualTo []}) then {
				_strategicValues set [_indexBest, (_strategicValues # _indexBest) / MACRO_AI_COMMANDER_STRATEGICVALUE_DECREASEPERGROUP];

				_waypointPos = _group getVariable [QGVAR(ai_unitControl_waypointPos), [0,0,0]];

				// Determine whether the group should go to the best sector, or an inherited goal position
				if (_inheritedGoalPos isEqualTo []) then {
					_sector         = GVAR(ai_sys_commander_sectors) # _indexBest;
					_attackPoints   = _sector getVariable [QGVAR(attackPoints), []];
					_newWaypointPos = getPosWorld _sector;
				} else {
					_sector           = objNull;
					_attackPoints     = [];
					_newWaypointPos   = +_inheritedGoalPos;
					_canReceiveOrders = true;
				};

				if (_canReceiveOrders) then {
					if (_attackPoints isEqualTo []) then {
						if !(_waypointPos distanceSqr _newWaypointPos < MACRO_AI_COMMANDER_WAYPOINT_MINDISTANCE ^ 2) then {
							_group addWaypoint [ASLtoATL _newWaypointPos, 0, 1];
						};
					} else {
						if ((_attackPoints findIf {_waypointPos distanceSqr _x < MACRO_AI_COMMANDER_WAYPOINT_MINDISTANCE ^ 2}) < 0) then {
							_group addWaypoint [ASLtoATL selectRandom _attackPoints, 0, 1];
						};
					};

					_group setVariable [QGVAR(ai_sys_commander_sector), _sector, true]; // Must be broadcast to allow remote AI commanders to make the right decisions
					_group setVariable [QGVAR(ai_sys_commander_nextUpdate), _time + (0.75 + random 0.5) * MACRO_AI_COMMANDER_NEWORDER_COOLDOWN, false];
				};

				#ifdef MACRO_DEBUG_AI_COMMANDER
					private _debug_colour = (switch (GVAR(ai_sys_commander_side)) do {
						case east:       {[0.8, 0,   0,   1]};
						case resistance: {[0,   0.6, 0,   1]};
						case west:       {[0,   0.4, 0.9, 1]};
						default          {[0.5, 0,   0.8, 1]};
					});

					(GVAR(debug_ai_commander_data) # GVAR(ai_sys_commander_side_index)) set [_forEachIndex, [
						groupId _group,
						_debug_colour,
						ASLtoATL _centerPos,
						ASLtoATL _waypointPos,
						[GVAR(ai_sys_commander_side)] call FUNC(gm_getFlagTexture)
					]];
				#endif
			};

		} forEach GVAR(ai_sys_commander_groupData);
	};



	// Restart the cycle for the next frame.
	// Doing this *after* the update loop guarantees no frame gets skipped due to resetting the nextUpdate time,
	// as we now have to wait at least one frame for the next cycle to be evaluated.
	if (_time > GVAR(ai_sys_commander_nextUpdate) and {GVAR(ai_sys_commander_index) < 0}) then {
		GVAR(ai_sys_commander_nextUpdate) = _time + MACRO_AI_COMMANDER_INTERVAL;

		// Pick the next side to be handled
		GVAR(ai_sys_commander_side_index) = (GVAR(ai_sys_commander_side_index) + 1) mod 3; // Hardcoded; there can only be up to 3 sides in Conquest
		GVAR(ai_sys_commander_side)       = GVAR(sides) # GVAR(ai_sys_commander_side_index);

		// Determine candidate sectors
		private _capturableSectors = GVAR(allSectors) select {
			!(_x getVariable [QGVAR(isLocked), false]) // Sector must not be locked
			and {
				GVAR(ai_sys_commander_side) != _x getVariable [QGVAR(side), sideEmpty] // Only include unowned sectors, aswell as...
				or {(_x getVariable [QGVAR(level), 0]) < MACRO_AI_COMMANDER_SECTOR_MINLEVELOWNED} // ...owned sectors that are at risk of being lost
			}
		};

		private _hasSpawnableSector = (GVAR(allSectors) findIf {
			_x getVariable [QGVAR(side), sideEmpty] == GVAR(ai_sys_commander_side)
			and {(_x getVariable [format [QGVAR(spawnPoints_%1), GVAR(ai_sys_commander_side)], []]) isNotEqualTo []}
		}) >= 0;
		private _capturableSectorsWithSpawnPoints = [];
		{
			if ((_x getVariable [format [QGVAR(spawnPoints_%1), GVAR(ai_sys_commander_side)], []]) isNotEqualTo []) then {
				_capturableSectorsWithSpawnPoints pushBack _x;
			};
		} forEach _capturableSectors;

		// Normally we let AI groups capture any and all unowned sectors that can be captured.
		// The only exception to this rule is when the side has no spawnable sectors left (usually indicating
		// that the side is about to lose). In that case, we specifically want to target sectors that the side
		// can spawn on, to reduce the risk of defeat.
		// This exception only matters if there are any suitable sectors to be captured, though. If not,
		// revert to capturing any unowned sector, and hope for the best.
		if (_hasSpawnableSector or {_capturableSectorsWithSpawnPoints isEqualTo []}) then {
			GVAR(ai_sys_commander_sectors) = _capturableSectors;
		} else {
			GVAR(ai_sys_commander_sectors) = _capturableSectorsWithSpawnPoints;
		};

		// Compile the candidate sectors lookup table
		deleteLocation GVAR(ai_sys_commander_sectorLookup);
		GVAR(ai_sys_commander_sectorLookup) = createLocation ["NameVillage", [0,0,0], 0, 0];

		{
			GVAR(ai_sys_commander_sectorLookup) setVariable [str _x, true];
		} forEach GVAR(ai_sys_commander_sectors);

		// Determine the concerned groups and candidate sectors
		if (GVAR(ai_sys_commander_sectors) isNotEqualTo []) then {
			GVAR(ai_sys_commander_groups)    = allGroups select {local _x and {side _x == GVAR(ai_sys_commander_side)}};
			GVAR(ai_sys_commander_count)     = count GVAR(ai_sys_commander_groups);
			GVAR(ai_sys_commander_index)     = GVAR(ai_sys_commander_count) - 1;
			GVAR(ai_sys_commander_groupData) = [];
		};
	};
}];





// Debug rendering
removeMissionEventHandler ["Draw3D", GVAR(ai_sys_commander_EH_draw3D_debug)];

#ifdef MACRO_DEBUG_AI_COMMANDER
	GVAR(ai_sys_commander_EH_draw3D_debug) = addMissionEventHandler ["Draw3D", {

		if (isGamePaused) exitWith {};

		{
			{
				_x params ["_groupName", "_colour", "_centerPos", "_waypointPos", "_flag"];

				if (!isNil "_x" and {_centerPos isNotEqualTo [0,0,0]}) then {
					cameraEffectEnableHUD true;
					drawIcon3D [
						"a3\ui_f\data\IGUI\Cfg\IslandMap\iconSelect_ca.paa",
						_colour,
						_centerPos,
						1,
						1,
						0,
						_groupName,
						2
					];

					if (_waypointPos isNotEqualTo []) then {

						private _count = 10;
						private _diff = (ATLtoASL _waypointPos) vectorDiff (ATLtoASL _centerPos);
						private _distMul = 0.25 * (_centerPos distance2D _waypointPos);
						for "_i" from 0 to _count - 1 do {
							drawLine3D [
								ASLtoATL (ATLtoASL _centerPos vectorAdd (_diff vectorMultiply (_i / _count)) vectorAdd [0, 0, _distMul * sin (180 * _i / _count)]),
								ASLtoATL (ATLtoASL _centerPos vectorAdd (_diff vectorMultiply ((_i + 1) / _count)) vectorAdd [0, 0, _distMul * sin (180 * (_i + 1) / _count)]),
								[0, 1, 0.0, 1]
							];
						};

						drawIcon3D [
							_flag,
							[1, 1, 1, 0.5],
							_waypointPos,
							0.5 * 4/3,
							0.5,
							0,
							"",
							2
						];

						drawIcon3D [
							"",
							_colour,
							_waypointPos,
							0.5,
							0.5,
							0,
							_groupName,
							2
						];

					};
				};
			} forEach _x;
		} foreach GVAR(debug_ai_commander_data);
	}];
#endif
