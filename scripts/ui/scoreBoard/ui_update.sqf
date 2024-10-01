case "ui_update": {
	_eventExists = true;

	private _player       = player;
	private _plyGroup     = group _player;
	private _allSideUnits = GVAR(ui_scoreBoard_sides) apply {[]};
	private _sideIndexes  = GVAR(sides) apply {GVAR(ui_scoreBoard_sides) find _x}; // Used to match AI units' side indexes
	GVAR(ui_scoreBoard_sides) params [["_sideLeft", sideEmpty], ["_sideMiddle", sideEmpty], ["_sideRight", sideEmpty]];





	// Aggregate players data from all sides
	private ["_sideX", "_sideIndex", "_UID", "_data", "_sideUnits"];
	{
		_sideX = _x getVariable [QGVAR(side), sideEmpty];

		_sideIndex = GVAR(ui_scoreBoard_sides) find _sideX;
		if (_sideIndex < 0) then {
			continue;
		};

		_UID       = [_x] call FUNC(unit_getUID);
		_data      = GVAR(ui_scoreBoard_cache) getOrDefault [_UID, []];
		_sideUnits = _allSideUnits # _sideIndex;
		_sideUnits pushBack [
			_UID, // UID
			squadParams _x # 0 # 4, // squadIcon
			name _x, // name
			_data param [MACRO_INDEX_SERVERSTAT_SCORE, 0], // score
			_data param [MACRO_INDEX_SERVERSTAT_KILLS, 0], // kills
			_data param [MACRO_INDEX_SERVERSTAT_DEATHS, 0], // deaths
			_data param [MACRO_INDEX_SERVERSTAT_REVIVES, 0], // revives
			_data param [MACRO_INDEX_SERVERSTAT_PING, 0], // ping
			group _x, // group
			[_x] call FUNC(unit_isAlive), // isAlive
			true // isPlayer
		];
	} forEach allPlayers;

	// Aggregate AI units data from all sides
	private ["_unitIndex", "_groupIndex", "_groupX", "_unitX"];
	{
		_sideIndex = _x # MACRO_INDEX_AIIDENTITY_SIDEINDEX;

		// Remap the "global" side index to the list of valid sides
		_sideIndex = _sideIndexes # _sideIndex;
		if (_sideIndex < 0) then {
			continue;
		};

		_side       = GVAR(ui_scoreBoard_sides) # _sideIndex;
		_unitIndex  = _x # MACRO_INDEX_AIIDENTITY_UNITINDEX;
		_groupIndex = _x # MACRO_INDEX_AIIDENTITY_GROUPINDEX;
		_groupX     = missionNamespace getVariable [format [QGVAR(AIGroup_%1_%2), _side, _groupIndex], grpNull];
		_unitX      = missionNamespace getVariable [format [QGVAR(AIUnit_%1), _unitIndex], objNull];
		_UID        = [_unitIndex] call FUNC(unit_getUID);
		_data       = GVAR(ui_scoreBoard_cache) getOrDefault [_UID, []];

		_sideUnits = _allSideUnits # _sideIndex;
		_sideUnits pushBack [
			_UID, // UID
			"", // squadIcon (AI)
			_x # MACRO_INDEX_AIIDENTITY_NAME, // name
			_data param [MACRO_INDEX_SERVERSTAT_SCORE, 0], // score
			_data param [MACRO_INDEX_SERVERSTAT_KILLS, 0], // kills
			_data param [MACRO_INDEX_SERVERSTAT_DEATHS, 0], // deaths
			_data param [MACRO_INDEX_SERVERSTAT_REVIVES, 0], // revives
			0, // ping
			_groupX, // group
			[_unitX] call FUNC(unit_isAlive), // isAlive
			false // isPlayer
		];

	} forEach GVAR(cl_AIIdentities);

	// Append a dummy entry to every sideUnits array. This is to pad the bottom of the listbox,
	// as currently using the scrollwheel doesn't move the scrollbar to the very bottom, cliping
	// off the last entry.
	{
		_x pushback [
			"", // UID
			"", // squadIcon (AI)
			"", // name
			0, // score
			0, // kills
			0, // deaths
			0, // revives
			0, // ping
			grpNull, // group
			false // isAlive
		];
	} forEach _allSideUnits;





	// Update the scoreboard listboxes for all sides
	private ["_ctrlTickets", "_ctrlListBox", "_tickets", "_colour", "_isPlayerSide", "_prevUnitsCount", "_unitsCount", "_selectedIndex"];
	{
		_x params ["_sideX", "_idcSideTickets", "_idcListBox"];
		if (_sideX == sideEmpty) then {
			continue;
		};

		scopeName QGVAR(ui_scoreBoard_side);

		_ctrlTickets = _scoreBoard displayCtrl _idcSideTickets;
		_ctrlListBox = _scoreBoard displayCtrl _idcListBox;

		// Update the tickets count and bleedout indicator
		_tickets = [_sideX] call FUNC(gm_getSideTickets);
		if (_tickets <= 0) then {
			_colour = SQUARE(MACRO_COLOUR_A25_WHITE);
		} else {
			if ([_sideX] call FUNC(gm_getTicketBleed) > 0) then {
				_colour = SQUARE(MACRO_COLOUR_A100_RED);
			} else {
				_colour = SQUARE(MACRO_COLOUR_A100_WHITE);
			};
		};

		_ctrlTickets ctrlSetText str _tickets;
		_ctrlTickets ctrlSetTextColor _colour;



		// Ensure the listbox's rows count matches the units count. This prevents the vertical scrollbar
		// from jumping back to 0% after every update.
		_sideUnits    = _allSideUnits param [_forEachIndex, []];
		_isPlayerSide = (_sideX == GVAR(side));

		_prevUnitsCount = _ctrlListBox getVariable [QGVAR(prevUnitsCount), 0];
		_unitsCount     = count _sideUnits;

		if (_prevUnitsCount <= _unitsCount) then {
			for "_i" from _prevUnitsCount to _unitsCount - 1 do {
				_ctrlListBox lnbAddRow ["", "", "", "", "", "", ""];
			};
		} else {
			for "_i" from _unitsCount to _prevUnitsCount - 1 do {
				_ctrlListBox lnbDeleteRow _i;
			};
		};

		// Fill out the listbox rows with actual data
		{
			_x params ["_UID", "_squadIcon", "_name", "_score", "_kills", "_deaths", "_revives", "_ping", "_group", "_isAlive", "_isPlayer"];

			if (_name != "") then {
				// Differentiate players from AI units
				if (_isPlayer) then {
					_ctrlListBox lnbSetText [[_forEachIndex, 0], ""];
					_ctrlListBox lnbSetPicture [[_forEachIndex, 0], _squadIcon];
					_ctrlListBox lnbSetColor [[_forEachIndex, 0], SQUARE(MACRO_COLOUR_A100_WHITE)];
					_ctrlListBox lnbSetTextRight [[_forEachIndex, 6], str _ping];

				} else {
					_ctrlListBox lnbSetPicture [[_forEachIndex, 0], ""];
					_ctrlListBox lnbSetText [[_forEachIndex, 0], "AI"];
					_ctrlListBox lnbSetColor [[_forEachIndex, 0], SQUARE(MACRO_COLOUR_A25_WHITE)];
					_ctrlListBox lnbSetTextRight [[_forEachIndex, 6], ""];
				};

				// Fill out the remaining columns
				_ctrlListBox lnbSetText [[_forEachIndex, 1], _name];
				_ctrlListBox lnbSetTextRight [[_forEachIndex, 2], str _score];
				_ctrlListBox lnbSetValue [[_forEachIndex, 2], _score];
				_ctrlListBox lnbSetTextRight [[_forEachIndex, 3], str _kills];
				_ctrlListBox lnbSetTextRight [[_forEachIndex, 4], str _deaths];
				_ctrlListBox lnbSetTextRight [[_forEachIndex, 5], str _revives];

				_ctrlListBox lnbSetData [[_forEachIndex, 1], _UID];

				// Handle row colours
				_colour = (switch (true) do {
					case (!_isAlive): {
						SQUARE(MACRO_COLOUR_A100_GREY);
					};
					case (_group == _plyGroup): {
						SQUARE(MACRO_COLOUR_A100_SQUAD);
					};
					case (_isPlayerSide): {
						SQUARE(MACRO_COLOUR_A100_FRIENDLY);
					};
					default {
						SQUARE(MACRO_COLOUR_A100_ENEMY);
					};
				});

				for "_column" from 1 to 6 do {
					_ctrlListBox lnbSetColor [[_forEachIndex, _column], _colour];
					_ctrlListBox lnbSetColorRight [[_forEachIndex, _column], _colour];
				};

			// Blank entry
			} else {
				_ctrlListBox lnbSetPicture [[_forEachIndex, 0], ""];
				_ctrlListBox lnbSetText [[_forEachIndex, 1], ""];
				_ctrlListBox lnbSetTextRight [[_forEachIndex, 2], ""];
				_ctrlListBox lnbSetValue [[_forEachIndex, 2], -9e9];
				_ctrlListBox lnbSetTextRight [[_forEachIndex, 3], ""];
				_ctrlListBox lnbSetTextRight [[_forEachIndex, 4], ""];
				_ctrlListBox lnbSetTextRight [[_forEachIndex, 5], ""];
				_ctrlListBox lnbSetTextRight [[_forEachIndex, 6], ""];
			}

		} forEach _sideUnits;

		// Sort by score
		[_ctrlListBox, 2] lnbSortBy ["VALUE", true, false, false, true];

		// Handle the listbox selection
		_selectedIndex = lnbCurSelRow _ctrlListBox;

		if (_sideX != GVAR(ui_scoreBoard_selectedSide)) then {
			if (_selectedIndex >= 0) then {
				_ctrlListBox lnbSetCurSelRow -1;
			};
		} else {
			for "_i" from 0 to _unitsCount - 1 do {
				_UID = _ctrlListBox lnbData [_i, 1];

				if (_UID == GVAR(ui_scoreBoard_selectedUID)) then {
					if (_selectedIndex != _i) then {
						_ctrlListBox lnbSetCurSelRow _i;
					};

					// Change the selected row's text colour to black for enhanced readability
					for "_column" from 1 to 6 do {
						_ctrlListBox lnbSetColor [[_i, _column], SQUARE(MACRO_COLOUR_A100_BLACK)];
						_ctrlListBox lnbSetColorRight [[_i, _column], SQUARE(MACRO_COLOUR_A100_BLACK)];
					};
					breakTo QGVAR(ui_scoreBoard_side);
				};
			};
		};

		_ctrlListBox setVariable [QGVAR(prevUnitsCount), _unitsCount];

	} forEach [
		[_sideLeft,   MACRO_IDC_SB_SIDE_TICKETS_LEFT_TEXT,   MACRO_IDC_SB_SIDE_PLAYERS_LEFT_LISTBOX],
		[_sideMiddle, MACRO_IDC_SB_SIDE_TICKETS_MIDDLE_TEXT, MACRO_IDC_SB_SIDE_PLAYERS_MIDDLE_LISTBOX],
		[_sideRight,  MACRO_IDC_SB_SIDE_TICKETS_RIGHT_TEXT,  MACRO_IDC_SB_SIDE_PLAYERS_RIGHT_LISTBOX]
	];
};
