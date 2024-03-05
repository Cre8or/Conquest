// Sector HUD
class GVAR(RscEndScreen) {
	idd = -1;
	fadeIn = 1;
	fadeOut = 0;
	duration = 999999;
	movingEnable = 0;
	movingEnabled = 0;
	name = QGVAR(RscEndScreen);
	onLoad = __EVAL(format ["uiNamespace setVariable ['%1', _this select 0]", QGVAR(RscEndScreen)]);

	class controls {

		// Background Controls Group
		class Background_CtrlGrp : RscControlsGroupNoScrollbars {
			idc = MACRO_IDC_ES_CTRLGRP;
			x = 0;
			y = 0;
			w = 1;
			h = 1;

			class controls {

				// Top Text
				class Top_Text : GVAR(RscText) {
					idc = MACRO_IDC_ES_TOP_TEXT;
					shadow = 2;
					font = MACRO_FONT_UI_MEDIUM;
					text = "BAMBOOZLED";
					sizeEx = MACRO_POS_ES_TOP_TEXTSIZE;
					x = 0;
					y = 0.1;
					w = 1;
					h = 0.1;
				};

				// Flag Picture, Left
				class Flag_Picture_Left : GVAR(RscPictureNoAR) {
					idc = MACRO_IDC_ES_FLAG_LEFT_PICTURE;
					text = "a3\data_f\Flags\flag_white_co.paa";
					x = 0;
					y = 0.3;
					w = 0.3;
					h = 0.25;
				};

				// Flag Picture, Middle
				class Flag_Picture_Middle : Flag_Picture_Left {
					idc = MACRO_IDC_ES_FLAG_MIDDLE_PICTURE;
					x = 0.35;
				};

				// Flag Picture, Right
				class Flag_Picture_Right : Flag_Picture_Left {
					idc = MACRO_IDC_ES_FLAG_RIGHT_PICTURE;
					x = 0.7;
				};

				// Tickets Text, Left
				class Tickets_Left : GVAR(RscText) {
					idc = MACRO_IDC_ES_TICKETS_LEFT_TEXT;
					shadow = 2;
					text = "0";
					sizeEx = MACRO_POS_ES_TICKETS_TEXTSIZE;
					x = 0;
					y = 0.55;
					w = 0.3;
					h = 0.1;
				};

				// Tickets Text, Middle
				class Tickets_Middle : Tickets_Left {
					idc = MACRO_IDC_ES_TICKETS_MIDDLE_TEXT;
					x = 0.35;
				};

				// Tickets Text, Right
				class Tickets_Right : Tickets_Left {
					idc = MACRO_IDC_ES_TICKETS_RIGHT_TEXT;
					x = 0.7;
				};

				// Top Text
				class Bottom_Text : Top_Text {
					idc = MACRO_IDC_ES_BOTTOM_TEXT;
					text = "IDAP WINS";
					y = 0.7;
				};

			};
		};
	};
};
