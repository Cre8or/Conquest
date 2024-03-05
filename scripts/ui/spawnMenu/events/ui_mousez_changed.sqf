// Mouse wheel moved
case "ui_mousez_changed": {
	_eventExists = true;

	// Fetch the params
	_args params ["_ctrl", "_mouseZ"];





	// Determine what to do based on the control that is firing this event
	switch (ctrlIDC _ctrl) do {

		// Role Preview Frame
		case MACRO_IDC_SM_ROLE_PREVIEW_FRAME: {

			// Change the camera's FOV
			GVAR(cam_role_curFov) = ((GVAR(cam_role_curFov) * exp (-_mouseZ / 6)) min MACRO_SM_ROLEPREVIEW_BASEFOV) max 0.01;
			GVAR(cam_role) camSetFov GVAR(cam_role_curFov);
		};
	};
};
