/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles the respawning for the player.
		When a player is respawned, their controls are taken away and they are looking through the panorama
		camera. The spawn menu is kept open until a valid spawn selection is made, at which point the player
		is put back into the action by the server.

		Only executed once by the client upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"

#include "..\..\res\macros\fnc_initVar.inc"

if (!hasInterface) exitWith {};

disableSerialization;





// Set up some variales
MACRO_FNC_INITVAR(GVAR(gm_sys_handlePlayerRespawn_EH), -1);

MACRO_FNC_INITVAR(GVAR(respawn_east), objNull);
MACRO_FNC_INITVAR(GVAR(respawn_resistance), objNull);
MACRO_FNC_INITVAR(GVAR(respawn_west), objNull);

GVAR(sys_handlePlayerRespawn_nextUpdate)     = 0;
GVAR(sys_handlePlayerRespawn_isAlive)        = false;
GVAR(sys_handlePlayerRespawn_nextShowMenu)   = 0;
GVAR(sys_handlePlayerRespawn_spawnTimeOut)   = 0;
GVAR(sys_handlePlayerRespawn_protectionTime) = 0;
GVAR(sys_handlePlayerRespawn_forceRespawn)   = false; // External interface to force a respawn (currently only used for singleplayer respawn)
GVAR(sys_handlePlayerRespawn_spawnRequested) = false; // Spawnmenu interface, set to true when the player presses the "SPAWN" button
GVAR(sys_handlePlayerRespawn_state)          = MACRO_ENUM_RESPAWN_INIT;
GVAR(sys_handlePlayerRespawn_respawnTime)    = 0;




