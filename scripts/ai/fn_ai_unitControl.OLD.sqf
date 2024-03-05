#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"





// Set up some constants
private _maxProcessCost = 40;			// Arbitrary maximum cost - every iteration costs at least 1; additional checks (healing/resupplying/vehicles) further add to the cost
private _maxDistClaimVehSqr = MACRO_AI_CLAIMVEHICLE_MAXDIST ^ 2;
private _maxDistGetInVehSqr = 8 ^ 2;
private _minDistMovedToUnstuck = 0.25 ^ 2;	// How far the unit needs to move away from its previous position for its "stuck" timer to reset (and for the unit to no longer be considered as stuck), in meters
private _vehClaimChance = 1;			// The chance that a unit's vehicle claim roll succeeds (out of 1)
private _delayBetweenVehClaims = 1;		// How long a unit must wait before it may attempt another vehicle claim roll, in seconds
private _delayBetweenUnstuckMove = 1;		// A stuck unit will attempt to move every this often to get unstuck, in seconds
private _delayBetweenMoveToVeh = 3;		// The unit will move to its claimed vehicle (if it has one) every this often, in seconds
private _delayBetweenMoveToWP = 5;		// The unit will move to the group's waypoint every this often, in seconds
private _vehMinDistReplanWP = 10;		// Vehicle drivers won't replan their path (as they do on a regular basis) if they are within this many meters of their waypoint

// Set up some variables
private _index = 0;
private _safeStartIsOn = false;

// Shared
private ["_time", "_processCost", "_indexStart", "_AICount", "_unit", "_group", "_side", "_leader", "_isLeader", "_isLeaderPlayer", "_curVeh", "_inVehicle", "_prevVeh", "_curPos"];
// AI Squad Leader
private ["_pathData", "_pathIndex", "_pathIndexLast", "_curNodePos", "_nextMoveTime", "_curWP", "_groupWPs", "_WPIndex"];
// Vehicle - Stage 1
private ["_expectedDest", "_handleFollowPath"];
// Infantry - Stage 1
private ["_lastMovedDelay", "_isStuck"];
// Infantry - Stage 2
private ["_checkClaimForced", "_claimedVeh", "_claimedVehRole"];
private ["_vehDist", "_seatInfo", "_roleIsAvailable", "_unitClaimPriority", "_claimTimeStr", "_claimPriorityStr", "_claimedByStr", "_prevClaimedBy"];
// Infantry - Stage 3
private ["_combatArea", "_punishTime"];
// Infantry - Stage 4
private ["_curNodeRadius"];





