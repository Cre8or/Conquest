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

#include "\a3\editor_f\Data\Scripts\dikCodes.h"

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"
#include "..\..\res\macros\tween_rampDown.inc"

if (!hasInterface) exitWith {};





// Set up some variales
MACRO_FNC_INITVAR(GVAR(gm_sys_handlePlayerRespawn_EH), -1);

MACRO_FNC_INITVAR(GVAR(respawn_east), objNull);
MACRO_FNC_INITVAR(GVAR(respawn_resistance), objNull);
MACRO_FNC_INITVAR(GVAR(respawn_west), objNull);

MACRO_FNC_INITVAR(GVAR(kb_act_pressed_giveUp), false);

MACRO_FNC_INITVAR(GVAR(ui_sm_role), MACRO_ENUM_ROLE_INVALID);

GVAR(gm_sys_handlePlayerRespawn_prevUpdate)      = time;
GVAR(gm_sys_handlePlayerRespawn_nextUpdate)      = 0; // Interfaces with unit_setUnconscious
GVAR(gm_sys_handlePlayerRespawn_prevAlive)       = false;
GVAR(gm_sys_handlePlayerRespawn_prevPlayer)      = player;
GVAR(gm_sys_handlePlayerRespawn_nextShowMenu)    = 0;
GVAR(gm_sys_handlePlayerRespawn_spawnTimeOut)    = 0;
GVAR(gm_sys_handlePlayerRespawn_bledOut)         = false;
GVAR(gm_sys_handlePlayerRespawn_protectionTime)  = 0; // Interfaces with unit_onFired
GVAR(gm_sys_handlePlayerRespawn_spawnRequested)  = false; // Spawnmenu interface, set to true when the player presses the "SPAWN" button
GVAR(gm_sys_handlePlayerRespawn_state)           = MACRO_ENUM_RESPAWN_INIT; // Interfaces with gm_spawnPlayer
GVAR(gm_sys_handlePlayerRespawn_respawnTime)     = 0; // Interfaces with unit_onKilled
GVAR(gm_sys_handlePlayerRespawn_unconsciousTime) = -1;





