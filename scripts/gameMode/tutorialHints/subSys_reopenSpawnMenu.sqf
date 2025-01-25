if (
	GVAR(gm_sys_tutorialHints_activeHint) == MACRO_ENUM_TUTORIALHINT_INVALID
	and {GVAR(gm_sys_handlePlayerRespawn_state) >= MACRO_ENUM_RESPAWN_SPAWNED_FROZEN}
	and {GVAR(gm_sys_handlePlayerRespawn_state) != MACRO_ENUM_RESPAWN_SPAWNED_UNFROZEN}
	and {isNull (uiNamespace getVariable [QGVAR(RscSpawnMenu), displayNull])}
) then {

	private _key       = MACRO_ENUM_TUTORIALHINT_REOPENSPAWNMENU;
	private _hintShown = GVAR(gm_sys_tutorialHints_hashmap) getOrDefault [_key, false];

	if (!_hintShown) then {
		GVAR(gm_sys_tutorialHints_activeHint) = MACRO_ENUM_TUTORIALHINT_REOPENSPAWNMENU;
		GVAR(gm_sys_tutorialHints_startTime)  = _time;
		GVAR(gm_sys_tutorialHints_expiration) = _time + MACRO_TH_EXPIRATION_SHORT;

		private _keyBindStr = [MACRO_MISSION_FRAMEWORK_GAMEMODE, QGVAR(kb_toggleSpawnMenu)] call FUNC(cba_getKeybindStr);
		GVAR(ui_sys_drawTutorialHints_data)   = [_keyBindStr];
		GVAR(ui_sys_drawTutorialHints_update) = true;

		GVAR(gm_sys_tutorialHints_hashmap) set [_key, true];
	};
};
