// Reset the focus
case "ui_focus_reset": {
	_eventExists = true;

	// First, set the focus onto the role preview controls group's focus frame
	ctrlSetFocus (_spawnMenu displayCtrl MACRO_IDC_SM_ROLE_PREVIEW_FOCUS_FRAME);

	// Next, set the focus onto the main controls group's focus frame
	ctrlSetFocus (_spawnMenu displayCtrl MACRO_IDC_SM_FOCUS_FRAME);

	// Finally, shift the focus onto the dummy controls group's focus frame, to hide button highlighting
	ctrlSetFocus (_spawnMenu displayCtrl MACRO_IDC_SM_EMPTY_FOCUS_FRAME);
};
