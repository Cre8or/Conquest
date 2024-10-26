case "ui_lbselection_changed": {
	_eventExists = true;

	_args params [
		["_ctrl", controlNull, [controlNull, 0]],
		["_selectedIndex", 0, [0, ""]]
	];

	scopeName QGVAR(ui_scoreBoard_lbselection_changed);

	// If a number was provided, consider it as an IDC and fetch the associated control
	if (_ctrl isEqualType 0) then {
		_ctrl = _selectionMenu displayCtrl _ctrl;
	};

	// If a UID string was passed as index, figure out where it belongs
	if (_selectedIndex isEqualType "") then {
		private _UID = _selectedIndex;

		_selectedIndex = -1;

		if (_UID == "") then {
			breakTo QGVAR(ui_scoreBoard_lbselection_changed);
		};

		private ["_ctrlX", "_sizeX", "_UIDX"];
		{
			_ctrlX = _scoreBoard displayCtrl _x;
			_sizeX = (lnbSize _ctrlX) # 0;

			for "_i" from 0 to _sizeX do {
				_UIDX = _ctrlX lnbData [_i, 1];

				if (_UID == _UIDX) then {
					_ctrl          = _ctrlX;
					_selectedIndex = _i;
					breakTo QGVAR(ui_scoreBoard_lbselection_changed);
				};
			};
		} forEach [
			MACRO_IDC_SB_PLAYERS_LEFT_LISTBOX,
			MACRO_IDC_SB_PLAYERS_MIDDLE_LISTBOX,
			MACRO_IDC_SB_PLAYERS_RIGHT_LISTBOX
		];
	};

	// Set up some variables
	GVAR(ui_scoreBoard_sides) params [["_sideLeft", sideEmpty], ["_sideMiddle", sideEmpty], ["_sideRight", sideEmpty]];
	private _selectedSide = sideEmpty;
	private _ctrlGroupIDC = -1;





	// Determine which button was pressed
	switch (ctrlIDC _ctrl) do {

		// Unit listboxes
		case MACRO_IDC_SB_PLAYERS_LEFT_LISTBOX: {
			_selectedSide = _sideLeft;
			_ctrlGroupIDC = MACRO_IDC_SB_PLAYERS_LEFT_CTRGROUP;
		};
		case MACRO_IDC_SB_PLAYERS_MIDDLE_LISTBOX: {
			_selectedSide = _sideMiddle;
			_ctrlGroupIDC = MACRO_IDC_SB_PLAYERS_MIDDLE_CTRGROUP;
		};
		case MACRO_IDC_SB_PLAYERS_RIGHT_LISTBOX: {
			_selectedSide = _sideRight;
			_ctrlGroupIDC = MACRO_IDC_SB_PLAYERS_RIGHT_CTRGROUP;
		};

		default {};
	};





	if (_selectedIndex >= 0) then {
		private _UID = _ctrl lnbData [_selectedIndex, 1];

		if (_UID == "") then {
			if (_selectedSide == GVAR(ui_scoreBoard_selectedSide)) then {
				private _prevIndex = _ctrl getVariable [QGVAR(prevSelectedIndex), -1];
				_ctrl lnbSetCurSelRow _prevIndex;

				["ui_update"] call FUNC(ui_scoreBoard);
			};

		} else {

			if (_UID != GVAR(ui_scoreBoard_selectedUID)) then {
				GVAR(ui_scoreBoard_selectedUID)  = _UID;
				GVAR(ui_scoreBoard_selectedSide) = _selectedSide;

				_ctrl setVariable [QGVAR(prevSelectedIndex), _selectedIndex];

				// Update the listboxes
				["ui_update"] call FUNC(ui_scoreBoard);
			};
		};

		// Ensure the selected row is visible by setting the scroll values
		private _ctrlGroup = _scoreBoard displayCtrl _ctrlGroupIDC;

		private _heightTotal   = (ctrlPosition _ctrl) # 3;
		private _heightOutside = _heightTotal - MACRO_POS_SB_LISTBOX_HEIGHT;

		private _scrollY = (ctrlScrollValues _ctrlGroup) # 0;
		private _minY    = _heightOutside * _scrollY;
		private _maxY    = _minY + MACRO_POS_SB_LISTBOX_HEIGHT - MACRO_POS_SB_LISTBOX_TEXTSIZE;
		private _targetY = _selectedIndex * MACRO_POS_SB_LISTBOX_TEXTSIZE * 1.01;

		//systemChat format ["(%1) scrollY %2 - pos: %3 - range: %4 .. %5", time, _scrollY, _targetY, _minY, _maxY];

		// The selected row is outside of the visible area; adjust the scroll position
		if (_targetY < _minY or {_targetY > _maxY}) then {

			if (_targetY < _minY) then {
				_scrollY = _targetY / _heightOutside;
			} else {
			 	_scrollY = _targetY / (_heightTotal + _heightOutside + MACRO_POS_SB_LISTBOX_TEXTSIZE);
			};

			//systemChat format ["New scrollY: %1", _scrollY];
			_ctrlGroup ctrlSetScrollValues [_scrollY, 0];
		};
	};
};
