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
#include "..\..\res\macros\fnc_initVar.inc"

params [
	"_sector",
	["_thisList", []]
];

MACRO_FNC_INITVAR(GVAR(init), false);

// Wait for gm_postInit to finish
if (!GVAR(init)) exitWith {};





private _time            = time;
private _countEast       = 0;
private _countResistance = 0;
private _countWest       = 0;
private _side            = _sector getVariable [QGVAR(side), sideEmpty];





// Handle the capturing logic
if (
	GVAR(missionState) == MACRO_ENUM_MISSION_LIVE
	and {!(_sector getVariable [QGVAR(isLocked), false])}
) then {

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
	// TODO: Move this into sector_sys_handleClient!
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
if (GVAR(param_gm_enableVehicles) and {_side != sideEmpty}) then {
	private _letter       = _sector getVariable [QGVAR(letter), "?"];
	private _allSpawnData = _sector getVariable [format [QGVAR(sv_spawnDataVeh_%1), _side], []];
	private ["_veh", "_spawnData", "_isSpawnAreaFree", "_vehSide", "_vehPos", "_punishTime", "_damage"];

	{
		_veh       = _sector getVariable [format [QGVAR(vehicle_%1), _forEachIndex], objNull];
		_spawnData = _x;
		_spawnData params [
			"_class",             // 0
			"_respawnTime",       // 1
			"_spawnPos",          // 2
			"_vecDir",            // 3
			"_vecUp",             // 4
			"_respawnDelay",      // 5
			"_playersOnly",       // 6
			"_initialSpawnDelay", // 7
			"_radius",            // 8
			"_textures",          // 9
			"_animations",        // 10
			"_pylons"             // 11
		];

		if (
			!alive _veh
			and {_time > _respawnTime}
		) then {

			// Set the respawn time
			if (_respawnTime < 0 and {!isNull _veh}) then {
				_respawnTime = _time + _respawnDelay;
				_x set [1, _respawnTime];
				//systemChat format ["[%1] vehicle destroyed (%2: %3) - respawn in %4", _letter, _forEachIndex, _class, _respawnDelay];
				continue;
			};

			scopeName QGVAR(sector_handleServer_vehRespawn);

			// Ensure that the spawn area is empty
			_isSpawnAreaFree = true;
			{
				if (getPosWorld _x distanceSqr _spawnPos < (_radius + MACRO_FNC_BOUNDINGRADIUS(_x)) ^ 2) then {
					_isSpawnAreaFree = false;
					breakTo QGVAR(sector_handleServer_vehRespawn);
				};
			} forEach GVAR(allVehicles);

			if (!_isSpawnAreaFree) then {continue};

			// The area is clear; spawn the vehicle
			_veh = createVehicle [_class, _spawnPos, [], 0, "CAN_COLLIDE"];
			_veh setPosASL _spawnPos; // Do not use setPosWorld here!
			_veh setVectorDirAndUp [_vecDir, _vecUp];

			[_veh, _textures, _animations, _pylons] call FUNC(veh_setCustomisation);
			[_veh, _side, _playersOnly] remoteExecCall [QFUNC(veh_onInit), 0, format [QGVAR(veh_onInit_%1_%2), _letter, _forEachIndex]];

			_sector setVariable [format [QGVAR(vehicle_%1), _forEachIndex], _veh, true];

			_spawnData set [1, -1];

		} else {

			// If the vehicle is in use, clear its punish time
			if (
				GVAR(missionState) != MACRO_ENUM_MISSION_LIVE
				or {crew _veh findIf {[_x] call FUNC(unit_isAlive)} >= 0}
			) then {
				_veh setVariable [QGVAR(sv_punishTime), -1, false];
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
				_veh setVariable [QGVAR(sv_punishTime), -1, false];
				continue;
			};

			// From here on out, we can assume the vehicle is either abandoned or inoperable
			_punishTime = _veh getVariable [QGVAR(sv_punishTime), -1];

			if (_punishTime < 0) then {
				_veh setVariable [QGVAR(sv_punishTime), _time + MACRO_SECTOR_VEH_DELAYUNTILDAMAGE, false];
				//systemChat format ["[%1] vehicle is abandoned: %2", _sector getVariable [QGVAR(letter), "???"], _class];

			// If the punish time has been exceeded, start damaging the vehicle
			} else {
				if (_time < _punishTime) then {continue};

				// Only continue if the vehicle is local
				if (!local _veh) then {
					_veh setOwner clientOwner;
					continue;
				};

				_damage = (_veh getHitPointDamage "HitEngine") + (0.05 * MACRO_SECTOR_TRIGGERINTERVAL);		// 0.05 damage per second

				if (_damage >= 0.9) then {
					//systemChat format ["[%1] Destroying abandoned vehicle: %2", _sector getVariable [QGVAR(letter), "???"], _class];
					clearMagazineCargo _veh;
					_veh setFuel 0;
					_veh setVehicleAmmoDef 0;
					_veh setDamage 1;
				} else {
					// TODO: Revisit for static emplacements
					_veh setHitPointDamage ["HitEngine", _damage, false];
				};
			};
		};

	} forEach _allSpawnData;
};
