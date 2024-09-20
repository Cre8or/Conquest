/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles the game mechanics of the given sector, by monitoring the trigger area for units attempting to
		capture it. Also handles vehicle spawns for the given sector.

		Executed repeatedly from the trigger's condition code.
	Arguments:
		0:	<OBJECT>	The sector (trigger) to handle
		1:	<ARRAY>		A list of units currently inside the trigger's area
	Returns:
		(none)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_boundingRadius.inc"

params ["_sector", ["_thisList", []]];





// Set up some variables
private _time = time;
private _countWest = 0;
private _countEast = 0;
private _countResistance = 0;
private _side = _sector getVariable [QGVAR(side), sideEmpty];





// Check if the mission is live
if (GVAR(missionState) == MACRO_ENUM_MISSION_LIVE and {!(_sector getVariable [QGVAR(isLocked), false])}) then {

	// Validate the units inside the sector's area
	private _units = [];
	private ["_vehicle"];
	{
		if (_x isKindOf "CAManBase") then {

			if ([_x] call FUNC(unit_isAlive) and {_x getVariable [QGVAR(canCaptureSectors), false]}) then {
				_units pushBack _x;
			};

		} else {
			_vehicle = _x;

			{
				if ([_x] call FUNC(unit_isAlive) and {_x getVariable [QGVAR(canCaptureSectors), false]}) then {
					_units pushBack _x;
				};
			} forEach crew _vehicle;
		};
	} forEach _thisList;

	// Count how many units of each side are in the sector area
	{
		switch (side group _x) do {
			case west:       {_countWest = _countWest + 1};
			case east:       {_countEast = _countEast + 1};
			case resistance: {_countResistance = _countResistance + 1};
		};
	} forEach _units;

	// Determine which side has the most
	private _allCounts = [
		[_countEast,       east],
		[_countResistance, resistance],
		[_countWest,       west]
	];
	_allCounts sort false;	// Sort by decreasing order

	// Check if there is a dominant side at all
	private _sideDominant = sideEmpty;
	private _highestCount = _allCounts # 0 # 0;
	if (_highestCount > 0) then {

		// Make sure there is no tie
		if (_highestCount > (_allCounts # 1 # 0)) then {
			_sideDominant = _allCounts # 0 # 1;
		};
	};

	private _level          = _sector getVariable [QGVAR(level), 0];
	private _levelLast      = _sector getVariable [QGVAR(levelLast), 0];
	private _levelNextScore = _sector getVariable [QGVAR(levelNextScore), MACRO_SECTOR_SCOREINTERVAL];

	private _sideCapturing     = _sector getVariable [QGVAR(sideCapturing), sideEmpty];
	private _sideCapturingLast = _sector getVariable [QGVAR(sideCapturingLast), sideEmpty];

	private _flag = _sector getVariable [QGVAR(flagPole), objNull];

	private _lastTime  = _sector getVariable [QGVAR(lastUpdateTime), _time];
	private _deltaTime = _time - _lastTime;



	// If we have a dominant side that is trying to capture this sector...
	if (_sideDominant != sideEmpty and {_sideDominant != _side}) then {

		// If the sector is currently unowned, increase the level
		if (_side == sideEmpty and {_sideCapturing == sideEmpty or {_sideCapturing == _sideDominant}}) then {
			_level = _level + _deltaTime / GVAR(param_gm_sector_captureDuration);

			// Add score to the capturing units
			if (_level >= _levelNextScore) then {
				{
					[_x, MACRO_ENUM_SCORE_SECTOR_CAPTURING] call FUNC(gm_addScore);
				} forEach (_units select {_x getVariable [QGVAR(side), sideEmpty] == _sideDominant});

				_sector setVariable [QGVAR(levelNextScore), _levelNextScore + MACRO_SECTOR_SCOREINTERVAL, false];
			};

			// If the level reached 100%, claim the sector
			if (_level >= 1) then {

				// Broadcast the sector capture/loss radio message
				{
					[selectRandom [
						MACRO_ENUM_RADIOMSG_SECTORLOST_1,
						MACRO_ENUM_RADIOMSG_SECTORLOST_2
					]] remoteExecCall [QFUNC(gm_playRadioMsg), _x, false];
				} forEach (GVAR(sides) - [_sideDominant, sideEmpty]);

				[selectRandom [
					MACRO_ENUM_RADIOMSG_SECTORCAPTURED_1,
					MACRO_ENUM_RADIOMSG_SECTORCAPTURED_2,
					MACRO_ENUM_RADIOMSG_SECTORCAPTURED_3
				]] remoteExecCall [QFUNC(gm_playRadioMsg), _sideDominant, false];

				// Add score to the units who captured the sector
				{
					[_x, MACRO_ENUM_SCORE_SECTOR_CAPTURED] call FUNC(gm_addScore);
				} foreach (_units select {_x getVariable [QGVAR(side), sideEmpty] == _sideDominant});

				_level = 1;
				_side = _sideDominant;
				_sideCapturing = sideEmpty;
				_sector setVariable [QGVAR(side), _side, true];
				_sector setVariable [QGVAR(levelNextScore), 1 - MACRO_SECTOR_SCOREINTERVAL, false];

			// Otherwise, update the capturing side
			} else {
				_sideCapturing = _sideDominant;
			};

		// Otherwise, decrease it
		} else {
			_level = (_level -_deltaTime / GVAR(param_gm_sector_captureDuration)) max 0;

			// Add score to the neutralising units
			if (_level <= _levelNextScore) then {
				{
					[_x, MACRO_ENUM_SCORE_SECTOR_CAPTURING] call FUNC(gm_addScore);
				} forEach (_units select {_x getVariable [QGVAR(side), sideEmpty] == _sideDominant});

				_sector setVariable [QGVAR(levelNextScore), _levelNextScore - MACRO_SECTOR_SCOREINTERVAL, false];
			};

			// If the level reached 0%, neutralise the sector
			if (_level == 0) then {

				if (_side != sideEmpty) then {

					// Broadcast the sector losing/capturing message
					if (_side != sideEmpty) then {
						[selectRandom [
							MACRO_ENUM_RADIOMSG_SECTORLOSING_1,
							MACRO_ENUM_RADIOMSG_SECTORLOSING_2,
							MACRO_ENUM_RADIOMSG_SECTORLOSING_3
						]] remoteExecCall [QFUNC(gm_playRadioMsg), _side, false];
					};

					[selectRandom [
						MACRO_ENUM_RADIOMSG_SECTORCAPTURING_1,
						MACRO_ENUM_RADIOMSG_SECTORCAPTURING_2,
						MACRO_ENUM_RADIOMSG_SECTORCAPTURING_3
					]] remoteExecCall [QFUNC(gm_playRadioMsg), _sideDominant, false];

					// Add score to the units who neutralised the sector
					{
						[_x, MACRO_ENUM_SCORE_SECTOR_NEUTRALISED] call FUNC(gm_addScore);
					} foreach (_units select {_x getVariable [QGVAR(side), sideEmpty] == _sideDominant});

					_side = sideEmpty;
					_sector setVariable [QGVAR(side), _side, true];
					_sector setVariable [QGVAR(levelNextScore), MACRO_SECTOR_SCOREINTERVAL, false];
				};

				// Update the capturing side
				_sideCapturing = _sideDominant;
			};
		};

	// Otherwise, if nobody is around, or mostly units from the sector's side are present, slowly reset the flag towards its previous state
	} else {

		if (_highestCount == 0 or {_sideDominant == _side and {_side != sideEmpty}}) then {

			// If the sector is still unowned, return to the neutral state
			if (_side == sideEmpty) then {
				_level = (_level - _deltaTime / GVAR(param_gm_sector_captureDuration)) max 0;

				if (_level == 0) then {
					_sideCapturing = sideEmpty;
				};

			// Otherwise, increase the level back to 100%
			} else {
				_level = (_level + _deltaTime / GVAR(param_gm_sector_captureDuration)) min 1;

				// Reset the capturing side (if it's not empty yet)
				if (_level >= 1) then {
					_sideCapturing = sideEmpty;
				};
			};
		};
	};

	// Update the flag
	private _sideFlag = [_side, _sideCapturing] select (_sideCapturing != sideEmpty);
	private _sideFlagLast = _sector getVariable [QGVAR(sideFlagLast), sideEmpty];

	if (_sideFlag != _sideFlagLast) then {
		_flag setFlagTexture ([_sideFlag] call FUNC(gm_getFlagTexture));
	};

	// Update the flag's animation phase
	if (_level != _levelLast) then {
		_flag setFlagAnimationPhase _levelLast;
	};

	// Save the shared variables
	_sector setVariable [QGVAR(level), _level, (_level != _levelLast)];
	_sector setVariable [QGVAR(sideCapturing), _sideCapturing, (_sideCapturing != _sideCapturingLast)];

	// Save the serverside variables
	_sector setVariable [QGVAR(levelLast), _level, false];
	_sector setVariable [QGVAR(lastUpdateTime), _time, false];
	_sector setVariable [QGVAR(sideFlagLast), _sideFlag, false];
};





// Handle the sector's vehicle spawning
private _allVehicleSpawns = _sector getVariable [QGVAR(vehicleSpawns), []];
private _activeVehicles   = _sector getVariable [QGVAR(activeVehicles), []];
private _sideIndex = GVAR(sides) find _side;

if (_sideIndex >= 0) then {
	private ["_veh", "_spawnData", "_isRespawnCandidate", "_vehSide", "_vehPos", "_punishTime", "_damage"];

	{
		_veh = _activeVehicles param [_forEachIndex, objNull];
		_spawnData = _x param [_sideIndex, []];
		_spawnData params [["_class", ""], "_spawnPos", "_vecDir", "_vecUp", "_respawnDelay", "_playersOnly", "_forbiddenWeapons", "_forbiddenMagazines", "_invincibleHitPoints", "_radius", "_respawnTime"];

		scopeName QGVAR(sector_handleServer_vehLoop);

		// Check if the vehicle may be respawned
		_isRespawnCandidate = (
			_time > _respawnTime
			and {
				isNull _veh
				or {!alive _veh and {_respawnTime >= 0}}
			}
		);

		if (_isRespawnCandidate) then {

			// Ensure the class is valid
			if (_class == "") then {
				continue;
			};

			// Ensure that the spawn area is empty
			{
				if (getPosWorld _x distanceSqr _spawnPos > (_radius + MACRO_FNC_BOUNDINGRADIUS(_x)) ^ 2) then {
					continue;
				};

				if (!alive _x) then {
					_x setVariable [QGVAR(gm_sys_removeCorpses_removalTime), _time, false]; // Don't use -1
				};
			} forEach GVAR(allVehicles);

			_veh = createVehicle [_class, _spawnPos, [], 0, "CAN_COLLIDE"];
			_veh setPosWorld _spawnPos;
			_veh setVectorDirAndUp [_vecDir, _vecUp];

			if (GVAR(missionState) < MACRO_ENUM_MISSION_LIVE) then {
				[_veh, GVAR(safeStart)] remoteExec [QFUNC(safeStart_vehicle), 0, false]; // TODO: Handle JIP support after safestart refactor!
			};

			// Update the list of active vehicles
			_activeVehicles set [_forEachIndex, _veh];
			_sector setVariable [QGVAR(activeVehicles), _activeVehicles, false];
			GVAR(allVehicles) pushBack _veh;

			// Broadcast the new vehicles list to all clients
			// TODO: If we ever run into the situation where this array grows very large,
			// I should consider refactoring this and making separate add/remove functions
			// to individually manipulate the array. That way every client replicates it
			// on its own, reducing network traffic from having to send an entire array.
			// For now, this is probably good enough.
			publicVariable QGVAR(allVehicles);

			// Clear the vehicle's cargo
			clearWeaponCargoGlobal _veh;
			clearMagazineCargoGlobal _veh;
			clearItemCargoGlobal _veh;
			clearBackpackCargoGlobal _veh;

			// Save some variables onto the vehicle
			_veh setVariable [QGVAR(side), _side, true];
			_veh setVariable [QGVAR(playersOnly), _playersOnly, false];

			// If the vehicle has a custom respawn delay, save it too
			if (_respawnDelay >= 0) then {
				_veh setVariable [QGVAR(respawnDelay), _respawnDelay, false];
			};

			// Remove the forbidden weapons
			if !(_forbiddenWeapons isEqualTo []) then {
				{
					_veh removeWeaponGlobal _x;
				} forEach _forbiddenWeapons;
			};

			// Remove the forbidden magazines
			if !(_forbiddenMagazines isEqualTo []) then {
				private ["_turretPath"];
				{
					_turretPath = _x;
					{
						_veh removeMagazinesTurret [_x, _turretPath];
					} forEach _forbiddenMagazines;
				} forEach allTurrets [_veh, false];
			};

			// If any hitpoints should be invincible, we need to add a Hit EH
			if !(_invincibleHitPoints isEqualTo []) then {
				[_veh, _invincibleHitPoints] remoteExec [QFUNC(veh_handleDamage), 0, false];	// TODO: Find a way to make this JIP compatible without cluttering the JIP queue up with messages!
			};

			GVAR(curatorModule) addCuratorEditableObjects [[_veh], false];

			// Reset the respawn time
			_spawnData set [10, -1];

		// Currently not a candidate for respawning
		} else {

			if (!alive _veh) then {
				if (_respawnTime < 0) then {
					_spawnData set [10, _time + _respawnDelay];
					//systemChat format ["[%1] vehicle destroyed: %2", _sector getVariable [QGVAR(letter), "???"], _class];
				};
				continue;
			};

			// If the vehicle is in use, clear its punish time
			if (
				GVAR(missionState) != MACRO_ENUM_MISSION_LIVE
				or {crew _veh findIf {[_x] call FUNC(unit_isAlive)} >= 0}
			) then {
				_veh setVariable [QGVAR(punishTime), -1, false];
				continue;
			};

			_vehSide = _veh getVariable [QGVAR(side), sideEmpty];
			_vehPos  = getPosWorld _veh;

			// If the vehicle is operable, belongs to the same side as the sector, and is inside the combat area, reset its punish time
			if (
				_vehPos distanceSqr _spawnPos <= MACRO_SECTOR_VEH_MAXSQRDISTFROMSPAWN	// Still near its spawn point
				and {_vehSide == _side or {_side == sideEmpty}}					// Owned by the same side as the sector
				and {[_veh] call FUNC(veh_isOperable)}
				and {[_vehPos, _vehSide] call FUNC(ca_isInCombatArea)}	// Inside the combat area
			) then {
				_veh setVariable [QGVAR(punishTime), -1, false];
				continue;
			};

			// From here on out, we can assume the vehicle is either abandoned or inoperable
			_punishTime = _veh getVariable [QGVAR(punishTime), -1];

			if (_punishTime < 0) then {
				_veh setVariable [QGVAR(punishTime), _time + MACRO_SECTOR_VEH_DELAYUNTILDAMAGE, false];
				//systemChat format ["[%1] vehicle is abandoned: %2", _sector getVariable [QGVAR(letter), "???"], _class];

			// If the punish time has been exceeded, start damaging the vehicle
			} else {
				if (_time > _punishTime) then {

					// Only continue if the vehicle is local
					if (local _veh) then {
						_damage = (_veh getHitPointDamage "HitEngine") + (0.05 * MACRO_SECTOR_TRIGGERINTERVAL);		// 0.05 damage per second

						if (_damage >= 0.9) then {
							//systemChat format ["[%1] Destroying abandoned vehicle: %2", _sector getVariable [QGVAR(letter), "???"], _class];
							clearMagazineCargo _veh;
							_veh setFuel 0;
							_veh setVehicleAmmoDef 0;
							_veh setDamage 1;
						} else {
							_veh setHitPointDamage ["HitEngine", _damage, false];
						};

					// Otherwise, assign the locality to the server
					} else {
						_veh setOwner clientOwner;
					};
				};
			};
		};

	} forEach _allVehicleSpawns;
};
