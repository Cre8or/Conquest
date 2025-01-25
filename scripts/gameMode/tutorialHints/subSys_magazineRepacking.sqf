if (
	GVAR(gm_sys_tutorialHints_activeHint) == MACRO_ENUM_TUTORIALHINT_INVALID
	and {_alive}
	and {[_player] call FUNC(unit_isReloading)}
) then {

	private _key       = MACRO_ENUM_TUTORIALHINT_MAGAZINEREPACKING;
	private _hintShown = GVAR(gm_sys_tutorialHints_hashmap) getOrDefault [_key, false];

	if (!_hintShown) then {
		GVAR(gm_sys_tutorialHints_activeHint) = MACRO_ENUM_TUTORIALHINT_MAGAZINEREPACKING;
		GVAR(gm_sys_tutorialHints_startTime)  = _time;
		GVAR(gm_sys_tutorialHints_expiration) = _time + MACRO_TH_EXPIRATION_MEDIUM;

		GVAR(ui_sys_drawTutorialHints_update) = true;

		GVAR(gm_sys_tutorialHints_hashmap) set [_key, true];
	};
};
