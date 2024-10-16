// Key down
case "ui_key_down": {
	_eventExists = true;

	_args params ["", "_key", "_shift", "_ctrl", "_alt"];

	// Set up some variables
	private _curMenu = _spawnMenu getVariable [QGVAR(currentMenu), 0];
	private _isNamingGroup = _spawnMenu getVariable [QGVAR(menuRole_isNamingGroup), false];




	// If the player is currently naming their new group...
	if (_isNamingGroup) then {
		_spawnMenu_return = false;

		private _keyIsValid = false;
		private _buffer = _spawnMenu getVariable [QGVAR(menuRole_textBuffer), ""];

		// ...determine what to do based on the key that was pressed
		switch (_key) do {

			// Backspace
			case 14: {
				_keyIsValid = true;
				_spawnMenu setVariable [QGVAR(menuRole_textBuffer), _buffer select [0, count _buffer - 1]];

				// Remove the group name error (if it was on)
					_spawnMenu setVariable [QGVAR(menuRole_hasNameCollision), false];
			};

			// Enter
			case 28;
			case 156: {
				_keyIsValid = true;

				// Submit the new callsign
				MACRO_FNC_SUBMITNEWCALLSIGN(group player,_buffer);
			};
		};

		// If a valid key was detected, update the role UI
		if (_keyIsValid) then {
			["ui_update_role"] call FUNC(ui_spawnMenu);
			_spawnMenu_return = true;
		};

	} else {

		// If the enter key was pressed, simulate clicking the "Spawn" button
		if (_key == 28 or {_key == 156}) then {
			["ui_button_click", MACRO_IDC_SM_SPAWN_BUTTON] call FUNC(ui_spawnMenu);
		};

		// If the night vision key was pressed...
		if (_key in actionKeys "nightvision") then {

			// ...and the role menu is currently active...
			if (_curMenu == MACRO_IDC_SM_ROLE_FRAME) then {

				// ...change the camera's vision mode
				GVAR(cam_role_useNVG) = !GVAR(cam_role_useNVG);
				QGVAR(tex_r2t_role) setPipEffect [([0,1] select GVAR(cam_role_useNVG))];
			};
		};
	};

};
