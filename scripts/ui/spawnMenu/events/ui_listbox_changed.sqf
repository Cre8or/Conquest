// Listbox selection changed
case "ui_listbox_changed": {
	_eventExists = true;

	// Fetch the params
	_args params ["_ctrl", "_index"];

	// Determine what to do based on which listbox raised the event
	switch (ctrlIDC _ctrl) do {

		// Groups Listbox
		case MACRO_IDC_SM_GROUP_GROUPS_LISTBOX: {
			_spawnMenu setVariable [QGVAR(menuRole_selectedGroup),
				(_spawnMenu getVariable [QGVAR(menuRole_groups), []]) param [_index, grpNull]
			];

			// Reset the member listbox selection
			(_spawnMenu displayCtrl MACRO_IDC_SM_GROUP_MEMBERS_LISTBOX) lnbSetCurSelRow -1;

			["ui_update_role"] call FUNC(ui_spawnMenu);
		};
	};
};
