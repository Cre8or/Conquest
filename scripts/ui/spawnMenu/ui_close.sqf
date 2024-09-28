// Unloading (closing the inventory)
case "ui_close": {
	_eventExists = true;

	_args params [
		["_forced", false, [false]]
	];





	// Remember which menu was open
	GVAR(ui_sm_prevMenu) = _spawnMenu getVariable [QGVAR(currentMenu), -1];

	// Stop the blur post-process effect
	GVAR(ui_sm_blurFx) ppEffectAdjust [0];
	GVAR(ui_sm_blurFx) ppEffectCommit 0.1;

	// Reopen the info panels
	setInfoPanel ["left", GVAR(ui_sm_panelLeft)];
	setInfoPanel ["right", GVAR(ui_sm_panelRight)];

	// Show the HUD
	showHUD [true, true, true, true, true, true, true, true, true, true];

	// Re-enable the action menu
	inGameUISetEventHandler ["PrevAction", "false"];
	inGameUISetEventHandler ["NextAction", "false"];
	inGameUISetEventHandler ["Action", "false"];

	// Re-enable the ShackTac UI group HUD (if it exists)
	if (!isNil "STHUD_UIMode" and {GVAR(STHUD_UIMode) > 0}) then {
		STHUD_UIMode = GVAR(STHUD_UIMode);
		GVAR(STHUD_UIMode) = 0;
	};

	removeMissionEventHandler ["EachFrame", GVAR(ui_sm_EH_eachFrame)];

	// Hide the role rendertarget objects
	GVAR(rt_role_wall) hideObject true;
	GVAR(rt_role_unit) hideObject true;

	// If this event is being forced, manually close the scorebard
	if (_forced) then {

		// Prevent recursive firing of the unload events handler
		_spawnMenu displayRemoveAllEventHandlers "Unload";
		_spawnMenu closeDisplay 0;
	};
};