// Handle player respawning
removeMissionEventHandler ["EachFrame", GVAR(gm_sys_handlePlayerRespawn_EH)];
GVAR(gm_sys_handlePlayerRespawn_EH) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	private _spawnStatusUI  = uiNamespace getVariable [QGVAR(RscSpawnStatus), displayNull];
	private _unconsciousHUD = uiNamespace getVariable [QGVAR(RscUnconsciousHUD), displayNull];
	private _time = time;

	if (GVAR(missionState) <= MACRO_ENUM_MISSION_LIVE and {_time > 0}) then {

		private _player = player;
		private _alive  = alive _player; // Don't use unit_isAlive here!



		// Single player work-around: respawning is performed by selecting a different player when
		// the original palyer unit dies. We detect this here.
		if (_player != GVAR(gm_sys_handlePlayerRespawn_prevPlayer)) then {
			GVAR(gm_sys_handlePlayerRespawn_prevPlayer) = _player;

			_player setVariable [QGVAR(isSpawned), false, true];
			_alive = false;
		};

		// Detect deaths
		if (_alive) then {
			if (!GVAR(gm_sys_handlePlayerRespawn_prevAlive)) then {

				[_player, false] call FUNC(unit_setUnconscious);

				// Ensure other machines don't consider this unit to be respawned (yet)
				_player setVariable [QGVAR(isSpawned), false, true];

				QGVAR(RscUnconsciousHUD) cutRsc ["Default", "PLAIN"];

				[false, 0.5] call FUNC(ui_blackScreen);
				QGVAR(RscSpawnStatus) cutRsc [QGVAR(RscSpawnStatus), "PLAIN"];
				_spawnStatusUI = uiNamespace getVariable [QGVAR(RscSpawnStatus), displayNull];

				// Holster the player's weapon
				_player action ["SwitchWeapon", _player, _player, -1];
				_player switchMove "amovpercmstpsnonwnondnon";
				_player allowDamage false;

				// NOTE: It is not possible to mix r2t cameras with "regular" ones (using camCreate).
				// Since the spawn menu might use the r2t camera (depending on which menu is open), we have
				// to use a workaround by using switchCamera. This is not ideal, but gets the job done.
				switchCamera GVAR(cam_panorama);

				[MACRO_ENUM_INPUTLOCK_RESPAWN, true] call FUNC(ui_disableUserInput);
			};

			// Ensure the player is always attached to their respawn object while awaiting spawning
			if (GVAR(gm_sys_handlePlayerRespawn_state) <= MACRO_ENUM_RESPAWN_SPAWNREQUESTED) then {
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
			if (GVAR(gm_sys_handlePlayerRespawn_prevAlive)) then {

				if (!GVAR(gm_sys_handlePlayerRespawn_bledOut)) then {
					GVAR(gm_sys_handlePlayerRespawn_respawnTime) = _time + GVAR(param_gm_unit_respawnDelay);
				};
				GVAR(gm_sys_handlePlayerRespawn_bledOut) = false;

				[true, 0.5] call FUNC(ui_blackScreen);

				// Reset the state to the beginning
				GVAR(gm_sys_handlePlayerRespawn_state) = MACRO_ENUM_RESPAWN_INIT;
			};
		};

		GVAR(gm_sys_handlePlayerRespawn_prevAlive) = _alive;



		if (_time > GVAR(gm_sys_handlePlayerRespawn_nextUpdate)) then {

			// Handle state transitions
			private _continue = true;
			while {_continue} do {

				private _spawnMenu = uiNamespace getVariable [QGVAR(RscSpawnMenu), displayNull];
				private _prevState = GVAR(gm_sys_handlePlayerRespawn_state);

				switch (GVAR(gm_sys_handlePlayerRespawn_state)) do {

					case MACRO_ENUM_RESPAWN_INIT: {
						GVAR(gm_sys_handlePlayerRespawn_spawnRequested) = false;
						GVAR(gm_sys_handlePlayerRespawn_nextShowMenu)   = -1;
						GVAR(gm_sys_handlePlayerRespawn_state)          = MACRO_ENUM_RESPAWN_SELECTINGSECTOR;

						if (GVAR(ui_sm_role) != MACRO_ENUM_ROLE_INVALID) then {
							GVAR(role) = GVAR(ui_sm_role);
						};
					};

					case MACRO_ENUM_RESPAWN_SELECTINGSECTOR: {

						// Unassign the selected side if it ran out of tickets
						if !([GVAR(side)] call FUNC(gm_isSidePlayable)) then {
							GVAR(side) = sideEmpty;
						};

						// Wait for the player to select a sector
						if (!GVAR(gm_sys_handlePlayerRespawn_spawnRequested)) then {

							if (!isNull _spawnMenu) then {
								GVAR(gm_sys_handlePlayerRespawn_nextShowMenu) = _time + MACRO_SM_RESPAWN_OPENINTERVAL;

							} else {

								// Once the player has physically respawned, set the countdown for the spawn menu to open up
								if (_alive and {GVAR(gm_sys_handlePlayerRespawn_nextShowMenu) < 0}) then {
									GVAR(gm_sys_handlePlayerRespawn_nextShowMenu) = _time + 1;
								};

								// Don't open the spawn menu if the escape menu is open
								if (
									_alive
									and {isNull findDisplay 49}
									and {_time > GVAR(gm_sys_handlePlayerRespawn_nextShowMenu)}
								) then {
									["ui_init"] call FUNC(ui_spawnMenu);

									if (GVAR(side) != sideEmpty) then {
										["ui_button_click", [MACRO_IDC_SM_DEPLOY_BUTTON]] call FUNC(ui_spawnMenu);
									};

									GVAR(gm_sys_handlePlayerRespawn_nextShowMenu) = _time + MACRO_SM_RESPAWN_OPENINTERVAL;
								};
							};

						} else {
							GVAR(gm_sys_handlePlayerRespawn_state) = MACRO_ENUM_RESPAWN_SECTORSELECTED;
						};
					};

					case MACRO_ENUM_RESPAWN_SECTORSELECTED: {

						if (
							_alive
							and {_time > GVAR(gm_sys_handlePlayerRespawn_respawnTime)}
							and {isNull _spawnMenu}
						) then {
							GVAR(gm_sys_handlePlayerRespawn_spawnTimeOut) = _time + 3;
							GVAR(gm_sys_handlePlayerRespawn_state)        = MACRO_ENUM_RESPAWN_SPAWNREQUESTED;

							// Request to be spawned
							[_player, GVAR(spawnSector)] remoteExecCall [QFUNC(gm_requestPlayerSpawn), 2, false];
						};
					};

					case MACRO_ENUM_RESPAWN_SPAWNREQUESTED: {
						// If the requested spawn sector is no longer spawnable, or if the server didn't respond
						// to the spawn request (for whatever reason), go back a step
						if (
							_time > GVAR(gm_sys_handlePlayerRespawn_spawnTimeOut)
							or {GVAR(side) != GVAR(spawnSector) getVariable [QGVAR(side), sideEmpty]}
						) then {
							GVAR(gm_sys_handlePlayerRespawn_spawnRequested) = false;
							GVAR(gm_sys_handlePlayerRespawn_state)          = MACRO_ENUM_RESPAWN_SELECTINGSECTOR;
						};

						// Transition to the next state is triggered by gm_spawnPlayer
					};

					case MACRO_ENUM_RESPAWN_SPAWNED_FROZEN: {
						GVAR(gm_sys_handlePlayerRespawn_protectionTime) = _time + GVAR(param_gm_unit_spawnProtectionDuration);
						GVAR(gm_sys_handlePlayerRespawn_state)          = MACRO_ENUM_RESPAWN_SPAWNED_UNFROZEN;

						switchCamera _player;

						["ui_close", true] call FUNC(ui_spawnMenu);

						[MACRO_ENUM_INPUTLOCK_RESPAWN, false] call FUNC(ui_disableUserInput);
						[false, 0.5] call FUNC(ui_blackScreen);
						QGVAR(RscSpawnStatus) cutRsc ["Default", "PLAIN"];

						// Focus the main map
						private _ctrlMap = (findDisplay 12) displayCtrl 51;
						[_ctrlMap, MACRO_UI_MAPFOCUS_PADDING_FULLSCREEN] call FUNC(ui_focusMap);

						// Enable the GPS by default
						// TODO: Add configuration option to choose the side the GPS is shown on
						setInfoPanel ["right", "MinimapDisplay"];
					};

					case MACRO_ENUM_RESPAWN_SPAWNED_UNFROZEN: {

						if (!GVAR(safeStart) and {_time > GVAR(gm_sys_handlePlayerRespawn_protectionTime)}) then {
							GVAR(gm_sys_handlePlayerRespawn_state) = MACRO_ENUM_RESPAWN_SPAWNED_UNPROTECTED;
							_player allowDamage true;	// TODO: Reimplement safestart guard after safestart rewrite
						};
					};

					case MACRO_ENUM_RESPAWN_SPAWNED_UNPROTECTED: {

						// Detect unconsciousness
						if (_player getVariable [QGVAR(isUnconscious), false]) then {
							GVAR(gm_sys_handlePlayerRespawn_state) = MACRO_ENUM_RESPAWN_UNCONSCIOUS;
							[MACRO_ENUM_INPUTLOCK_RESPAWN, true] call FUNC(ui_disableUserInput);

							GVAR(gm_sys_handlePlayerRespawn_respawnTime) = _time + GVAR(param_gm_unit_respawnDelay);
							GVAR(gm_sys_handlePlayerRespawn_nextUpdate)  = -1;
							GVAR(gm_sys_handlePlayerRespawn_bledOut)     = false;

							// Open the unconscious HUD
							QGVAR(RscUnconsciousHUD) cutRsc [QGVAR(RscUnconsciousHUD), "PLAIN"];
							_unconsciousHUD = uiNamespace getVariable [QGVAR(RscUnconsciousHUD), displayNull];
						};
					};

					case MACRO_ENUM_RESPAWN_UNCONSCIOUS: {

						if (_player getVariable [QGVAR(isUnconscious), false]) then {

							// Store the time when we entered this state (used for the UI fade-in animation)
							if (GVAR(gm_sys_handlePlayerRespawn_unconsciousTime) < 0) then {
								GVAR(gm_sys_handlePlayerRespawn_unconsciousTime) = _time;
							};

							private _bleedoutTime = _player getVariable [QGVAR(bleedoutTime), -1];

							if (_time > _bleedoutTime) then {
								_player setDamage 1;

								// Remember that the player bled out; this prevents the respawn timer from
								// being reset once the system registers the player's death.
								GVAR(gm_sys_handlePlayerRespawn_bledOut) = true;
							};

							// Check if the player is holding the give-up keybinding
							if (GVAR(kb_act_pressed_giveUp)) then {
								private _deltaTime = _time - GVAR(gm_sys_handlePlayerRespawn_prevUpdate);

								_bleedoutTime = _bleedoutTime - _deltaTime * GVAR(param_gm_unit_reviveDuration);
								_player setVariable [QGVAR(bleedoutTime), _bleedoutTime, false];

								playSoundUI ["click", 1, 2, true];
							};

							// Find the nearest medic
							private _c_maxDistMedicSqr = MACRO_UI_ICONS3D_MAXDISTANCE_ROLEACTION ^ 2;
							private _medic             = objNull;
							private _medicDistSqr      = _c_maxDistMedicSqr;
							private ["_distSqrX"];

							{
								_distSqrX = _player distanceSqr _x;

								if (_distSqrX < _medicDistSqr) then {
									_medicDistSqr = _distSqrX;
									_medic        = _x;
								};
							} forEach (allUnits select {
								_x == vehicle _x
								and {_x getVariable [QGVAR(role), MACRO_ENUM_ROLE_INVALID] == MACRO_ENUM_ROLE_MEDIC}
								and {_x getVariable [QGVAR(side), sideEmpty] == GVAR(side)}
								and {_x distanceSqr _player < _c_maxDistMedicSqr}
								and {[_x] call FUNC(unit_isAlive)}
								and {_x != _player}
							});

							openMap [false, false];

							// Handle the unconscious HUD
							private _ctrlCountdown = _unconsciousHUD displayCtrl MACRO_IDC_UHUD_TEXT_COUNTDOWN;
							private _ctrlMedicNone = _unconsciousHUD displayCtrl MACRO_IDC_UHUD_TEXT_MEDIC_NONE;
							private _ctrlMedicDist = _unconsciousHUD displayCtrl MACRO_IDC_UHUD_TEXT_MEDIC_DISTANCE;
							private _ctrlMedicName = _unconsciousHUD displayCtrl MACRO_IDC_UHUD_TEXT_MEDIC_NAME;
							private _ctrlGiveUp    = _unconsciousHUD displayCtrl MACRO_IDC_UHUD_TEXT_GIVE_UP;

							// Update the countdown
							private _delay = ceil (_bleedoutTime - _time max 0);
							_ctrlCountdown ctrlSetText str _delay;

							// Display the nearest medic's distance and name
							private _foundMedic = !isNull _medic;
							_ctrlMedicNone ctrlShow !_foundMedic;
							_ctrlMedicDist ctrlShow _foundMedic;
							_ctrlMedicName ctrlShow _foundMedic;

							if (_foundMedic) then {
								private _medicDistStr = format ["Nearest medic (%1 m):", ceil sqrt _medicDistSqr];
								private _medicNameStr = name _medic;

								private _widthMedicDist = ("w" + _medicDistStr) getTextWidth [MACRO_FONT_UI_MEDIUM, MACRO_POS_UHUD_MEDIC_TEXTSIZE];
								private _widthMedicName = ("w" + _medicNameStr) getTextWidth [MACRO_FONT_UI_MEDIUM, MACRO_POS_UHUD_MEDIC_TEXTSIZE];
								private _offset         = (MACRO_POS_UHUD_WIDTH - _widthMedicDist - _widthMedicName) / 2;

								_ctrlMedicDist ctrlSetPositionX _offset;
								_ctrlMedicDist ctrlSetPositionW _widthMedicDist;
								_ctrlMedicDist ctrlCommit 0;

								_ctrlMedicName ctrlSetPositionX (_offset + _widthMedicDist);
								_ctrlMedicName ctrlSetPositionW _widthMedicName;
								_ctrlMedicName ctrlCommit 0;

								_ctrlMedicDist ctrlSetText _medicDistStr;
								_ctrlMedicName ctrlSetText _medicNameStr;

								private _medicNameColour = [SQUARE(MACRO_COLOUR_A100_FRIENDLY), SQUARE(MACRO_COLOUR_A100_SQUAD)] select (group _medic == group _player);
								_ctrlMedicName ctrlSetTextColor _medicNameColour;
							};

							// Show the keybinding to give up
							private _keyBind = [MACRO_MISSION_FRAMEWORK_GAMEMODE, QGVAR(kb_giveUp)] call CBA_fnc_getKeybind;
							private ["_keyBindStr"];

							if (isNil "_keyBind" or {_keyBind isEqualTo []}) then {
								_keyBindStr = "No Key Assigned";
							} else {
								_keyBindStr = (_keyBind param [5, [MACRO_KEYBIND_GIVEUP]]) call CBA_fnc_localizeKey;
							};

							_ctrlGiveUp ctrlSetText format ["Hold [%1] to give up", _keyBindStr];

						// Detect revival
						} else {
							GVAR(gm_sys_handlePlayerRespawn_state)           = MACRO_ENUM_RESPAWN_SPAWNED_UNPROTECTED;
							GVAR(gm_sys_handlePlayerRespawn_unconsciousTime) = -1;

							QGVAR(RscUnconsciousHUD) cutRsc ["Default", "PLAIN"];

							[MACRO_ENUM_INPUTLOCK_RESPAWN, false] call FUNC(ui_disableUserInput);
						};
					};
				};

				// Continue until no further state transitions are possible
				_continue = (_prevState != GVAR(gm_sys_handlePlayerRespawn_state));
			};

			GVAR(gm_sys_handlePlayerRespawn_nextUpdate) = _time + MACRO_GM_SYS_HANDLEPLAYERRESPAWN_INTERVAL;
			GVAR(gm_sys_handlePlayerRespawn_prevUpdate) = _time;
		};

		// Update the spawn status UI
		if (!isNull _spawnStatusUI) then {

			private _ctrlText = _spawnStatusUI displayCtrl MACRO_IDC_SS_STATUS_TEXT;
			private _str = "";

			switch (GVAR(gm_sys_handlePlayerRespawn_state)) do {
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
					_str = format ["Spawning in %1", abs (0 max ceil (GVAR(gm_sys_handlePlayerRespawn_respawnTime) - _time))];
				};
				case MACRO_ENUM_RESPAWN_SPAWNREQUESTED: {
					_str = "Spawning...";
				};
			};

			_ctrlText ctrlSetText _str;
		};

		// Handle the unconscious HUD's fade-in animation
		if (!isNull _unconsciousHUD) then {
			private _ctrlGrp = _unconsciousHUD displayCtrl MACRO_IDC_UHUD_CTRLGRP;

			private _animEndTime = GVAR(gm_sys_handlePlayerRespawn_unconsciousTime) + MACRO_UHUD_FADEIN_ANIMDURATION;
			private _animPhase   = 1 - MACRO_TWEEN_RAMPDOWN(_time, _animEndTime, MACRO_UHUD_FADEIN_ANIMDURATION);
			private _ctrlPos     = ctrlPosition _ctrlGrp;

			// Start centered, expand up and down
			_ctrlGrp ctrlSetPositionY (safeZoneY + safezoneH / 2 - MACRO_POS_UHUD_HEIGHT * (0.5 + 0.5 * _animPhase));
			_ctrlGrp ctrlSetPositionH (MACRO_POS_UHUD_HEIGHT * _animPhase);
			_ctrlGrp ctrlCommit 0;
		};

	} else {

		if (!isNull _spawnStatusUI) then {
			QGVAR(RscSpawnStatus) cutRsc ["Default", "PLAIN"];
		};

		if (!isNull _unconsciousHUD) then {
			QGVAR(RscUnconsciousHUD) cutRsc ["Default", "PLAIN"];
		};
	};
}];
