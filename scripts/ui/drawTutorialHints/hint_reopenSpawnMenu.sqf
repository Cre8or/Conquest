case MACRO_ENUM_TUTORIALHINT_REOPENSPAWNMENU: {
	GVAR(ui_sys_drawTutorialHints_data) params ["_keyBindStr"];

	// Wrap the keybinding in brackets
	_keyBindStr = format ["[%1]", _keyBindStr];

	_strTitle = toUpper localize LSTRING(tutorialHints_reopenSpawnMenu_title);
	_strBody  = format [
		localize LSTRING(tutorialHints_reopenSpawnMenu_body),
		MACRO_FNC_ADDHTMLCOLOUR(_keyBindStr, MACRO_COLOUR_HTML_GREEN)
	];
};
