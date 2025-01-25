case MACRO_ENUM_TUTORIALHINT_ROLEABILITIES: {
	GVAR(ui_sys_drawTutorialHints_data) params ["_side", "_role"]; // Interface with subSys_roleAbilities

	_strTitle = "TUTORIAL";

	// Determine the abilities associated with the player's role on this side
	private _abilities     = missionNamespace getVariable [format [QGVAR(abilities_%1_%2), _side, _role], []];
	private _abilitiesText = _abilities apply {[
		"<img image='" + ([_x, false] call FUNC(ui_getAbilityIcon)) + "'/> ",
		[_x] call FUNC(ui_getAbilityDescription)
	]};

	// Compile all abilities into the body string
	if (_abilitiesText isNotEqualTo []) then {

		private _roleName = (switch (_role) do {
			case MACRO_ENUM_ROLE_SPECOPS:  {LSTRING(role_specops) call BIS_fnc_localize};
			case MACRO_ENUM_ROLE_SNIPER:   {LSTRING(role_sniper) call BIS_fnc_localize};
			case MACRO_ENUM_ROLE_ASSAULT:  {LSTRING(role_assault) call BIS_fnc_localize};
			case MACRO_ENUM_ROLE_SUPPORT:  {LSTRING(role_support) call BIS_fnc_localize};
			case MACRO_ENUM_ROLE_ENGINEER: {LSTRING(role_engineer) call BIS_fnc_localize};
			case MACRO_ENUM_ROLE_MEDIC:    {LSTRING(role_medic) call BIS_fnc_localize};
			case MACRO_ENUM_ROLE_ANTITANK: {LSTRING(role_antitank) call BIS_fnc_localize};
			default                        {"ERROR: Unknown role"};
		});

		_strBody = format [
			LSTRING(tutorialHints_roleAbilities) call BIS_fnc_localize,
			MACRO_FNC_ADDHTMLCOLOUR(_roleName, "00FF00")
		];
		_strBody = _strBody + "<br/>";
		{
			_strBody = _strBody + "<br/><t align='left'>" + (_x # 0) + "</t><t align='center'>" + (_x # 1) + "</t>";
		} forEach _abilitiesText;

	// Fallback when no abilities were detected
	} else {
		_strBody = "TODO";
	};
};
