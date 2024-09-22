case "ui_close": {
	_eventExists = true;

	_args params [
		["_forced", false, [false]]
	];





	removeMissionEventHandler ["EachFrame", GVAR(ui_scoreBoard_EH)];

	// If this event is being forced, manually close the scorebard
	if (_forced) then {

		// Prevent recursive firing of the unload events handler
		_scoreBoard displayRemoveAllEventHandlers "Unload";

		if (GVAR(ui_scoreBoard_isDialog)) then {
			_scoreBoard closeDisplay 0;
		} else {
			QGVAR(RscScoreBoard) cutRsc ["Default", "PLAIN"];
		};
	};
};
