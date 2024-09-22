case "ui_request_cursor": {
	_eventExists = true;





	if (!GVAR(ui_scoreBoard_isDialog)) then {
		["ui_init", true] call FUNC(ui_scoreBoard);
	};
};
