if (
	GVAR(gm_sys_tutorialHints_activeHint) == MACRO_ENUM_TUTORIALHINT_INVALID
	and {_alive}
) then {

	private _key       = format ["%1_%2_%3", MACRO_ENUM_TUTORIALHINT_ROLEABILITIES, GVAR(side), GVAR(role)];
	private _hintShown = GVAR(gm_sys_tutorialHints_hashmap) getOrDefault [_key, false];

	if (!_hintShown) then {
		GVAR(gm_sys_tutorialHints_activeHint) = MACRO_ENUM_TUTORIALHINT_ROLEABILITIES;
		GVAR(gm_sys_tutorialHints_startTime)  = _time;
		GVAR(gm_sys_tutorialHints_expiration) = _time + MACRO_TH_EXPIRATION_ROLEABILITIES;

		GVAR(ui_sys_drawTutorialHints_update) = true;
		GVAR(ui_sys_drawTutorialHints_data)   = [GVAR(side), GVAR(role)];

		GVAR(gm_sys_tutorialHints_hashmap) set [_key, true];
	};
};
