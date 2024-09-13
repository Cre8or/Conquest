// Update the side menu
case "ui_update_side": {
	_eventExists = true;

	// Order of sides is hardcoded and must always be the same
	private _sideLeft   = east;
	private _sideMiddle = resistance;
	private _sideRight  = west;

	private _ticketBleedLeft   = GVAR(ticketBleedEast);
	private _ticketBleedMiddle = GVAR(ticketBleedResistance);
	private _ticketBleedRight  = GVAR(ticketBleedWest);

	// On a two-sides setup, swap the panels around such that the middle one remains free
	private _indexEmpty = GVAR(sides) find sideEmpty;
	if (_indexEmpty >= 0) then {

		switch (_indexEmpty) do {
			case 0: {
				_ticketBleedLeft = _ticketBleedMiddle;
				_sideLeft        = _sideMiddle;
			};
			case 2: {
				_ticketBleedRight = _ticketBleedMiddle;
				_sideRight        = _sideMiddle;
			};
		};
		_sideMiddle = sideEmpty;
	};

	// Initial setup
	if !(_spawnMenu getVariable [QGVAR(menuSide_isInit), false]) then {
		_spawnMenu setVariable [QGVAR(menuSide_isInit), true];

		private _ctrls = [];

		// Fill out the controls with actual data (flag textures, side names, etc.)
		{
			_x params ["_sideX", "_listBoxIDC", "_flagPictureIDC", "_nameTextIDC"];

			_ctrls pushback (_spawnMenu displayCtrl _listBoxIDC);
			(_spawnMenu displayCtrl _flagPictureIDC) ctrlSetText ([_sideX] call FUNC(gm_getFlagTexture));
			(_spawnMenu displayCtrl _nameTextIDC) ctrlSetText ([_sideX] call FUNC(gm_getSideName));
		} forEach [
			[_sideLeft,   MACRO_IDC_SM_SIDE_PLAYERS_LEFT_LISTBOX,   MACRO_IDC_SM_SIDE_FLAG_LEFT_PICTURE,   MACRO_IDC_SM_SIDE_NAME_LEFT_TEXT],
			[_sideMiddle, MACRO_IDC_SM_SIDE_PLAYERS_MIDDLE_LISTBOX, MACRO_IDC_SM_SIDE_FLAG_MIDDLE_PICTURE, MACRO_IDC_SM_SIDE_NAME_MIDDLE_TEXT],
			[_sideRight,  MACRO_IDC_SM_SIDE_PLAYERS_RIGHT_LISTBOX,  MACRO_IDC_SM_SIDE_FLAG_RIGHT_PICTURE,  MACRO_IDC_SM_SIDE_NAME_RIGHT_TEXT]
		];

		// Save the resulting array of controls to be updated
		_spawnMenu setVariable [QGVAR(menuSide_ctrls), _ctrls];
	};

	// If the menu was reopened, we may need to hide some controls again (as the sides controls group keeps unhiding them when it gets unhidden)
	if !(_spawnMenu getVariable [QGVAR(menu_isOpen), false]) then {
		_spawnMenu setVariable [QGVAR(menu_isOpen), true];

		if (_sideLeft == sideEmpty) then {
			{
				(_spawnMenu displayCtrl _x) ctrlShow false;
			} forEach [
				MACRO_IDC_SM_SIDE_FLAG_LEFT_PICTURE,
				MACRO_IDC_SM_SIDE_FLAG_LEFT_GRADIENT,
				MACRO_IDC_SM_SIDE_FLAG_LEFT_FILL,
				MACRO_IDC_SM_SIDE_FLAG_LEFT_SEPARATOR,
				MACRO_IDC_SM_SIDE_NAME_LEFT_TEXT,
				MACRO_IDC_SM_SIDE_TICKETS_LEFT_TEXT,
				MACRO_IDC_SM_SIDE_PLAYERS_LEFT_BACKGROUND,
				MACRO_IDC_SM_SIDE_PLAYERS_LEFT_OUTLINE,
				MACRO_IDC_SM_SIDE_PLAYERS_LEFT_LISTBOX,
				MACRO_IDC_SM_SIDE_JOIN_LEFT_FRAME,
				MACRO_IDC_SM_SIDE_JOIN_LEFT_BUTTON
			];
		};

		if (_sideMiddle == sideEmpty) then {
			{
				(_spawnMenu displayCtrl _x) ctrlShow false;
			} forEach [
				MACRO_IDC_SM_SIDE_FLAG_MIDDLE_PICTURE,
				MACRO_IDC_SM_SIDE_FLAG_MIDDLE_GRADIENT,
				MACRO_IDC_SM_SIDE_FLAG_MIDDLE_FILL,
				MACRO_IDC_SM_SIDE_FLAG_MIDDLE_SEPARATOR,
				MACRO_IDC_SM_SIDE_NAME_MIDDLE_TEXT,
				MACRO_IDC_SM_SIDE_TICKETS_MIDDLE_TEXT,
				MACRO_IDC_SM_SIDE_PLAYERS_MIDDLE_BACKGROUND,
				MACRO_IDC_SM_SIDE_PLAYERS_MIDDLE_OUTLINE,
				MACRO_IDC_SM_SIDE_PLAYERS_MIDDLE_LISTBOX,
				MACRO_IDC_SM_SIDE_JOIN_MIDDLE_FRAME,
				MACRO_IDC_SM_SIDE_JOIN_MIDDLE_BUTTON
			];
		};

		if (_sideRight == sideEmpty) then {
			{
				(_spawnMenu displayCtrl _x) ctrlShow false;
			} forEach [
				MACRO_IDC_SM_SIDE_FLAG_RIGHT_PICTURE,
				MACRO_IDC_SM_SIDE_FLAG_RIGHT_GRADIENT,
				MACRO_IDC_SM_SIDE_FLAG_RIGHT_FILL,
				MACRO_IDC_SM_SIDE_FLAG_RIGHT_SEPARATOR,
				MACRO_IDC_SM_SIDE_NAME_RIGHT_TEXT,
				MACRO_IDC_SM_SIDE_TICKETS_RIGHT_TEXT,
				MACRO_IDC_SM_SIDE_PLAYERS_RIGHT_BACKGROUND,
				MACRO_IDC_SM_SIDE_PLAYERS_RIGHT_OUTLINE,
				MACRO_IDC_SM_SIDE_PLAYERS_RIGHT_LISTBOX,
				MACRO_IDC_SM_SIDE_JOIN_RIGHT_FRAME,
				MACRO_IDC_SM_SIDE_JOIN_RIGHT_BUTTON
			];
		};
	};





	// Update the side tickets
	private ["_ctrlX", "_ticketsX"];
	{
		_x params ["_side", "_idcTickets", "_ticketBleed"];

		if (_side != sideEmpty) then {
			_ticketsX = [_side] call FUNC(gm_getSideTickets);

			_ctrlX = _spawnMenu displayCtrl _idcTickets;
			_ctrlX ctrlSetText str _ticketsX;
			_ctrlX ctrlSetTextColor ([SQUARE(MACRO_COLOUR_A100_WHITE), SQUARE(MACRO_COLOUR_A100_RED)] select (_ticketBleed or {_ticketsX <= 0}));
		};
	} forEach [
		[_sideLeft,	MACRO_IDC_SM_SIDE_TICKETS_LEFT_TEXT, 	_ticketBleedLeft],
		[_sideMiddle,	MACRO_IDC_SM_SIDE_TICKETS_MIDDLE_TEXT,	_ticketBleedMiddle],
		[_sideRight,	MACRO_IDC_SM_SIDE_TICKETS_RIGHT_TEXT,	_ticketBleedRight]
	];

	// Update the side join buttons
	private ["_isSelected", "_isPlayable", "_ctrlButton"];
	private _alive = [player] call FUNC(unit_isAlive);
	{
		_x params ["_side", "_idcFrame", "_idcButton"];
		_isSelected   = (GVAR(side) == _side);
		_isPlayable   = [_side] call FUNC(gm_isSidePlayable);
		_isSelectable = !_alive and {_isPlayable};
		_ctrlButton   = _spawnMenu displayCtrl _idcFrame;

		if (_isSelected and {_isSelectable}) then {
			_ctrlButton ctrlSetBackgroundColor SQUARE(MACRO_COLOUR_BUTTON_ACTIVE_PRESSED);
		} else {
			_ctrlButton ctrlSetBackgroundColor ([SQUARE(MACRO_COLOUR_BUTTON_INACTIVE), SQUARE(MACRO_COLOUR_BUTTON_ACTIVE)] select _isSelectable);
		};

		(_spawnMenu displayCtrl _idcButton) ctrlSetText (["CLICK TO SELECT", "SELECTED"] select _isSelected);

	} forEach [
		[_sideLeft,	MACRO_IDC_SM_SIDE_JOIN_LEFT_FRAME,	MACRO_IDC_SM_SIDE_JOIN_LEFT_BUTTON],
		[_sideMiddle,	MACRO_IDC_SM_SIDE_JOIN_MIDDLE_FRAME,	MACRO_IDC_SM_SIDE_JOIN_MIDDLE_BUTTON],
		[_sideRight,	MACRO_IDC_SM_SIDE_JOIN_RIGHT_FRAME,	MACRO_IDC_SM_SIDE_JOIN_RIGHT_BUTTON]
	];

	// Update the names lists
	private _ctrls = _spawnMenu getVariable [QGVAR(menuSide_ctrls), []];
	private _players = allPlayers;
	private ["_curSide", "_curSideIndex", "_ctrlListBox", "_unit", "_index"];
	{
		_curSide = _x;
		_curSideIndex = _forEachIndex;
		_ctrlListBox = _ctrls param [_forEachIndex, controlNull];
		_index = 0;

		// Clear all entries from the listbox
		lbClear _ctrlListBox;

		if ([_curSide] call FUNC(gm_isSidePlayable)) then {
			// Add the players from this side
			{
				_ctrlListBox lnbAddRow ["", name _x];
				_ctrlListBox lnbSetPicture [[_index, 0], squadParams _x # 0 # 4];

				if !([_x] call FUNC(unit_isAlive)) then {
					for "_i" from 0 to 1 do {
						_ctrlListBox lnbSetColor [[_index, _i], SQUARE(MACRO_COLOUR_A100_GREY)];
					};
				};
				_index = _index + 1;
			} forEach (_players select {_x getVariable [QGVAR(side), sideEmpty] == _curSide});

			// Add the AI units from this side
			{
				// Only consider units that are on this side
				if (_x # 0 == _curSideIndex) then {
					_unit = missionNamespace getVariable [format [QGVAR(AIUnit_%1), _forEachIndex], objNull];

					_ctrlListBox lnbAddRow ["AI", _x # 1];
					_ctrlListBox lnbSetColor [[_index, 0], SQUARE(MACRO_COLOUR_A100_GREY)];

					if !([_unit] call FUNC(unit_isAlive)) then {
						_ctrlListBox lnbSetColor [[_index, 1], SQUARE(MACRO_COLOUR_A100_GREY)];
					};
					_index = _index + 1;
				};
			} forEach GVAR(cl_AIIdentities);
		};
	} forEach GVAR(sides);
};
