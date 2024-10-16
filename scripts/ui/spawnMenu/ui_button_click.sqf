// A UI button was clicked
case "ui_button_click": {
	_eventExists = true;

	_args params [
		["_ctrlIn", controlNull, [controlNull, -1]],	// can either be a control or an IDC
		["_button", 0],
		["_mouseX", 0],
		["_mouseY", 0]
	];

	// Validate the input
	private ["_ctrl", "_IDC"];
	if (_ctrlIn isEqualType -1) then {
		_IDC = _ctrlIn;
		_ctrl = _spawnMenu displayCtrl _IDC;
	} else {
		_ctrl = _ctrlIn;
		_IDC = ctrlIDC _ctrl;
	};

	// Set up some variables
	private _player   = player;
	private _groupPly = group _player;
	private _alive    = [_player, true] call FUNC(unit_isAlive);
	private _curMenu  = _spawnMenu getVariable [QGVAR(currentMenu), 0];// We use the menu buttons' frame IDCs to identify the menu - 0 is the control group, but this shouldn't interfere with anything
	private _newMenu  = _curMenu;
	private _newSide  = GVAR(side);
	private _newSpawn = GVAR(spawnSector);
	private _newRole  = GVAR(ui_sm_role);
	private _clickedOnRolePreview = false;





	// Decide what to do based on the button that was pressed
	switch (_IDC) do {

		// Menus
		case MACRO_IDC_SM_SIDE_BUTTON:   {_newMenu = MACRO_IDC_SM_SIDE_FRAME};
		case MACRO_IDC_SM_ROLE_BUTTON:   {_newMenu = MACRO_IDC_SM_ROLE_FRAME};
		case MACRO_IDC_SM_DEPLOY_BUTTON: {_newMenu = MACRO_IDC_SM_DEPLOY_FRAME};

		// Side menu
		case MACRO_IDC_SM_SIDE_JOIN_LEFT_BUTTON:   {_newSide = east};
		case MACRO_IDC_SM_SIDE_JOIN_MIDDLE_BUTTON: {_newSide = resistance};
		case MACRO_IDC_SM_SIDE_JOIN_RIGHT_BUTTON:  {_newSide = west};

		// Role Preview Frame
		//case MACRO_IDC_SM_ROLE_PREVIEW_FRAME: {_clickedOnRolePreview = (_button == 1)}; // Only consider right clicks
		case MACRO_IDC_SM_ROLE_PREVIEW_FRAME:   {_clickedOnRolePreview = true};	 // Consider all clicks

		// Roles
		case MACRO_IDC_SM_ROLE_SPECOPS_BUTTON:  {_newRole = MACRO_ENUM_ROLE_SPECOPS};
		case MACRO_IDC_SM_ROLE_SNIPER_BUTTON:   {_newRole = MACRO_ENUM_ROLE_SNIPER};
		case MACRO_IDC_SM_ROLE_ASSAULT_BUTTON:  {_newRole = MACRO_ENUM_ROLE_ASSAULT};
		case MACRO_IDC_SM_ROLE_SUPPORT_BUTTON:  {_newRole = MACRO_ENUM_ROLE_SUPPORT};
		case MACRO_IDC_SM_ROLE_ENGINEER_BUTTON: {_newRole = MACRO_ENUM_ROLE_ENGINEER};
		case MACRO_IDC_SM_ROLE_MEDIC_BUTTON:    {_newRole = MACRO_ENUM_ROLE_MEDIC};
		case MACRO_IDC_SM_ROLE_ANTITANK_BUTTON: {_newRole = MACRO_ENUM_ROLE_ANTITANK};

		// Groups
		case MACRO_IDC_SM_GROUP_JOIN_BUTTON: {

			private _selectedGroup = _spawnMenu getVariable [QGVAR(menuRole_selectedGroup), grpNull];

			// Check if we can switch groups
			if (!isNull _selectedGroup and {_selectedGroup != _groupPly}) then {
				[_player] joinSilent _selectedGroup;
				[_groupPly] remoteExecCall ["deleteGroup", 0, false];

				_spawnMenu setVariable [QGVAR(menuRole_isNamingGroup), false];

				["ui_update_role"] call FUNC(ui_spawnMenu);
			};
		};
		case MACRO_IDC_SM_GROUP_CREATE_BUTTON: {

			// Check if the player is currently naming a new group
			if (_spawnMenu getVariable [QGVAR(menuRole_isNamingGroup), false]) then {
				_buffer = _spawnMenu getVariable [QGVAR(menuRole_textBuffer), ""];

				// Submit the new callsign
				MACRO_FNC_SUBMITNEWCALLSIGN(_groupPly,_buffer);

				["ui_update_role"] call FUNC(ui_spawnMenu);
			} else {
				// Only allow leaving if the current group isn't valid -> player is "ungrouped"
				if (!MACRO_COND_ISVALIDGROUP(_groupPly)) then {

					// First, leave the current group
					["ui_button_click", MACRO_IDC_SM_GROUP_LEAVE_BUTTON] call FUNC(ui_spawnMenu);

					// Then, mark the new group as valid
					_groupPly setVariable [QGVAR(isValid), true, true];

					// Set a flag to detect that we are awaiting a character stream
					_spawnMenu setVariable [QGVAR(menuRole_isNamingGroup), true];

					// Reset the group name buffer and error flag
					_spawnMenu setVariable [QGVAR(menuRole_textBuffer), ""];
					_spawnMenu setVariable [QGVAR(menuRole_hasNameCollision), false];

					// Finally, select the new group
					_spawnMenu setVariable [QGVAR(menuRole_selectedGroup), _groupPly];
					["ui_update_role", [false, true]] call FUNC(ui_spawnMenu);
				};
			};
		};
		case MACRO_IDC_SM_GROUP_LEAVE_BUTTON: {

			// Check if we can switch groups
			if MACRO_COND_ISVALIDGROUP(_groupPly) then {
				MACRO_FNC_LEAVEGROUP(_groupPly);
			};

			_spawnMenu setVariable [QGVAR(menuRole_isNamingGroup), false];

			["ui_update_role"] call FUNC(ui_spawnMenu);
		};

		// Spawn
		case MACRO_IDC_SM_SPAWN_BUTTON: {

			if (
				GVAR(side) != sideEmpty
				and {GVAR(role) != MACRO_ENUM_ROLE_INVALID}
				and {GVAR(side) == GVAR(spawnSector) getVariable [QGVAR(side), sideEmpty]}
			) then {
				// Tell the respawn handler that the player is ready
				GVAR(gm_sys_handlePlayerRespawn_spawnRequested) = true;

				["ui_close", true] call FUNC(ui_spawnMenu);
			} else {
				["ui_update_spawn"] call FUNC(ui_spawnMenu);
			};
		};

		// Deploy map
		case MACRO_IDC_SM_DEPLOY_MAP: {
			private _ctrlMap = _spawnMenu displayCtrl _IDC;
			private _minDist = 9e9;
			private _maxDist = 0.1 ^ 2; // in UI size
			private ["_posX", "_distX"];

			// Enable spawn sector selection by clicking on the map
			{
				_posX  = _ctrlMap ctrlMapWorldToScreen getPosWorld _x;
				_distX = _posX distanceSqr [_mouseX, _mouseY];

				if (_distX < _minDist and {_distX < _maxDist}) then {
					_minDist  = _distX;
					_newSpawn = _x;
				};
			} forEach (GVAR(allSectors) select {
				_x getVariable [QGVAR(side), sideEmpty] == GVAR(side)
				and {(_x getVariable [format [QGVAR(spawnPoints_%1), GVAR(side)], []]) isNotEqualTo []}
			});
		};

		// Special cases
		default {

			// Spawn sector
			if (_curMenu == MACRO_IDC_SM_DEPLOY_FRAME) then {
				if (_IDC >= MACRO_IDC_SM_DEPLOY_SECTOR_START) then {
					_newSpawn = _ctrl getVariable [QGVAR(sector), objNull];
				};
			};
		};
	};





	// Check if a different menu should be opened
	private _curSidePlayable = [GVAR(side)] call FUNC(gm_isSidePlayable);
	private _shouldChangeMenu = (_newMenu != _curMenu) and {
		switch (_newMenu) do {
			case MACRO_IDC_SM_ROLE_FRAME:   {_alive or {_curSidePlayable}};
			case MACRO_IDC_SM_DEPLOY_FRAME: {GVAR(role) != MACRO_ENUM_ROLE_INVALID and {_alive or {_curSidePlayable}}};
			default {true} // Side menu; must be allowed at all times
		}
	};
	if (_shouldChangeMenu) then {

		// Update the colour of the previous and the new menu frame controls
		(_spawnMenu displayCtrl _curMenu) ctrlSetBackgroundColor SQUARE(MACRO_COLOUR_BUTTON_ACTIVE);
		(_spawnMenu displayCtrl _newMenu) ctrlSetBackgroundColor SQUARE(MACRO_COLOUR_BUTTON_ACTIVE_PRESSED);

		// Save the new menu onto the spawn menu
		_spawnMenu setVariable [QGVAR(currentMenu), _newMenu];

		// Hide all menu controls group
		(_spawnMenu displayCtrl MACRO_IDC_SM_SIDE_CTRLGROUP) ctrlShow false;
		(_spawnMenu displayCtrl MACRO_IDC_SM_ROLE_CTRLGROUP) ctrlShow false;
		(_spawnMenu displayCtrl MACRO_IDC_SM_DEPLOY_CTRLGROUP) ctrlShow false;

		// Mark the menu as no longer being open (allows the respective update event to hide/reset its controls)
		_spawnMenu setVariable [QGVAR(menu_isOpen), false];


		// Show the requested menu's controls group
		switch (_newMenu) do {
			case MACRO_IDC_SM_SIDE_FRAME: {
				(_spawnMenu displayCtrl MACRO_IDC_SM_SIDE_CTRLGROUP) ctrlShow true;
				["ui_update_side"] call FUNC(ui_spawnMenu);
			};
			case MACRO_IDC_SM_ROLE_FRAME: {
				(_spawnMenu displayCtrl MACRO_IDC_SM_ROLE_CTRLGROUP) ctrlShow true;
				["ui_update_role"] call FUNC(ui_spawnMenu);
			};
			case MACRO_IDC_SM_DEPLOY_FRAME: {
				(_spawnMenu displayCtrl MACRO_IDC_SM_DEPLOY_CTRLGROUP) ctrlShow true;
				["ui_update_deploy"] call FUNC(ui_spawnMenu);
			};
		};

		// Handle the deployment map's visibility
		(_spawnMenu displayCtrl MACRO_IDC_SM_DEPLOY_MAP) ctrlShow (_newMenu == MACRO_IDC_SM_DEPLOY_FRAME);

		// End the group naming process (if it is currently active)
		_spawnMenu setVariable [QGVAR(menuRole_isNamingGroup), false];

		// Reset the eachFrame update time to match the new menu
		_spawnMenu setVariable [QGVAR(nextUpdateTime), 0];
	};

	// Check if the player wants to switch team
	if (
		_newSide != GVAR(side)
		and {!_alive}
		and {[_newSide] call FUNC(gm_isSidePlayable)}
	) then {
		GVAR(side) = _newSide;

		// Leave the group
		MACRO_FNC_LEAVEGROUP(_groupPly);

		["ui_update_side"] call FUNC(ui_spawnMenu);

		// Reset the eachFrame update time to match the new menu
		_spawnMenu setVariable [QGVAR(nextUpdateTime), 0];

		// Reset the role and deploy menus' init variables, as the loadouts and sectors must be updated
		_spawnMenu setVariable [QGVAR(menuRole_isInit), false];
		_spawnMenu setVariable [QGVAR(menuDeploy_isInit), false];

		// Switch to the role menu
		//["ui_button_click", [_spawnMenu displayCtrl MACRO_IDC_SM_ROLE_BUTTON]] call FUNC(ui_spawnMenu);
		//playSound3D ["a3\ui_f\data\Sound\CfgNotifications\addItemOK.wss", player];
		//playSound3D ["a3\ui_f\data\Sound\CfgNotifications\TacticalPing2.wss", player];
		//playSound3D ["a3\ui_f\data\Sound\CfgNotifications\TacticalPing3.wss", player];
	};

	// Check if the player selected a new role
	if (_newRole != GVAR(ui_sm_role)) then {

		GVAR(ui_sm_role) = _newRole;
		if (!_alive) then {
			GVAR(role) = GVAR(ui_sm_role);
		};

		// Update the selected role
		["ui_update_role", [true]] call FUNC(ui_spawnMenu);
	};

	// Check if the player clicked on the role preview control
	if (_clickedOnRolePreview) then {

		// Remember the current mouse position, unit height and direction
		_spawnMenu setVariable [QGVAR(rolePreview_isMouseMoving), true];
		_spawnMenu setVariable [QGVAR(rolePreview_unitPosZBase), _spawnMenu getVariable [QGVAR(rolePreview_unitPosZ), 0]];
		_spawnMenu setVariable [QGVAR(rolePreview_unitDir), direction GVAR(rt_role_unit)];
		_spawnMenu setVariable [QGVAR(rolePreview_mouseX), _mouseX];
		_spawnMenu setVariable [QGVAR(rolePreview_mouseY), _mouseY];

		// Attach an EH to the display to detect the mouse button being released
		private _EH = _spawnMenu displayAddEventHandler ["MouseButtonUp", {
			params ["_spawnMenu", "_button"];

			// Only consider the right mouse button
			//if (_button == 1) then {
				_spawnMenu setVariable [QGVAR(rolePreview_isMouseMoving), false];
				_spawnMenu displayRemoveEventHandler ["MouseButtonUp", _spawnMenu getVariable [QGVAR(EH_mouseButtonUp_rolePreview), -1]];
			//};
		}];
		_spawnMenu setVariable [QGVAR(EH_mouseButtonUp_rolePreview), _EH];
	};

	// Check if the player selected a new spawn sector
	if (_newSpawn != GVAR(spawnSector)) then {
		GVAR(spawnSector) = _newSpawn;

		// Update the selected sector
		["ui_update_deploy"] call FUNC(ui_spawnMenu);
		["ui_update_spawn"] call FUNC(ui_spawnMenu);
	};

	// Reset the focus
	["ui_focus_reset"] call FUNC(ui_spawnMenu);
};
