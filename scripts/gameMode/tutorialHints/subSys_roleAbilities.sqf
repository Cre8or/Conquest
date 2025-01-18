if (_alive) then {
	private _key       = format ["%1_%2", GVAR(side), GVAR(role)];
	private _hintShown = GVAR(gm_sys_tutorialHints_hashmap_roleAbilities) getOrDefault [_key, false];

	if (_hintShown) then {
		breakTo QGVAR(gm_sys_tutorialHints);
	};



	// Determine the abilities associated with the player's role on this side
	private _abilities     = missionNamespace getVariable [format [QGVAR(abilities_%1_%2), GVAR(side), GVAR(role)], []];
	private _abilitiesText = _abilities apply {[
		"<img image='" + ([_x, false] call FUNC(ui_getAbilityIcon)) + "'/> ",
		[_x] call FUNC(ui_getAbilityDescription)
	]};

	if (_abilitiesText isNotEqualTo []) then {

		// Prepare the hint sentence
		private _roleName = (switch (GVAR(role)) do {
			case MACRO_ENUM_ROLE_SPECOPS:  {LSTRING(role_specops) call BIS_fnc_localize};
			case MACRO_ENUM_ROLE_SNIPER:   {LSTRING(role_sniper) call BIS_fnc_localize};
			case MACRO_ENUM_ROLE_ASSAULT:  {LSTRING(role_assault) call BIS_fnc_localize};
			case MACRO_ENUM_ROLE_SUPPORT:  {LSTRING(role_support) call BIS_fnc_localize};
			case MACRO_ENUM_ROLE_ENGINEER: {LSTRING(role_engineer) call BIS_fnc_localize};
			case MACRO_ENUM_ROLE_MEDIC:    {LSTRING(role_medic) call BIS_fnc_localize};
			case MACRO_ENUM_ROLE_ANTITANK: {LSTRING(role_antitank) call BIS_fnc_localize};
			default                        {"Unknown role"};
		});

		private _sentence = format [
			LSTRING(tutorialHints_roleAbilities) call BIS_fnc_localize,
			MACRO_FNC_ADDHTMLCOLOUR(_roleName, "00FF00")
		];
		_sentence = _sentence + "<br/>";
		{
			_sentence = _sentence + "<br/><t align='left'>" + (_x # 0) + "</t><t align='center'>" + (_x # 1) + "</t>";
		} forEach _abilitiesText;

		hintSilent parseText _sentence;
	};

	GVAR(gm_sys_tutorialHints_hashmap_roleAbilities) set [_key, true];
};
