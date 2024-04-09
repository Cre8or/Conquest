// Role menu
case "ui_update_role": {
	_eventExists = true;

	#include "..\..\..\..\res\macros\cond_isValidGroup.inc"

	// Fetch our params
	_args params [
		["_shouldUpdateRole", false, [false]],
		["_shouldSelectCurrentGroup", false, [false]]
	];

	// Set up some variables
	private _menuInit = false;
	private _menuOpened = false;





	// Perform the initial setup
	if !(_spawnMenu getVariable [QGVAR(menuRole_isInit), false]) then {
		_spawnMenu setVariable [QGVAR(menuRole_isInit), true];
		_menuInit = true;

		// Set up some variables
		private _ctrls = [];
		private _ctrlGrp = _spawnMenu displayCtrl MACRO_IDC_SM_ROLE_CTRLGROUP;
		private _safeZoneW = safeZoneW;
		private _safeZoneH = safeZoneH;
		private _pixelW = pixelW;
		private _pixelH = pixelH;
		private ["_roleIndex", "_loadout", "_abilities", "_weaponPrimary", "_posFrame", "_posAbility", "_offsetX", "_offsetY", "_ctrlAbility_background", "_ctrlAbility_icon"];

		// Delete the previous controls
		{
			ctrlDelete _x;
		} forEach (_spawnMenu getVariable [QGVAR(menuRole_ctrls), []]);

		// Fill the loadout controls with actual data
		{
			_x params ["_IDC_frame", "_IDC_shadowPicture", "_IDC_weaponPicture"];
			_roleIndex     = _forEachIndex;
			_loadout       = missionNamespace getVariable [format [QGVAR(loadout_%1_%2), GVAR(side), _roleIndex], []];
			_abilities     = missionNamespace getVariable [format [QGVAR(abilities_%1_%2), GVAR(side), _roleIndex], []];
			_weaponPrimary = missionNamespace getVariable [format [QGVAR(weaponIcon_%1_%2), GVAR(side), _roleIndex], ""];
			_posFrame      = ctrlPosition (_ctrlGrp controlsGroupCtrl _IDC_frame);

			// Set the loadout's weapon icon
			(_ctrlGrp controlsGroupCtrl _IDC_shadowPicture) ctrlSetText _weaponPrimary;
			(_ctrlGrp controlsGroupCtrl _IDC_weaponPicture) ctrlSetText _weaponPrimary;

			// Iterate over this loadout's abilities
			{
				_offsetX = 1 + floor (_forEachIndex / 2);
				_offsetY = _forEachIndex mod 2;
				_posAbility = [
					_posFrame # 2 - _offsetX * _safeZoneW * 0.025 - (_offsetX - 1) * _pixelW * MACRO_POS_SPACER_X,
					_posFrame # 1 + _offsetY * _safeZoneH * 0.04 + (_offsetY + 1) * _pixelH * MACRO_POS_SPACER_Y + _safeZoneH * 0.03,
					_safeZoneW * 0.025,
					_safeZoneH * 0.04
				];

				// Create the background frame
				_ctrlAbility_background = _spawnMenu ctrlCreate [QGVAR(RscPicture), -1, _ctrlGrp];
				_ctrlAbility_background ctrlSetText "res\images\abilities\ability_background.paa";
				_ctrlAbility_background ctrlSetTextColor SQUARE(MACRO_COLOUR_A75_BLACK);
				_ctrlAbility_background ctrlSetPosition _posAbility;
				_ctrlAbility_background ctrlCommit 0;

				// Create the ability picture
				_ctrlAbility_icon = _spawnMenu ctrlCreate [QGVAR(RscPicture), -1, _ctrlGrp];
				_ctrlAbility_icon ctrlSetText ([_x] call FUNC(ui_getAbilityIcon));
				_ctrlAbility_icon ctrlSetPosition _posAbility;
				_ctrlAbility_icon ctrlCommit 0;

				// Save the newly created controls in our array
				_ctrls pushBack _ctrlAbility_background;
				_ctrls pushBack _ctrlAbility_icon;

			} forEach (_abilities select [0, 8]); // Limit to 8 abilities to avoid clutter
		} forEach [
			[MACRO_IDC_SM_ROLE_SPECOPS_FRAME,	MACRO_IDC_SM_ROLE_SPECOPS_SHADOW_PICTURE,	MACRO_IDC_SM_ROLE_SPECOPS_WEAPON_PICTURE],
			[MACRO_IDC_SM_ROLE_SNIPER_FRAME,	MACRO_IDC_SM_ROLE_SNIPER_SHADOW_PICTURE,	MACRO_IDC_SM_ROLE_SNIPER_WEAPON_PICTURE],
			[MACRO_IDC_SM_ROLE_ASSAULT_FRAME,	MACRO_IDC_SM_ROLE_ASSAULT_SHADOW_PICTURE,	MACRO_IDC_SM_ROLE_ASSAULT_WEAPON_PICTURE],
			[MACRO_IDC_SM_ROLE_SUPPORT_FRAME,	MACRO_IDC_SM_ROLE_SUPPORT_SHADOW_PICTURE,	MACRO_IDC_SM_ROLE_SUPPORT_WEAPON_PICTURE],
			[MACRO_IDC_SM_ROLE_ENGINEER_FRAME,	MACRO_IDC_SM_ROLE_ENGINEER_SHADOW_PICTURE,	MACRO_IDC_SM_ROLE_ENGINEER_WEAPON_PICTURE],
			[MACRO_IDC_SM_ROLE_MEDIC_FRAME,		MACRO_IDC_SM_ROLE_MEDIC_SHADOW_PICTURE,		MACRO_IDC_SM_ROLE_MEDIC_WEAPON_PICTURE],
			[MACRO_IDC_SM_ROLE_ANTITANK_FRAME,	MACRO_IDC_SM_ROLE_ANTITANK_SHADOW_PICTURE,	MACRO_IDC_SM_ROLE_ANTITANK_WEAPON_PICTURE]
		];

		// Force the preview unit to update its loadout
		_shouldUpdateRole = true;

		// Save the new controls
		_spawnMenu setVariable [QGVAR(menuRole_ctrls), _ctrls];
	};

	// If the role menu was opened, reset the role preview scene back to default values
	if !(_spawnMenu getVariable [QGVAR(menu_isOpen), false]) then {
		_spawnMenu setVariable [QGVAR(menu_isOpen), true];
		_menuOpened = true;

		if (isPipEnabled) then {

			// Reset the unit's position and direction
			GVAR(rt_role_unit) attachTo [GVAR(rt_role_wall), [0,15,-1]];
			GVAR(rt_role_unit) setDir MACRO_SM_ROLEPREVIEW_BASEDIRECTION;
			_spawnMenu setVariable [QGVAR(rolePreview_unitPosZ), -1];

			// Reset the camera's field of view
			GVAR(cam_role_curFov) = MACRO_SM_ROLEPREVIEW_BASEFOV;
			GVAR(cam_role) camSetFov GVAR(cam_role_curFov);

			// Set up the controls text
			(_spawnMenu displayCtrl MACRO_IDC_SM_ROLE_PREVIEW_CONTROLS_TEXT) ctrlSetText format ["Hold RMB to pan/rotate\nScroll to zoom\nPress %1 to toggle NVG", (actionKeysNamesArray "nightVision") param [0, "<Night vision (UNBOUND)>"]];
			(_spawnMenu displayCtrl MACRO_IDC_SM_ROLE_PREVIEW_CONTROLS_TEXT) ctrlSetTextColor SQUARE(MACRO_COLOUR_A0);

		// Otherwise, hide the preview controls group
		} else {
			(_spawnMenu displayCtrl MACRO_IDC_SM_ROLE_PREVIEW_CTRLGROUP) ctrlShow false;
		};
	};

	// Check if the selected role has changed
	if (_shouldUpdateRole) then {

		if (GVAR(role) != MACRO_ENUM_ROLE_INVALID) then {
			[GVAR(rt_role_unit), GVAR(side), GVAR(role)] call FUNC(lo_setRoleLoadout);
			GVAR(rt_role_unit) switchMove selectRandom [
				"Acts_AidlPercMstpSloWWpstDnon_warmup_1_loop",
				"Acts_AidlPercMstpSloWWrflDnon_warmup_3_loop",
				"Acts_AidlPercMstpSloWWrflDnon_warmup_4_loop",
				"Acts_RU_Briefing_Speaking",
				"Acts_GetAttention_Loop"
			];
			GVAR(rt_role_unit) setAnimSpeedCoef 0.5;
			GVAR(rt_role_unit) hideObject false;
		} else {
			GVAR(rt_role_unit) hideObject true;
		};

		// Reset the colour of all loadout frames
		private ["_isSelected"];
		{
			_x params ["_roleX", "_idc_frameX", "_idc_backgroundX"];
			_isSelected = (_roleX == GVAR(role));

			(_spawnMenu displayCtrl _idc_frameX) ctrlSetBackgroundColor ([SQUARE(MACRO_COLOUR_BUTTON_ACTIVE), SQUARE(MACRO_COLOUR_BUTTON_ACTIVE_PRESSED)] select _isSelected);
			(_spawnMenu displayCtrl _idc_backgroundX) ctrlSetBackgroundColor ([SQUARE(MACRO_COLOUR_A50_WHITE), SQUARE(MACRO_COLOUR_A75_WHITE)] select _isSelected);
		} forEach [
			[MACRO_ENUM_ROLE_SPECOPS,	MACRO_IDC_SM_ROLE_SPECOPS_FRAME,	MACRO_IDC_SM_ROLE_SPECOPS_BACKGROUND],
			[MACRO_ENUM_ROLE_SNIPER,	MACRO_IDC_SM_ROLE_SNIPER_FRAME,		MACRO_IDC_SM_ROLE_SNIPER_BACKGROUND],
			[MACRO_ENUM_ROLE_ASSAULT,	MACRO_IDC_SM_ROLE_ASSAULT_FRAME,	MACRO_IDC_SM_ROLE_ASSAULT_BACKGROUND],
			[MACRO_ENUM_ROLE_SUPPORT,	MACRO_IDC_SM_ROLE_SUPPORT_FRAME,	MACRO_IDC_SM_ROLE_SUPPORT_BACKGROUND],
			[MACRO_ENUM_ROLE_ENGINEER,	MACRO_IDC_SM_ROLE_ENGINEER_FRAME,	MACRO_IDC_SM_ROLE_ENGINEER_BACKGROUND],
			[MACRO_ENUM_ROLE_MEDIC,		MACRO_IDC_SM_ROLE_MEDIC_FRAME,		MACRO_IDC_SM_ROLE_MEDIC_BACKGROUND],
			[MACRO_ENUM_ROLE_ANTITANK,	MACRO_IDC_SM_ROLE_ANTITANK_FRAME,	MACRO_IDC_SM_ROLE_ANTITANK_BACKGROUND]
		];
	};





	private _ctrlLB_groups = _spawnMenu displayCtrl MACRO_IDC_SM_GROUP_GROUPS_LISTBOX;
	private _ctrlLB_members = _spawnMenu displayCtrl MACRO_IDC_SM_GROUP_MEMBERS_LISTBOX;
	private _ctrlFrame_join = _spawnMenu displayCtrl MACRO_IDC_SM_GROUP_JOIN_FRAME;
	private _ctrlFrame_create = _spawnMenu displayCtrl MACRO_IDC_SM_GROUP_CREATE_FRAME;
	private _ctrlFrame_leave = _spawnMenu displayCtrl MACRO_IDC_SM_GROUP_LEAVE_FRAME;

	// Update the group listboxes
	lbClear _ctrlLB_groups;
	lbClear _ctrlLB_members;

	// Fetch this side's groups
	private _playerGroup = group player;
	private _selectedGroup = _spawnMenu getVariable [QGVAR(menuRole_selectedGroup), grpNull];
	private _isNamingGroup = _spawnMenu getVariable [QGVAR(menuRole_isNamingGroup), false];
	private _groups = allGroups select {MACRO_COND_ISVALIDGROUP(_x)};

	// List all groups
	private ["_units", "_buffer", "_countTotal"];
	{
		_units      = units _x;
		_countTotal = count (_x getVariable [QGVAR(group_AIIdentities), []]) + ({isPlayer _x} count _units);

		// Other groups
		if (_x != _playerGroup) then {
			_ctrlLB_groups lnbAddRow ["", groupId _x, str _countTotal];
			continue;
		};

		// Player's current group
		if (_isNamingGroup) then {
			_buffer = _spawnMenu getVariable [QGVAR(menuRole_textBuffer), ""];

			_ctrlLB_groups lnbAddRow ["", [_buffer, groupId _x] select (_buffer isEqualTo ""), str _countTotal];

			if (_spawnMenu getVariable [QGVAR(menuRole_hasNameCollision), false]) then {
				_ctrlLB_groups lnbSetColor [[_forEachIndex, 1], SQUARE(MACRO_COLOUR_A100_RED)];
			} else {
				_ctrlLB_groups lnbSetColor [[_forEachIndex, 1], SQUARE(MACRO_COLOUR_BUTTON_ACTIVE)];
			};
		} else {
			_ctrlLB_groups lnbAddRow ["", groupId _x, str _countTotal];
		};

		_ctrlLB_groups lnbSetPicture [[_forEachIndex, 0], "a3\ui_f\data\GUI\RscCommon\RscHTML\arrow_right_ca.paa"];

	} forEach _groups;

	// List all players in the selected group
	private _index = 0;
	{
		_ctrlLB_members lnbAddRow ["", "", name _x];
		_ctrlLB_members lnbSetPicture [[_index, 1], squadParams _x # 0 # 4];

		if (!alive _x) then {
			for "_i" from 0 to 2 step 2 do {
				_ctrlLB_members lnbSetColor [[_index, _i], SQUARE(MACRO_COLOUR_A100_GREY)];
			};
		};
		_index = _index + 1;
	} forEach (units _selectedGroup select {isPlayer _x});

	// List all AI units in the group
	private ["_unit"];
	{
		_unit = missionNamespace getVariable [format [QGVAR(AIUnit_%1), _x], objNull];

		_ctrlLB_members lnbAddRow ["", "AI", GVAR(cl_AIIdentities) # _x # 1];
		_ctrlLB_members lnbSetColor [[_index, 1], SQUARE(MACRO_COLOUR_A100_GREY)];

		if (!alive _unit) then {
			for "_i" from 0 to 2 step 2 do {
				_ctrlLB_members lnbSetColor [[_index, _i], SQUARE(MACRO_COLOUR_A100_GREY)];
			};
		};
		_index = _index + 1;
	} forEach (_selectedGroup getVariable [QGVAR(group_AIIdentities), []]);

	// Save the groups list onto the control
	_spawnMenu setVariable [QGVAR(menuRole_groups), _groups];

	// If the menu was initialised for the first time...
	if (_menuInit) then {

		// Reselect the player's current group, if it is present
		_index = _groups find _playerGroup;

		if (_index >= 0) then {
			_ctrlLB_groups lnbSetCurSelRow _index;
			_selectedGroup = _playerGroup;

		// If it isn't, look for the selected group instead
		} else {
			_index = _groups find _selectedGroup;
		};

		// If no group is selected, reset the cursor
		if (_index < 0) then {
			_ctrlLB_groups lnbSetCurSelRow -1;
			_selectedGroup = grpNull;
			_spawnMenu setVariable [QGVAR(menuRole_selectedGroup), _selectedGroup];
		};

	// Otherwise, if the menu was reopened...
	} else {
		if (_menuOpened or {_shouldSelectCurrentGroup}) then {

			// Reselect the previously selected group
			_ctrlLB_groups lnbSetCurSelRow (_groups find _selectedGroup);
		};
	};

	// Set the colour of the group buttons
	private _isPlayerGroupValid = MACRO_COND_ISVALIDGROUP(_playerGroup);

	_ctrlFrame_join ctrlSetBackgroundColor ([SQUARE(MACRO_COLOUR_BUTTON_ACTIVE), SQUARE(MACRO_COLOUR_BUTTON_INACTIVE)] select (isNull _selectedGroup or {_playerGroup == _selectedGroup}));
	_ctrlFrame_leave ctrlSetBackgroundColor ([SQUARE(MACRO_COLOUR_BUTTON_INACTIVE), SQUARE(MACRO_COLOUR_BUTTON_ACTIVE)] select _isPlayerGroupValid);

	if (_isNamingGroup) then {
		_ctrlFrame_create ctrlSetBackgroundColor SQUARE(MACRO_COLOUR_BUTTON_ACTIVE_PRESSED);
	} else {
		_ctrlFrame_create ctrlSetBackgroundColor ([SQUARE(MACRO_COLOUR_BUTTON_ACTIVE), SQUARE(MACRO_COLOUR_BUTTON_INACTIVE)] select _isPlayerGroupValid);
	};
};
