// Mouse moved
case "ui_mouse_moving": {
	_eventExists = true;

	_args params ["_ctrl", "_mouseX", "_mouseY", "_mouseOver"];





	// Determine what to do based on the control that is firing this event
	switch (ctrlIDC _ctrl) do {

		// Role Preview Frame
		case MACRO_IDC_SM_ROLE_PREVIEW_FRAME: {

			// Only continue if we should be moving
			if (_spawnMenu getVariable [QGVAR(rolePreview_isMouseMoving), false]) then {

				private _dir = _spawnMenu getVariable [QGVAR(rolePreview_unitDir), direction GVAR(rt_role_unit)];
				private _startX = _spawnMenu getVariable [QGVAR(rolePreview_mouseX), 0];
				private _startY = _spawnMenu getVariable [QGVAR(rolePreview_mouseY), 0];
				private _startPosZ = _spawnMenu getVariable [QGVAR(rolePreview_unitPosZBase), 0];
				private _fovMul = (MACRO_SM_ROLEPREVIEW_BASEFOV + GVAR(cam_role_curFov) * 5) / (MACRO_SM_ROLEPREVIEW_BASEFOV * 6);
				private _newPosZ = ((_startPosZ + (_startY - _mouseY) * 1 * _fovMul) min -0.6) max -1.6;

				// Rotate the unit
				GVAR(rt_role_unit) setDir (_dir + (_startX - _mouseX) * 200 * _fovMul);

				// Move the unit
				GVAR(rt_role_unit) attachTo [GVAR(rt_role_wall), [0, 15, _newPosZ]];
				_spawnMenu setVariable [QGVAR(rolePreview_unitPosZ), _newPosZ];
			};

			// Toggle the controls text
			(_spawnMenu displayCtrl MACRO_IDC_SM_ROLE_PREVIEW_CONTROLS_TEXT) ctrlSetTextColor ([SQUARE(MACRO_COLOUR_A0), SQUARE(MACRO_COLOUR_A100_WHITE)] select _mouseOver);
		};
	};
};
