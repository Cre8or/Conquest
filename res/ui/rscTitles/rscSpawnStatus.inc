// Spawn Status
class GVAR(RscSpawnStatus) {
	idd = -1;
	fadeIn = 0;
	fadeOut = 0;
	duration = 999999;
	movingEnable = 0;
	movingEnabled = 0;
	name = QGVAR(RscSpawnStatus);
	onLoad = __EVAL(format ["uiNamespace setVariable ['%1', _this select 0]", QGVAR(RscSpawnStatus)]);

	class controls {

		class CtrlGrp : RscControlsGroupNoScrollbars {
			idc = MACRO_IDC_SS_CTRLGRP;
			x = 0;
			y = 0.45;
			w = 1;
			h = 0.1;

			class controls {

				// Status Text
				class Status_Text : GVAR(RscText) {
					idc = MACRO_IDC_SS_STATUS_TEXT;
					shadow = 2;
					font = MACRO_FONT_UI_MEDIUM;
					text = "Hello yes this is spawn status";
					sizeEx = 0.07;
					x = 0;
					y = 0;
					w = 1;
					h = 0.1;
				};
			};
		};
	};
};
