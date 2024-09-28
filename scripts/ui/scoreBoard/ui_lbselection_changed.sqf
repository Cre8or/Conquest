case "ui_lbselection_changed": {
	_eventExists = true;

	_args params [
		["_ctrl", controlNull, [controlNull, 0]],
		["_selectedIndex", 0, [0]]
	];

	// If a number was provided, consider it as an IDC and fetch the associated control
	if (_ctrl isEqualType 0) then {
		_ctrl = _selectionMenu displayCtrl _ctrl;
	};

	// Set up some variables
	GVAR(ui_scoreBoard_sides) params [["_sideLeft", sideEmpty], ["_sideMiddle", sideEmpty], ["_sideRight", sideEmpty]];
	private _selectedUIDChanged = false;
	private _selectedSide       = sideEmpty;





	// Determine which button was pressed
	switch (ctrlIDC _ctrl) do {

		// Unit listboxes
		case MACRO_IDC_SB_SIDE_PLAYERS_LEFT_LISTBOX: {
			_selectedUIDChanged = true;
			_selectedSide       = _sideLeft;
		};
		case MACRO_IDC_SB_SIDE_PLAYERS_MIDDLE_LISTBOX: {
			_selectedUIDChanged = true;
			_selectedSide       = _sideMiddle;
		};
		case MACRO_IDC_SB_SIDE_PLAYERS_RIGHT_LISTBOX: {
			_selectedUIDChanged = true;
			_selectedSide       = _sideRight;
		};

		default {};
	};





	if (_selectedUIDChanged and {_selectedIndex >= 0}) then {
		private _UID = _ctrl lnbData [_selectedIndex, 1];

		if (_UID == "") then {
			if (_selectedSide == GVAR(ui_scoreBoard_selectedSide)) then {
				private _prevIndex = _ctrl getVariable [QGVAR(prevSelectedIndex), -1];
				_ctrl lnbSetCurSelRow _prevIndex;

				//systemchat format ["Reselecting previous index %1", _prevIndex];

				["ui_update"] call FUNC(ui_scoreBoard);
			};

		} else {

			if (_UID != GVAR(ui_scoreBoard_selectedUID)) then {
				GVAR(ui_scoreBoard_selectedUID)  = _UID;
				GVAR(ui_scoreBoard_selectedSide) = _selectedSide;

				_ctrl setVariable [QGVAR(prevSelectedIndex), _selectedIndex];

				//systemchat format ["Selected %1 (%2)", _selectedIndex, _UID];

				// Update the listboxes
				["ui_update"] call FUNC(ui_scoreBoard);
			};
		};
	};
};