// loop
while {true} do {

	scopeName "mainLoop";

	// Escape scheduled environment
	isNil {

		// If the mission isn't live, tell the AI to stay in place
		if (GVAR(missionState) != MACRO_ENUM_MISSION_LIVE) then {
			_safeStartIsOn = true;
			private "_veh";

			{
				if !(_x getVariable [QGVAR(safestart_disabledAI), false]) then {
					_x setVariable [QGVAR(safestart_disabledAI), true, false];

					_x doMove (getPosATL _x);

					_veh = vehicle _x;
					if !(_veh isKindOf "Air") then {
						_veh engineOn false;
					};

					_x disableAI "MOVE";
					_x disableAI "FSM";
					_x disableAI "TARGET";
					_x disableAI "AUTOTARGET";
					_x disableAI "WEAPONAIM";
					_x setUnitCombatMode "WHITE";
					(group _x) setCombatMode "WHITE";
				};
			} forEach GVAR(AIUnits);





		// Otherwise, start working
		} else {

			// If the round just started, re-enable the disabled AI components on all units
			if (_safeStartIsOn) then {
				_safeStartIsOn = false;

				{
					_x setVariable [QGVAR(safestart_disabledAI), false, false];

					_x enableAI "MOVE";
					_x enableAI "FSM";
					_x enableAI "TARGET";
					_x enableAI "AUTOTARGET";
					_x enableAI "WEAPONAIM";
					_x setUnitCombatMode "RED";
					(group _x) setCombatMode "RED";
				} forEach GVAR(AIUnits);
			};

			_time = time;
			_processCost = 0;
			_indexStart = _index;
			_AICount = 1 max count GVAR(AIUnits);



			// Iterate through the units
			while {_processCost < _maxProcessCost} do {
				_processCost = _processCost + 1;

				scopeName "unitLoop";

				// Fetch the current unit
				_unit = GVAR(AIUnits) param [_index, objNull];

				// Only continue if the unit is alive
				if (alive _unit) then {
					_processCost = _processCost + 1;

					// Fetch some info about our unit
					_group = group _unit;
					_side = side _group;
					_leader = leader _group;
					_isLeader = (_unit == _leader);
					_isLeaderPlayer = isPlayer _leader;
					_curVeh = vehicle _unit;
					_inVehicle = (_unit != _curVeh);
					_curPos = getPosATL _unit;



					// ------------------------------------------ AI SQUAD LEADER ------------------------------------------
					// Handle the squad's move orders
					_pathData = _unit getVariable [QGVAR(pathData), [[],[],[]]];
					_pathIndex = _unit getVariable [QGVAR(pathIndex), 0];
					_pathIndexLast = _unit getVariable [QGVAR(pathIndexLast), 0];
					_curNodePos = (_pathData # 0) param [_pathIndex, _curPos];
					_nextMoveTime = _unit getVariable [QGVAR(nextMoveTime), 0];
					_curWP = _group getVariable [QGVAR(curWP), _curPos];

					// If the group leader is dead, take over until he spawns back in
					if (!alive _leader) then {
						_group selectLeader _unit;
					};

					// If the unit is the leader of the group, check if the group's current waypoint has changed
					if (_isLeader) then {
						_groupWPs = waypoints _group;
						_WPIndex = currentWaypoint _group;

						// If the group currently has a waypoint...
						if (count _groupWPs > 1) then {
							_group setCurrentWaypoint (_groupWPs # (_WPIndex max 1));

							// If this waypoint's position doesn't match the current waypoint's position, copy it over
							if !(waypointPosition (_groupWPs # _WPIndex) isEqualTo _curWP) then {

								// Update our variables
								_curWP = waypointPosition (_groupWPs # _WPIndex);
								_group setVariable [QGVAR(curWP), _curWP, false];

								systemChat format ["%1 - Received WP", _group];

								// Notify every group member to refresh their current move order
								{
									_x setVariable [QGVAR(forceRecalcPath), true, false];
								} forEach units _group;
							};
						};
					};





					// If the unit is in a vehicle...
					if (_inVehicle) then {
						_unit setVariable [QGVAR(claimedVeh), objNull, false];
						_unit setVariable [QGVAR(prevVeh), _curVeh, false];

						// If the unit is driving...
						if (_unit == driver _curVeh) then {

							// ------------------------------------------ VEHICLES - STAGE 1 ------------------------------------------
							// ...check if the leader has any orders for us
							if (_isLeaderPlayer) then {
								_curVeh setEffectiveCommander _unit;

								_expectedDest = (expectedDestination _unit) param [0, [0,0,0]];

								if !(_expectedDest distance2D [0,0,0] < _vehMinDistReplanWP or {_unit getVariable [QGVAR(lastExpectedDest), []] isEqualTo _expectedDest}) then {
									_unit setVariable [QGVAR(lastExpectedDest), _expectedDest, false];
									_unit setVariable [QGVAR(forceRecalcPath), true, false];

								};

								_curWP = _unit getVariable [QGVAR(lastExpectedDest), _curWP];
							};

							// Handle the vehicles's move orders
							if (!(_curWP isEqualTo []) and {_unit getVariable [QGVAR(forceRecalcPath), false] or {_time > (_unit getVariable [QGVAR(nextRecalcPathTime), 0])} or {_pathData isEqualTo [[],[],[]]}}) then {
								_processCost = _processCost + 10;

								// Calculate a path to the new destination
								if (_curPos distance2D _curWP > _vehMinDistReplanWP) then {
									_pathData = [_curVeh, ATLtoASL _curWP] call FUNC(nm_findPath);
/*
									// If no path could be found, set the path to go directly towards the objective
									if (_pathData isEqualTo [[],[],[]]) then {
										_pathData = [[_curWP], [0], [objNull]];
									};
*/
									// Fetch and terminate the previous followPath script
									terminate (_unit getVariable [QGVAR(handle_followPath), scriptNull]);

									// Start the followPath script on the returned path
									_handleFollowPath = [_curVeh, _pathData] spawn FUNC(veh_followPath);
									_unit setVariable [QGVAR(handle_followPath), _handleFollowPath, false];
								};

								// Update the unit's variables
								_unit setVariable [QGVAR(nextRecalcPathTime), _time + (0.8 + random 0.2) * MACRO_AI_VEH_DELAYUNTILRECALCPATH, false];
								_unit setVariable [QGVAR(forceRecalcPath), false, false];
								_unit setVariable [QGVAR(pathData), _pathData, false];
							};
						};





					// Otherwise, if the unit is on foot...
					} else {

						// If the group is being lead by a player...
						if (_isLeaderPlayer) then {
							_unit setVariable [QGVAR(claimedVeh), objNull, false];

						// Otherwise, do our own thinking
						} else {
							// ------------------------------------------ INFANTRY - STAGE 1 ------------------------------------------
							// Handle the stuck status
							_isStuck = _unit getVariable [QGVAR(isStuck), false];

							// Reclaim the group locality, if needed
							if (!local _group) then {
								_group setGroupOwner 2;
								_unit setOwner 2;
							};

							// If the unit has moved beyond the minimum distance threshold, update its information
							if (_curPos distanceSqr (_unit getVariable [QGVAR(prevPos), [0,0,0]]) > _minDistMovedToUnstuck) then {

								_unit setVariable [QGVAR(prevPos), _curPos, false];
								_unit setVariable [QGVAR(lastMovedTime), _time, false];
								_unit setVariable [QGVAR(isStuck), false, false];

								// If the unit was previously stuck, give it some extra time to keep moving (before the groupWP is reapplied)
								if (_isStuck) then {
									//systemChat format ["%1 is no longer stuck", _unit];
									_unit setVariable [QGVAR(nextMoveTime), _time + _delayBetweenMoveToWP, false];
									_isStuck = false;
								};

							// Otherwise, check how long it's been stationary
							} else {
								_lastMovedDelay = _time - (_unit getVariable [QGVAR(lastMovedTime), -MACRO_AI_DELAYUNTILFORCERESPAWN]);

								// If the unit hasn't moved in a while, we take a closer look at it...
								if (_lastMovedDelay > MACRO_AI_DELAYUNTILSTUCK) then {

									// If the unit has been stuck for a while, we delete it
									if (_lastMovedDelay > MACRO_AI_DELAYUNTILFORCERESPAWN) then {
										systemChat format ["Deleting %1 (stuck)", _unit];
										deleteVehicle _unit;
									} else {

										// If the unit is inside the area of a sector that isn't owned (or at 100% level), then it's trying to capture ( = not stuck)
										if ((GVAR(allSectors) findIf {_unit inArea _x and (_x getVariable [QGVAR(side), sideEmpty] != _side or {_x getVariable [QGVAR(level), 0] < 1})}) >= 0) then {
											_unit setVariable [QGVAR(lastMovedTime), _time, false];
											//systemChat format ["%1 isn't stuck, but capping", _unit];

										// Otherwise, we mark it as being stuck
										} else {

											// If the unit wasn't already stuck, reset its move time (so it can attempt to get unstuck)
											if (!_isStuck) then {
												//systemChat format ["%1 is stuck", _unit];
												_isStuck = true;
												_unit setVariable [QGVAR(isStuck), true, false];
												_unit setVariable [QGVAR(nextMoveTime), 0, false];
											};
										};
									};
								};
							};



							// ------------------------------------------ INFANTRY - STAGE 2 ------------------------------------------
							// Handle vehicle claiming
							[_unit] allowGetIn false;
							_claimedVeh = _unit getVariable [QGVAR(claimedVeh), objNull];
							_checkClaimForced = _unit getVariable [QGVAR(forceCheckClaim), false];

							// Check if this unit may look for a vehicle
							if (_checkClaimForced or {_time > (_unit getVariable [QGVAR(vehClaimTime), 0])}) then {

								// Reset the claim time
								_unit setVariable [QGVAR(vehClaimTime), _time + _delayBetweenVehClaims, false];

								if (_checkClaimForced or (!_isStuck and {GVAR(param_AI_allowVehicles)} and {random 1 < _vehClaimChance})) then {
									_processCost = _processCost + 1;
									_claimedVeh = objNull;
									_claimedVehRole = [];
									_unit setVariable [QGVAR(forceCheckClaim), false, false];

									scopeName "vehicleClaim";

									// Fetch all nearby claimable vehicles
									private _nearbyVehicles = [];
									{
										if (
											!(_x getVariable [QGVAR(playersOnly), false])
											and {_x getVariable [QGVAR(side), sideEmpty] == _side}
											and {canMove _x}
											and {fuel _x > 0})
										then {
											_vehDist = _x distanceSqr _unit;

											if (_vehDist < _maxDistClaimVehSqr) then {
												_nearbyVehicles pushBack [_vehDist, _x];
											};
										};
									} forEach GVAR(allVehicles);
									_nearbyVehicles sort true;

									// Iterate through the claimable vehicles until we find a good one
									{
										_x params ["_distSqr", "_vehX"];
										_unitClaimPriority = (MACRO_AI_CLAIMVEHICLE_MAXDIST - sqrt _distSqr) / MACRO_AI_CLAIMVEHICLE_MAXDIST;

										scopeName "vehicleClaimLoop";

										// Iterate through this vehicle's roles
										{
											_x params ["_role", "_turretPath"];

											// If we reached a cargo role, move on to the next vehicle
											if (_role == MACRO_ENUM_VEHICLEROLE_CARGO) then {
												breakTo "vehicleClaimLoop";
											};

											// Check if the current role is available
											_roleIsAvailable = switch (_role) do {
												case MACRO_ENUM_VEHICLEROLE_DRIVER:	{!alive driver _vehX};
												case MACRO_ENUM_VEHICLEROLE_GUNNER:	{!alive gunner _vehX};
												case MACRO_ENUM_VEHICLEROLE_COMMANDER:	{!alive commander _vehX};
												case MACRO_ENUM_VEHICLEROLE_TURRET:	{!alive (_vehX turretUnit _turretPath)};
											};

											// If this role is available, check if we can claim it
											if (_roleIsAvailable) then {
												_claimTimeStr = format [QGVAR(%1_%2_claimTime), _role, _turretPath];
												_claimPriorityStr = format [QGVAR(%1_%2_claimPriority), _role, _turretPath];

												// If the previous claim expired, or if this unit's priority is higher than the previous claimer's, we can have it
												if (_time - (_vehX getVariable [_claimTimeStr, 0]) > MACRO_AI_CLAIMVEHICLE_TIMEOUT or {_unitClaimPriority > (_vehX getVariable [_claimPriorityStr, 0])}) then {
													_claimedByStr = format [QGVAR(%1_%2_claimedBy), _role, _turretPath];
													_prevClaimedBy = _vehX getVariable [_claimedByStr, objNull];

													// Let the previous claiming unit know that it needs to look for a new vehicle/role
													if (alive _prevClaimedBy and {_prevClaimedBy != _unit}) then {
														_prevClaimedBy setVariable [QGVAR(forceCheckClaim), true, false];
													};

													// Finally, we claim this vehicle role
													_vehX setVariable [_claimedByStr, _unit, false];
													_vehX setVariable [_claimTimeStr, _time, false];
													_vehX setVariable [_claimPriorityStr, _unitClaimPriority, false];
													_unit setVariable [QGVAR(claimedVeh), _vehX, false];
													_claimedVeh = _vehX;
													_claimedVehRole = [_role, _turretPath];

													// Reset the move time so the unit can move towards the vehicle
													_unit setVariable [QGVAR(nextMoveTime), 0, false];

													//systemChat format ["%1 claimed %2 (%3)", _unit, typeOf _claimedVeh, _claimedVehRole];

													breakTo "vehicleClaim";
												};
											};

										} forEach ([_vehX] call FUNC(veh_getRoles));

									} forEach _nearbyVehicles;
								};
							};

							// If the unit has a claimed vehicle...
							if (alive _claimedVeh) then {
								_distSqr = _unit distanceSqr _claimedVeh;

								// Check if it is within range of its claimed vehicle
								if (_distSqr < _maxDistGetInVehSqr) then {

									// Mount up
									switch (_claimedVehRole # 0) do {
										case MACRO_ENUM_VEHICLEROLE_DRIVER:	{_unit moveInDriver _claimedVeh};
										case MACRO_ENUM_VEHICLEROLE_GUNNER:	{_unit moveInGunner _claimedVeh};
										case MACRO_ENUM_VEHICLEROLE_COMMANDER:	{_unit moveInCommander _claimedVeh};
										case MACRO_ENUM_VEHICLEROLE_TURRET:	{_unit moveInTurret [_claimedVeh, _turretPath]};
									};

									// If we managed to get into the vehicle, update our variables
									if (_unit in _claimedVeh) then {
										_inVehicle = true;
										_curVeh = _claimedVeh;
										[_unit] allowGetIn true;
										//systemChat format ["%1 mounted up", _unit];

										// Reset the current path data
										_unit setVariable [QGVAR(pathData), [[],[],[]], false];

									// Otherwise, query a vehicle claim update
									} else {
										_unit setVariable [QGVAR(forceCheckClaim), true, false];
										//systemChat format ["%1 failed to mount up", _unit];
									};

									// Reset the claimed vehicle variable
									_claimedVeh = objNull;
									_unit setVariable [QGVAR(claimedVeh), objNull, false];

								// Otherwise...
								} else {
									// ...if the vehicle is now outside of the claim range, we query another vehicle claim update
									if (_distSqr > _maxDistClaimVehSqr) then {
										_claimedVeh = objNull;
										_unit setVariable [QGVAR(claimedVeh), objNull, false];
										_unit setVariable [QGVAR(forceCheckClaim), true, false];
										//systemChat format ["%1's claimed vehicle went too far", _unit];

										// Reset the move time so the unit can go on about its job
										_unit setVariable [QGVAR(nextMoveTime), 0, false];
									};
								};
							};

							// Unclaim the previous vehicle (if there is one)
							if (alive _prevVeh) then {
								_unit setVariable [QGVAR(prevVeh), objNull, false];
							};



							// ------------------------------------------ INFANTRY - STAGE 3 ------------------------------------------
							// Check if the unit is inside the combat area (if we have one)
							_combatArea = missionNamespace getVariable [format [QGVAR(CA_%1), _side], []];

							if (_curPos inPolygon _combatArea or {_combatArea isEqualTo []}) then {
								_unit setVariable [QGVAR(punishTime), -1, false];

							// The combat area is valid, and the unit is outside of it
							} else {
								_punishTime = _unit getVariable [QGVAR(punishTime), -1];

								// If the punish time hasn't been set yet, set it
								if (_punishTime < 0) then {
									systemChat format ["%1 left the combat area", _unit];
									_unit setVariable [QGVAR(punishTime), _time + MACRO_CA_DELAYUNTILDEATH, false];

								// Otherwise, if the unit has been outside the combat area for too long, kill it
								} else {
									if (_time > _punishTime) then {
										systemChat format ["Killed %1 for deserting", _unit];
										_unit setDamage 1;
									};
								};
							};



							// ------------------------------------------ INFANTRY - STAGE 4 ------------------------------------------
							// Check if the unit should recalculate its path
							if (_unit getVariable [QGVAR(forceRecalcPath), false] or {_time > (_unit getVariable [QGVAR(nextRecalcPathTime), 0])} or {_pathData isEqualTo [[],[],[]]}) then {
								_processCost = _processCost + 6;

								// Calculate a path to the new destination
								_pathData = [_unit, ATLtoASL _curWP, false, true] call FUNC(nm_findPath);
								_pathIndexLast = count (_pathData # 0) - 1;

								// If no path could be found...
								if (_pathIndexLast < 0) then {

									// ...and the waypoint is inside the combat area, go directly towards the objective
									if (_curWP inPolygon _combatArea or {_combatArea isEqualTo []}) then {
										_pathData = [[_curWP], [0], [objNull]];

									// Otherwise, stay where we are
									} else {
										_pathData = [[_curPos], [0], [objNull]];
									};
									_pathIndexLast = 0;
								};

								// Fetch the current node's position
								_pathIndex = 0;
								_curNodePos = (_pathData # 0) param [_pathIndex, _curPos];

								// Update the unit's variables
								_unit setVariable [QGVAR(nextRecalcPathTime), _time + (0.8 + random 0.2) * MACRO_AI_INF_DELAYUNTILRECALCPATH, false];
								_unit setVariable [QGVAR(forceRecalcPath), false, false];
								_unit setVariable [QGVAR(pathData), _pathData, false];
								_unit setVariable [QGVAR(pathIndex), _pathIndex, false];
								_unit setVariable [QGVAR(pathIndexLast), _pathIndexLast, false];
								_unit setVariable [QGVAR(nextMoveTime), 0, false];

							// Otherwise, monitor the unit's progress along its current path
							} else {
								_curNodeRadius = (_pathData # 1) param [_pathIndex, 0];

								// If the unit has reached its current node...
								if (_unit distanceSqr _curNodePos < _curNodeRadius) then {

									// If there are any nodes left to go to after this one, increase the path index
									if (_pathIndex < _pathIndexLast) then {
										_pathIndex = _pathIndex + 1;
										_curNodePos = (_pathData # 0) # _pathIndex;
										_unit setVariable [QGVAR(pathIndex), _pathIndex, false];
										//systemChat format ["%1 moving to %2 (radius: %3)", _unit, _pathIndex, sqrt ((_pathData # 1) param [_pathIndex, 0])];

										// Reset the unit's move time
										_nextMoveTime = 0;
										_unit setVariable [QGVAR(nextMoveTime), 0, false];
									};
								};
							};

							// Check if the unit should move
							if (_time > _nextMoveTime) then {

								// If the unit is stuck, attempt to move it around
								if (_isStuck) then {
									_unit doMove (_curPos vectorAdd [5 - random 10, 5 - random 10, 0]);
									_unit setVariable [QGVAR(nextMoveTime), _time + _delayBetweenUnstuckMove, false];
									//systemChat format ["%1 shuffling...", _unit];

								// Otherwise....
								} else {

									// If the unit has claimed a vehicle, move towards it
									if (alive _claimedVeh) then {
										_unit doMove getPosATL _claimedVeh;
										_unit setVariable [QGVAR(nextMoveTime), _time + _delayBetweenMoveToVeh, false];

									// Otherwise...
									} else {

										// Move to the path's current node
										_unit doMove _curNodePos;
										_unit setVariable [QGVAR(nextMoveTime), _time + _delayBetweenMoveToWP, false];
										//systemChat "Moving to waypoint";
									};
								};
							};
						};
					};
				};



				// If we've looped through all units at least once, stop
				_index = (_index + 1) % _AICount;
				if (_index == _indexStart) then {
					breakTo "mainLoop";
				};
			};
		};
	};

	sleep 0.1;
};
