// Deployment menu
case "ui_update_deploy": {
	_eventExists = true;

	// Set up some constants
	private _C_vehicleIconsPerRow = 4;

	// Set up some variables
	private _playerSideValid = (GVAR(side) != sideEmpty);
	private _sectors = GVAR(allSectors) select {
		_x getVariable [QGVAR(side), sideEmpty] == GVAR(side)
		and {(_x getVariable [format [QGVAR(spawnPoints_%1), GVAR(side)], []]) isNotEqualTo []}
	};





	// Perform the initial setup (or redraw if the sectors array has changed)
	if (
		!(_spawnMenu getVariable [QGVAR(menuDeploy_isInit), false])
		or {_sectors isNotEqualTo (_spawnMenu getVariable [QGVAR(menuDeploy_sectorsPrev), []])}
	) then {
		_spawnMenu setVariable [QGVAR(menuDeploy_isInit), true];
		_spawnMenu setVariable [QGVAR(menuDeploy_sectorsPrev), _sectors];

		// Set up some variables
		private _ctrls = [];
		private _ctrlGrp = _spawnMenu displayCtrl MACRO_IDC_SM_DEPLOY_SECTORS_CTRLGROUP;

		// Delete the previous controls
		{
			ctrlDelete _x;
		} forEach (_spawnMenu getVariable [QGVAR(menuDeploy_ctrls), []]);

		// Only continue if the player has joined a side
		if (_playerSideValid) then {

			private _sideIndex = GVAR(sides) find GVAR(side);
			private _pixelW = pixelW;
			private _pixelH = pixelH;
			private _safeZoneW = safeZoneW;
			private _safeZoneH = safeZoneH;
			private _pos = ctrlPosition _ctrlGrp;
			private _originX = _pos # 0 + _pixelW * MACRO_POS_SPACER_X;
			private _originY = _pos # 1 + _pixelH * MACRO_POS_SPACER_Y;
			private _width = _pos # 2 - _pixelW * (MACRO_POS_SPACER_X * 2 + 1);
			private _cfgVehicles = configFile >> "CfgVehicles";
			private ["_vehIcons", "_typeX", "_iconX", "_iconPlaneX", "_vehicleRows", "_height"];
			private ["_ctrlBackground", "_ctrlSideFlag", "_ctrlSideFlagGradient", "_ctrlHeader", "_ctrlSectorName", "_ctrlSectorLock", "_vehicleIconCtrls", "_ctrlVehIconX", "_ctrlOutline", "_ctrlButton", "_sectorCtrls"];

			// Iterate over all owned sectors
			{
				// Fetch the sector's list of vehicle spawns
				_vehIcons = [];
				{
					_typeX = _x param [_sideIndex, ""];

					if (_typeX != "") then {
						_iconX = getText (_cfgVehicles >> _typeX >> "picture");
						_iconPlaneX = getText (_cfgVehicles >> _typeX >> "icon");

						if (_typeX isKindOf "Plane" and {_iconPlaneX != ""}) then {
							_iconX = _iconPlaneX;
						};

						if (_iconX != "") then {
							_vehIcons pushBack _iconX;
						};
					};
				} forEach (_x getVariable [QGVAR(vehicleTypes), []]);

				// Determine the required size of this sector's control
				_vehicleRows = 3 max ceil ((count _vehIcons) / _C_vehicleIconsPerRow);
				_height = _safeZoneH * (0.03 + _pixelH * MACRO_POS_SPACER_Y + MACRO_POS_SM_DEPLOY_VEHICLEICON_HEIGHT * _vehicleRows);

				// Create the controls
					// ------------------------------------------------------------------------------------------------------------------------------------------------
					// Background
					_ctrlBackground = _spawnMenu ctrlCreate [QGVAR(RscFrame), -1, _ctrlGrp];
					_ctrlBackground ctrlSetPosition [
						_originX,
						_originY,
						_width,
						_height
					];
					_ctrlBackground ctrlSetBackgroundColor SQUARE(MACRO_COLOUR_A100_BLACK);

					// ------------------------------------------------------------------------------------------------------------------------------------------------
					// Side Flag
					_ctrlSideFlag = _spawnMenu ctrlCreate [QGVAR(RscPictureNoAR), -1, _ctrlGrp];
					_ctrlSideFlag ctrlSetPosition [
						_originX,
						_originY + _safeZoneH * 0.03 - _pixelH,
						_width * 0.5,
					 	_height - _safeZoneH * 0.03
					];
					_ctrlSideFlag ctrlSetTextColor SQUARE(MACRO_COLOUR_A50_WHITE);

					// ------------------------------------------------------------------------------------------------------------------------------------------------
					// Side Flag Gradient
					_ctrlSideFlagGradient = _spawnMenu ctrlCreate [QGVAR(RscPictureNoAR), -1, _ctrlGrp];
					_ctrlSideFlagGradient ctrlSetPosition [
						_originX + _width * 0.25,
						_originY + _safeZoneH * 0.03 - _pixelH,
						_width * 0.25,
					 	_height - _safeZoneH * 0.03
					];
					_ctrlSideFlagGradient ctrlSetText "a3\ui_f\data\GUI\RscCommon\RscBackgroundGUI\gradient_right_gs.paa";
					_ctrlSideFlagGradient ctrlSetTextColor SQUARE(MACRO_COLOUR_A100_BLACK);

					// ------------------------------------------------------------------------------------------------------------------------------------------------
					// Header
					_ctrlHeader = _spawnMenu ctrlCreate [QGVAR(RscFrame), -1, _ctrlGrp];
					_ctrlHeader ctrlSetPosition [
						_originX,
						_originY,
						_width,
					 	_safeZoneH * 0.03
					];
					_ctrlHeader ctrlSetText (_x getVariable [QGVAR(letter), "???"]);

					// ------------------------------------------------------------------------------------------------------------------------------------------------
					// Sector Name
					_ctrlSectorName = _spawnMenu ctrlCreate [QGVAR(RscTextHeader), -1, _ctrlGrp];
					_ctrlSectorName ctrlSetPosition [
						_originX + _width * 0.1,
						_originY,
						_width * 0.8,
					 	_safeZoneH * 0.03
					];
					_ctrlSectorName ctrlSetText toUpper (_x getVariable [QGVAR(name), "???"]);
					_ctrlSectorName ctrlSetFontHeight (0.02 * _safeZoneW);

					// ------------------------------------------------------------------------------------------------------------------------------------------------
					// Locked Icon
					if (_x getVariable [QGVAR(isLocked), false]) then {
						_ctrlSectorLock = _spawnMenu ctrlCreate [QGVAR(RscPicture), -1, _ctrlGrp];
						_ctrlSectorLock ctrlSetPosition [
							_originX + _width * 0.95,
							_originY + _safeZoneH * 0.005,
							_width * 0.05,
						 	_safeZoneH * 0.02
						];
						_ctrlSectorLock ctrlSetText getMissionPath "res\images\sector_locked_full.paa";
						_ctrlSectorLock ctrlSetTextColor SQUARE(MACRO_COLOUR_SECTOR_LOCKED);
					} else {
						_ctrlSectorLock = controlNull;
					};

					// ------------------------------------------------------------------------------------------------------------------------------------------------
					// Vehicle icons
					_vehicleIconCtrls = [];
					{
						_ctrlVehIconX = _spawnMenu ctrlCreate [QGVAR(RscPicture), -1, _ctrlGrp];
						_ctrlVehIconX ctrlSetPosition [
							_originX + _width * (1 - ((_forEachIndex mod _C_vehicleIconsPerRow) + 1) / (_C_vehicleIconsPerRow * 2)),
							_originY + _safeZoneH * (0.03 + MACRO_POS_SM_DEPLOY_VEHICLEICON_HEIGHT * floor (_forEachIndex / _C_vehicleIconsPerRow)),
							_width * (0.5 / _C_vehicleIconsPerRow) - _pixelW * MACRO_POS_SPACER_X,
							_safeZoneH * MACRO_POS_SM_DEPLOY_VEHICLEICON_HEIGHT
						];
						_ctrlVehIconX ctrlSetText _x;

						_vehicleIconCtrls pushBack _ctrlVehIconX;
					} forEach _vehIcons;

					// ------------------------------------------------------------------------------------------------------------------------------------------------
					// Outline
					_ctrlOutline = _spawnMenu ctrlCreate [QGVAR(RscOutline), -1, _ctrlGrp];
					_ctrlOutline ctrlSetPosition [
						_originX,
						_originY,
						_width,
						_height
					];

					// ------------------------------------------------------------------------------------------------------------------------------------------------
					// Button
					_ctrlButton = _spawnMenu ctrlCreate [QGVAR(RscFrameFocused), MACRO_IDC_SM_DEPLOY_SECTOR_START + _forEachIndex, _ctrlGrp];
					_ctrlButton ctrlSetPosition [
						_originX,
						_originY,
						_width,
						_height
					];
					_ctrlButton ctrlSetBackgroundColor SQUARE(MACRO_COLOUR_A0);
					_ctrlButton ctrlAddEventHandler ["MouseButtonDown", {["ui_button_click", _this] call FUNC(ui_spawnMenu)}];
					_ctrlButton ctrlAddEventHandler ["MouseButtonDblClick", {["ui_focus_reset", _this] call FUNC(ui_spawnMenu)}];

				// Append the new controls to the total list - NOTE: The order of the sector controls must match with the "update" pass, further below!
				_sectorCtrls = [
					_ctrlBackground,
					_ctrlSideFlag,
					_ctrlSideFlagGradient,
					_ctrlHeader,
					_ctrlSectorName,
					_ctrlSectorLock,
					_ctrlOutline
				];
				_ctrls append ([_ctrlButton] + _sectorCtrls + _vehicleIconCtrls);

				// Save the arrays of controls onto the button control
				_ctrlButton setVariable [QGVAR(sectorCtrls), _sectorCtrls];
				_ctrlButton setVariable [QGVAR(vehicleIconCtrls), _vehicleIconCtrls];
				_ctrlButton setVariable [QGVAR(sector), _x];

				// Increase the origin on the Y axis
				_originY = _originY + _height + _pixelH * MACRO_POS_SPACER_Y;

			} forEach _sectors;

			// Move all newly created controls into place
			{
				_x ctrlCommit 0;
			} forEach _ctrls;
		};

		// Save the new controls
		_spawnMenu setVariable [QGVAR(menuDeploy_ctrls), _ctrls];
	};

	// Perform the initial setup (or redraw if the sectors array has changed)
	if !(_spawnMenu getVariable [QGVAR(menu_isOpen), false]) then {
		_spawnMenu setVariable [QGVAR(menu_isOpen), true];

		// Focus the map
		[_spawnMenu displayCtrl MACRO_IDC_SM_DEPLOY_MAP, MACRO_UI_MAPFOCUS_PADDING_SM] call FUNC(ui_focusMap);
	};



	if (_playerSideValid) then {

		// Update the sector controls
		private _groupPly = group player;
		private ["_IDC", "_activeVehicles", "_ctrlButton", "_vehicleIconCtrls", "_vehX", "_driverX"];
		{
			_isSelected = (GVAR(spawnSector) == _x);
			_IDC = _forEachIndex + MACRO_IDC_SM_DEPLOY_SECTOR_START;
			_activeVehicles = _x getVariable [QGVAR(activeVehicles), []];

			// Fetch our controls
			_ctrlButton = _spawnMenu displayCtrl _IDC;
			_vehicleIconCtrls = _ctrlButton getVariable [QGVAR(vehicleIconCtrls), []];
			(_ctrlButton getVariable [QGVAR(sectorCtrls), []]) params [
				"_ctrlBackground",
				"_ctrlSideFlag",
				"_ctrlSideFlagGradient",
				"_ctrlHeader"
			];

			// Update the flag texture
			_ctrlSideFlag ctrlSetText ([GVAR(side)] call FUNC(gm_getFlagTexture));
			_ctrlSideFlag ctrlSetTextColor ([SQUARE(MACRO_COLOUR_A25_WHITE), SQUARE(MACRO_COLOUR_A100_WHITE)] select _isSelected);

			// Update the colour of the header
			_ctrlHeader ctrlSetBackgroundColor ([SQUARE(MACRO_COLOUR_BUTTON_ACTIVE), SQUARE(MACRO_COLOUR_BUTTON_ACTIVE_PRESSED)] select _isSelected);

			// Update the sector's vehicle icons
			{
				_vehX = _activeVehicles param [_forEachIndex, objNull];

				if (alive _vehX and {GVAR(side) == (_vehX getVariable [QGVAR(side), sideEmpty])}) then {
					_driverX = driver _vehX;

					if (lifestate _driverX isEqualTo "HEALTHY") then {
						if (group _driverX == _groupPly) then {
							_x ctrlSetTextColor SQUARE(MACRO_COLOUR_A100_SQUAD);
						} else {
							_x ctrlSetTextColor SQUARE(MACRO_COLOUR_A100_FRIENDLY);
						};
					} else {
						_x ctrlSetTextColor SQUARE(MACRO_COLOUR_A100_WHITE);
					};
				} else {
					_x ctrlSetTextColor SQUARE(MACRO_COLOUR_A100_GREY);
				};
			} forEach _vehicleIconCtrls;
		} forEach _sectors;
	};
};
