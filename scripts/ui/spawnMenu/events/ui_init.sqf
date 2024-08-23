// Initialisation
case "ui_init": {
	_eventExists = true;

	// Sanity check
	if (!isNull _spawnMenu) exitWith {systemChat "ERROR: Spawn menu is already open!"};

	// Initialise some variables
	MACRO_FNC_INITVAR(GVAR(cam_role_curFov),MACRO_SM_ROLEPREVIEW_BASEFOV);
	MACRO_FNC_INITVAR(GVAR(cam_role_isReady),false);
	MACRO_FNC_INITVAR(GVAR(cam_role_useNVG),false);
	MACRO_FNC_INITVAR(GVAR(cam_role),objNull);
	MACRO_FNC_INITVAR(GVAR(rt_role_wall),objNull);
	MACRO_FNC_INITVAR(GVAR(rt_role_unit),objNull);
	MACRO_FNC_INITVAR(GVAR(rt_role_light),objNull);
	MACRO_FNC_INITVAR(GVAR(ui_sm_role), MACRO_ENUM_ROLE_INVALID);
	MACRO_FNC_INITVAR(GVAR(ui_sm_prevMenu), 0);
	MACRO_FNC_INITVAR(GVAR(ui_sm_EH_eachFrame), 0);

	// Create the spawn menu display
	createDialog QGVAR(RscSpawnMenu);
	_spawnMenu = uiNamespace getVariable [QGVAR(RscSpawnMenu), displayNull];

	// Error checking
	if (isNull _spawnMenu) exitWith {
		diag_log format ["[CONQUEST] Spawn menu failed to open! Aborting... (%1)", _event];
		systemChat format ["Spawn menu failed to open! Aborting... (%1)", _event];
	};

	// Attach an EH to the spawn menu to detect when it is closed
	_spawnMenu displayAddEventHandler ["Unload", {
		["ui_unload"] call FUNC(ui_spawnMenu);
	}];

	// Turn on the blur post-process effect
	GVAR(ui_sm_blurFx) ppEffectAdjust [2];
	GVAR(ui_sm_blurFx) ppEffectCommit 0;

	// Store the currently opened info panels so they can be reopened afterwards
	GVAR(ui_sm_panelLeft)  = (infoPanel "left") param [1, ""];
	GVAR(ui_sm_panelRight) = (infoPanel "right") param [1, ""];

	setInfoPanel ["left", "EmptyDisplay"];
	setInfoPanel ["right", "EmptyDisplay"];

	// Hide the HUD
	showHUD [false, false, false, false, false, false, false, false, false, false];

	// Disable the action menu
	inGameUISetEventHandler ["PrevAction", "true"];
	inGameUISetEventHandler ["NextAction", "true"];
	inGameUISetEventHandler ["Action", "true"];

	// Temporarily disable the ShackTac UI group HUD (if it exists)
	if (!isNil "STHUD_UIMode") then {
		GVAR(STHUD_UIMode) = STHUD_UIMode;
		STHUD_UIMode = 0;
	};

	if (
		[GVAR(side)] call FUNC(gm_isSidePlayable)
		and {GVAR(role) != MACRO_ENUM_ROLE_INVALID}
	) then {
		switch (GVAR(ui_sm_prevMenu)) do {
			case MACRO_IDC_SM_ROLE_FRAME:   {["ui_button_click", [MACRO_IDC_SM_ROLE_BUTTON]] call FUNC(ui_spawnMenu)};
			case MACRO_IDC_SM_DEPLOY_FRAME: {["ui_button_click", [MACRO_IDC_SM_DEPLOY_BUTTON]] call FUNC(ui_spawnMenu)};
			default                         {["ui_button_click", [MACRO_IDC_SM_SIDE_BUTTON]] call FUNC(ui_spawnMenu)};
		};
	} else {
		// Default to the side menu, forcing the player to pick a side
		["ui_button_click", [MACRO_IDC_SM_SIDE_BUTTON]] call FUNC(ui_spawnMenu);
	};

	// Set up the role rendertarget camera
	if (!GVAR(cam_role_isReady)) then {
		GVAR(cam_role_isReady) = true;

		GVAR(cam_role) cameraEffect ["Terminate", "BACK", QGVAR(tex_r2t_role)];
		camDestroy GVAR(cam_role);

		deleteVehicle GVAR(rt_role_wall);
		deleteVehicle GVAR(rt_role_unit);
		deleteVehicle GVAR(rt_role_light);

		GVAR(cam_role) = "camera" camCreate [0,0,0];
		GVAR(cam_role) setPosWorld [0,0,MACRO_SM_ROLEPREVIEW_BASEHEIGHTASL];
		GVAR(cam_role) setVectorDirAndUp [[0,-1,0], [0,0,1]];

		GVAR(rt_role_wall) = "Land_VR_Block_04_F" createVehicleLocal [0,0,0];
		GVAR(rt_role_wall) setPosWorld [0,-30,MACRO_SM_ROLEPREVIEW_BASEHEIGHTASL];
		GVAR(rt_role_wall) setVectorDirAndUp [[0,1,0], [0,0,1]];
		GVAR(rt_role_wall) setObjectTexture [0, "#(rgb,8,8,3)color(0.1,0.1,0.1,1)"];

		GVAR(rt_role_unit) = "C_man_1" createVehicleLocal [0,0,0];
		GVAR(rt_role_unit) allowDamage false;
		GVAR(rt_role_unit) attachTo [GVAR(rt_role_wall), [0,15,-1]];
		GVAR(rt_role_unit) setVectorDirAndUp [[0,1,0], [0,0,1]];
		GVAR(rt_role_unit) setDir MACRO_SM_ROLEPREVIEW_BASEDIRECTION;

		GVAR(rt_role_light) = "#lightpoint" createVehicleLocal [0,0,0];
		GVAR(rt_role_light) setPosWorld [2,-13,MACRO_SM_ROLEPREVIEW_BASEHEIGHTASL];
		GVAR(rt_role_light) setLightIntensity 3;
		GVAR(rt_role_light) setLightColor [250,150,100];
		GVAR(rt_role_light) setLightAmbient [20,30,50];
		GVAR(rt_role_light) setLightDayLight true;

		// Apply the player's face onto the unit
		GVAR(rt_role_unit) setFace face player;

		// Remove the preview unit's loadout
		removeAllWeapons GVAR(rt_role_unit);
		removeUniform    GVAR(rt_role_unit);
		removeVest       GVAR(rt_role_unit);
		removeBackpack   GVAR(rt_role_unit);
		removeHeadgear   GVAR(rt_role_unit);
		removeGoggles    GVAR(rt_role_unit);

		_spawnMenu setVariable [QGVAR(rolePreview_unitPosZ), -1];

	// Unhide the role rendertarget objects
	} else {
		GVAR(rt_role_wall) hideObject false;
		GVAR(rt_role_unit) hideObject (GVAR(role) == MACRO_ENUM_ROLE_INVALID); // Hide the unit until a valid role is selected
	};

	// Always (re)enable the camera effect, because switching to any other camera temporarily disables the r2t for some reason
	GVAR(cam_role) cameraEffect ["Internal", "BACK", QGVAR(tex_r2t_role)];
	GVAR(cam_role) camSetFov GVAR(cam_role_curFov);
	GVAR(cam_role) camCommit 0;

	// Add a keyDown EH to the spawn menu to detect key presses
	_spawnMenu displayAddEventHandler ["KeyDown", {["ui_key_down", _this] call FUNC(ui_spawnMenu)}];

	// Add an eachFrame EH to the mission to continuously update the active menu
	GVAR(ui_sm_EH_eachFrame) = addMissionEventHandler ["EachFrame", {

		if (isGamePaused) exitWith {};

		// Fetch the spawn menu
		private _spawnMenu = uiNamespace getVariable [QGVAR(RscSpawnMenu), displayNull];

		// Fetch some data from the spawn menu
		private _curMenu    = _spawnMenu getVariable [QGVAR(currentMenu), 0];
		private _nextUpdate = _spawnMenu getVariable [QGVAR(nextUpdateTime), -1];
		private _time = time;

		// Check if we're allowed to perform an action in this frame
		if (_time > _nextUpdate) then {

			// Update the contents of the currently open menu
			switch (_curMenu) do {
				case MACRO_IDC_SM_SIDE_FRAME: {
					["ui_update_side"] call FUNC(ui_spawnMenu);
				};

				case MACRO_IDC_SM_ROLE_FRAME: {
					["ui_update_role"] call FUNC(ui_spawnMenu);
				};

				case MACRO_IDC_SM_DEPLOY_FRAME: {
					["ui_update_deploy"] call FUNC(ui_spawnMenu);
				};
			};

			// Handle the availability of the role and deploy menu buttons
			private _ctrlButtonRole   = _spawnMenu displayCtrl MACRO_IDC_SM_ROLE_FRAME;
			private _ctrlButtonDeploy = _spawnMenu displayCtrl MACRO_IDC_SM_DEPLOY_FRAME;
			private _curMenu          = _spawnMenu getVariable [QGVAR(currentMenu), 0];
			private _isSideValid      = [GVAR(side)] call FUNC(gm_isSidePlayable) or {[player] call FUNC(unit_isAlive)};

			// Role menu
			if (_isSideValid) then {
				_ctrlButtonRole ctrlSetBackgroundColor ([SQUARE(MACRO_COLOUR_BUTTON_ACTIVE), SQUARE(MACRO_COLOUR_BUTTON_ACTIVE_PRESSED)] select (_curMenu == MACRO_IDC_SM_ROLE_FRAME));
			} else {
				_ctrlButtonRole ctrlSetBackgroundColor SQUARE(MACRO_COLOUR_BUTTON_INACTIVE);
			};

			// Deploy menu
			if (_isSideValid and {GVAR(role) != MACRO_ENUM_ROLE_INVALID}) then {
				_ctrlButtonDeploy ctrlSetBackgroundColor ([SQUARE(MACRO_COLOUR_BUTTON_ACTIVE), SQUARE(MACRO_COLOUR_BUTTON_ACTIVE_PRESSED)] select (_curMenu == MACRO_IDC_SM_DEPLOY_FRAME));
			} else {
				_ctrlButtonDeploy ctrlSetBackgroundColor SQUARE(MACRO_COLOUR_BUTTON_INACTIVE);
			};

			// Update the spawn button
			["ui_update_spawn"] call FUNC(ui_spawnMenu);

			_spawnMenu setVariable [QGVAR(nextUpdateTime), _time + MACRO_SM_MENU_UPDATEINTERVAL];
		};

		// Prevent the player from opening the map while the spawn menu is open
		if (visibleMap) then {
			openMap [false, false];
		};

		// Contuinously reset the focus, to prevent all possibilities of control groups being highlighted/hidden
		["ui_focus_reset"] call FUNC(ui_spawnMenu);
	}];

	// Draw the sector UI elements and the combat area on the deployment map
	private _ctrlMap = _spawnMenu displayCtrl MACRO_IDC_SM_DEPLOY_MAP;
	_ctrlMap setVariable [QGVAR(isSpawnMenu), true];
	_ctrlMap ctrlAddEventHandler ["Draw", FUNC(ui_drawSpawnSector)];
	_ctrlMap ctrlAddEventHandler ["Draw", FUNC(ui_drawUnitIcons2D)];
	_ctrlMap ctrlAddEventHandler ["Draw", FUNC(ui_drawSectorFlags)];
	_ctrlMap ctrlAddEventHandler ["Draw", FUNC(ui_drawSectorLocations)];
	_ctrlMap ctrlAddEventHandler ["Draw", FUNC(ui_drawCombatArea_map)];
};
