// Medical action: heal injured friendlies
private _c_maxDistSqr = 20 ^ 2;
if (
	GVAR(gm_sys_tutorialHints_activeHint) == MACRO_ENUM_TUTORIALHINT_INVALID
	and {_alive}
	and {GVAR(role) == MACRO_ENUM_ROLE_MEDIC}
	and {_teamMates findIf {
		_x getVariable [QGVAR(health), 1] <= MACRO_UNIT_HEALTH_THRESHOLDLOW
		and {!(_x getVariable [QGVAR(isUnconscious), false])}
		and {_x distanceSqr _player < _c_maxDistSqr}
	} >= 0}
) then {

	private _key       = MACRO_ENUM_TUTORIALHINT_MEDICAL_HEALFRIENDLY;
	private _hintShown = GVAR(gm_sys_tutorialHints_hashmap) getOrDefault [_key, false];

	if (!_hintShown) then {
		GVAR(gm_sys_tutorialHints_activeHint) = MACRO_ENUM_TUTORIALHINT_MEDICAL_HEALFRIENDLY;
		GVAR(gm_sys_tutorialHints_startTime)  = _time;
		GVAR(gm_sys_tutorialHints_expiration) = _time + MACRO_TH_EXPIRATION_SHORT;

		private _keyBindStr = [MACRO_MISSION_FRAMEWORK_GAMEMODE, QGVAR(kb_healUnit)] call FUNC(cba_getKeybindStr);
		GVAR(ui_sys_drawTutorialHints_data)   = [_keyBindStr];
		GVAR(ui_sys_drawTutorialHints_update) = true;

		GVAR(gm_sys_tutorialHints_hashmap) set [_key, true];
	};
};