// Handle player respawning
removeMissionEventHandler ["EachFrame", GVAR(gm_sys_handlePlayerRespawn_EH)];
GVAR(gm_sys_handlePlayerRespawn_EH) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	private _spawnStatusUI = uiNamespace getVariable [QGVAR(RscSpawnStatus), displayNull];
	private _time = time;

	if (GVAR(missionState) <= MACRO_ENUM_MISSION_LIVE and {_time > 0}) then {

		private _player = player;
		private _alive  = alive _player; // Don't use FUNC(unit_isAlive) here!

		// Handle external respawn requests
		if (GVAR(sys_handlePlayerRespawn_forceRespawn)) then {
			GVAR(sys_handlePlayerRespawn_forceRespawn) = false;

			_player setVariable [QGVAR(isSpawned), false, true];
			_alive = false;
		};

		// Detect deaths
		if (_alive) then {
			if (!GVAR(sys_handlePlayerRespawn_isAlive)) then {
				GVAR(sys_handlePlayerRespawn_isAlive) = true;

				// Ensure other machines don't consider this unit to be respawned (yet)
				_player setVariable [QGVAR(isSpawned), false, true];

				[false, 0.5] call FUNC(ui_blackScreen);
				QGVAR(RscSpawnStatus) cutRsc [QGVAR(RscSpawnStatus), "PLAIN"];
				_spawnStatusUI = uiNamespace getVariable [QGVAR(RscSpawnStatus), displayNull];

				// Holster the player's weapon
				_player action ["SwitchWeapon", _player, _player, -1];
				_player switchMove "amovpercmstpsnonwnondnon";
				_player allowDamage false;

				// NOTE: It is not possible to mix r2t cameras with "regular" ones.
				// Since the spawn menu might use the r2t camera (depending on which menu is open), we have
				// to use a workaround by using switchCamera. This is not ideal, but gets the job done.
				switchCamera GVAR(cam_panorama);

				[true] call FUNC(ui_disableUserInput);
			};

			// Ensure the player is always attached to their respawn object while awaiting spawning
			if (GVAR(sys_handlePlayerRespawn_state) <= MACRO_ENUM_RESPAWN_SPAWNREQUESTED) then {
				private _respawnObject = (switch (GVAR(side)) do {
					case east:       {GVAR(respawn_east)};
					case resistance: {GVAR(respawn_resistance)};
					case west:       {GVAR(respawn_west)};
					default          {objNull};
				});

				if (alive _respawnObject and {attachedTo _player != _respawnObject}) then {
					_player attachTo [_respawnObject, [0,0,0]];
				};
			};

		} else {
			if (GVAR(sys_handlePlayerRespawn_isAlive)) then {
				GVAR(sys_handlePlayerRespawn_isAlive)     = false;
				GVAR(sys_handlePlayerRespawn_respawnTime) = _time + GVAR(Param_GM_Unit_RespawnDelay);

				[true, 0.5] call FUNC(ui_blackScreen);

				// Reset the state to the beginning
				GVAR(sys_handlePlayerRespawn_state) = MACRO_ENUM_RESPAWN_INIT;
			};
		};

		if (_time > GVAR(sys_handlePlayerRespawn_nextUpdate)) then {

			// Handle state transitions
			private _continue = true;
			while {_continue} do {

				private _spawnMenu = uiNamespace getVariable [QGVAR(RscSpawnMenu), displayNull];
				private _prevState = GVAR(sys_handlePlayerRespawn_state);
				switch (GVAR(sys_handlePlayerRespawn_state)) do {

					case MACRO_ENUM_RESPAWN_INIT: {
						GVAR(sys_handlePlayerRespawn_spawnRequested) = false;
						GVAR(sys_handlePlayerRespawn_nextShowMenu)   = _time + 1;
						GVAR(sys_handlePlayerRespawn_state)          = MACRO_ENUM_RESPAWN_SELECTINGSECTOR;
					};

					case MACRO_ENUM_RESPAWN_SELECTINGSECTOR: {

						// Unassign the selected side if it ran out of tickets
						if !([GVAR(side)] call FUNC(gm_isSidePlayable)) then {
							GVAR(side) = sideEmpty;
						};

						// Wait for the player to select a sector
						if (!GVAR(sys_handlePlayerRespawn_spawnRequested)) then {

							if (!isNull _spawnMenu) then {

								GVAR(sys_handlePlayerRespawn_nextShowMenu) = _time + MACRO_SM_RESPAWN_OPENINTERVAL;

							} else {
								// Don't open the spawn menu if the escape menu is open
								if (isNull findDisplay 49 and {_time > GVAR(sys_handlePlayerRespawn_nextShowMenu)}) then {

									// Force-open the spawn mnenu's deploy screen
									["ui_init"] call FUNC(ui_spawnMenu);

									if (GVAR(side) != sideEmpty) then {
										["ui_button_click", [MACRO_IDC_SM_DEPLOY_BUTTON]] call FUNC(ui_spawnMenu);
									};

									GVAR(sys_handlePlayerRespawn_nextShowMenu) = _time + MACRO_SM_RESPAWN_OPENINTERVAL;
								};
							};

						} else {
							GVAR(sys_handlePlayerRespawn_state) = MACRO_ENUM_RESPAWN_SECTORSELECTED;
						};
					};

					case MACRO_ENUM_RESPAWN_SECTORSELECTED: {

						if (
							_alive
							and {_time > GVAR(sys_handlePlayerRespawn_respawnTime)}
							and {isNull _spawnMenu}
						) then {
							GVAR(sys_handlePlayerRespawn_spawnTimeOut) = _time + 3;
							GVAR(sys_handlePlayerRespawn_state)        = MACRO_ENUM_RESPAWN_SPAWNREQUESTED;

							// Request to be spawned
							[_player, GVAR(spawnSector)] remoteExecCall [QFUNC(gm_requestPlayerSpawn), 2, false];
						};
					};

					case MACRO_ENUM_RESPAWN_SPAWNREQUESTED: {
						// If the requested spawn sector is no longer spawnable, or if the server didn't respond
						// to the spawn request (for whatever reason), go back a step
						if (
							_time > GVAR(sys_handlePlayerRespawn_spawnTimeOut)
							or {GVAR(side) != GVAR(spawnSector) getVariable [QGVAR(side), sideEmpty]}
						) then {
							GVAR(sys_handlePlayerRespawn_spawnRequested) = false;
							GVAR(sys_handlePlayerRespawn_state)          = MACRO_ENUM_RESPAWN_SELECTINGSECTOR;
						};

						// Transition to the next state is triggered by gm_spawnPlayer
					};

					case MACRO_ENUM_RESPAWN_SPAWNED_FROZEN: {
						GVAR(sys_handlePlayerRespawn_protectionTime) = _time + GVAR(Param_GM_Unit_SpawnProtectionDuration);
						GVAR(sys_handlePlayerRespawn_state)          = MACRO_ENUM_RESPAWN_SPAWNED_UNFROZEN;

						switchCamera _player;

						(uiNamespace getVariable [QGVAR(RscSpawnMenu), displayNull]) closeDisplay 0;

						[false] call FUNC(ui_disableUserInput);

						[false, 0.5] call FUNC(ui_blackScreen);
						QGVAR(RscSpawnStatus) cutRsc ["Default", "PLAIN"];

						// Focus the main map
						private _ctrlMap = (findDisplay 12) displayCtrl 51;
						[_ctrlMap, MACRO_UI_MAPFOCUS_PADDING_FULLSCREEN] call FUNC(ui_focusMap);
					};

					case MACRO_ENUM_RESPAWN_SPAWNED_UNFROZEN: {

						if (_time > GVAR(sys_handlePlayerRespawn_protectionTime)) then {
							GVAR(sys_handlePlayerRespawn_state) = MACRO_ENUM_RESPAWN_SPAWNED_UNPROTECTED;

							//if (!GVAR(safeStart)) then {
								_player allowDamage true;	// TODO: Reimplement safestart guard after safestart rewrite
							//};
						};
					};
				};

				// Continue until no further state transitions are possible
				_continue = (_prevState != GVAR(sys_handlePlayerRespawn_state));
			};

			GVAR(sys_handlePlayerRespawn_nextUpdate) = _time + 0.25; // Must be less than the MP respawn time
		};

		// Update the spawn status UI
		if (!isNull _spawnStatusUI) then {

			private _ctrlText = _spawnStatusUI displayCtrl MACRO_IDC_SS_STATUS_TEXT;
			private _str = "";

			switch (GVAR(sys_handlePlayerRespawn_state)) do {
				case MACRO_ENUM_RESPAWN_INIT;
				case MACRO_ENUM_RESPAWN_SELECTINGSECTOR: {
					if (GVAR(side) == sideEmpty) then {
						_str = "Select a side";
					} else {
						if (GVAR(role) == MACRO_ENUM_ROLE_INVALID) then {
							_str = "Select a role";
						} else {
							_str = "Select a spawn sector";
						};
					};
				};
				case MACRO_ENUM_RESPAWN_SECTORSELECTED: {
					_str = format ["Spawning in %1", abs (0 max ceil (GVAR(sys_handlePlayerRespawn_respawnTime) - _time))];
				};
				case MACRO_ENUM_RESPAWN_SPAWNREQUESTED: {
					_str = "Spawning...";
				};
			};

			_ctrlText ctrlSetText _str;
		};

	} else {

		// Close the status UI
		if (!isNull _spawnStatusUI) then {
			QGVAR(RscSpawnStatus) cutRsc ["Default", "PLAIN"];
		};
	};
}];
