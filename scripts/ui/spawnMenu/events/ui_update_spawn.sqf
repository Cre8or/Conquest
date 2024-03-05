// Update the spawn button
case "ui_update_spawn": {
	_eventExists = true;

	private _buttonSpawn = _spawnMenu displayCtrl MACRO_IDC_SM_SPAWN_FRAME;

	if (
		GVAR(side) != sideEmpty
		and {GVAR(role) != MACRO_ENUM_ROLE_INVALID}
		and {GVAR(side) == GVAR(spawnSector) getVariable [QGVAR(side), sideEmpty]}
	) then {
		_buttonSpawn ctrlSetBackgroundColor SQUARE(MACRO_COLOUR_BUTTON_ACTIVE);

	} else {
		_buttonSpawn ctrlSetBackgroundColor SQUARE(MACRO_COLOUR_BUTTON_INACTIVE);

		GVAR(spawnSector) = objNull;
	};
};
