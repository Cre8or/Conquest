case MACRO_ENUM_TUTORIALHINT_MEDICAL_REVIVEFRIENDLY: {
	GVAR(ui_sys_drawTutorialHints_data) params ["_keyBindStr"];

	// Wrap the keybinding in brackets
	_keyBindStr = format ["[%1]", _keyBindStr];

	_strTitle = toUpper localize LSTRING(tutorialHints_medical_reviveFriendly_title);
	_strBody  = format [
		localize LSTRING(tutorialHints_medical_reviveFriendly_body),
		"<br/><br/>",
		MACRO_FNC_ADDHTMLCOLOUR(_keyBindStr, MACRO_COLOUR_HTML_GREEN)
	];
};
