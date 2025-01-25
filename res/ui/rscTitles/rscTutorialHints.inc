// Combat Area
class GVAR(RscTutorialHints) {
	idd = -1;
	fadeIn = 0;
	fadeOut = 0;
	duration = 999999;
	movingEnable = 0;
	movingEnabled = 0;
	name = QGVAR(RscTutorialHints);
	onLoad = __EVAL(format ["uiNamespace setVariable ['%1', _this select 0]", QGVAR(RscTutorialHints)]);

	class controls {

		class Background_CtrlGrp : RscControlsGroupNoScrollbars {
			idc = MACRO_IDC_TH_CTRLGRP;
			x = MACRO_POS_TH_X;
			y = MACRO_POS_TH_Y;
			w = MACRO_POS_TH_WIDTH;
			h = MACRO_POS_TH_WIDTH; // Overwritten by script

			class controls {

				class Background : GVAR(RscFrame) {
					idc = MACRO_IDC_TH_BACKGROUND;
					w = MACRO_POS_TH_WIDTH;
					h = 999;
					colorBackground[] = CURLY(MACRO_COLOUR_A75_BLACK);
				};

				class Progress_Bar : Background {
					idc = MACRO_IDC_TH_PROGRESS_BAR;
					colorBackground[] = CURLY(MACRO_COLOUR_A100_FRIENDLY);
					w = MACRO_POS_TH_TITLE_TEXTSIZE;
					h = MACRO_POS_TH_TITLE_TEXTSIZE;
				};

				class Icon : GVAR(RscPicture) {
					idc = MACRO_IDC_TH_ICON_PICTURE;
					text = "a3\ui_f\data\GUI\Rsc\RscDisplayMain\menu_tutorials_ca.paa";
					shadow = 1;
					w = MACRO_POS_TH_TITLE_TEXTSIZE * (3 / 4);
					h = MACRO_POS_TH_TITLE_TEXTSIZE;
				};

				class Title : GVAR(RscText) {
					idc = MACRO_IDC_TH_TITLE_TEXT;
					text = "HINT";
					sizeEx = MACRO_POS_TH_TITLE_TEXTSIZE;
					w = MACRO_POS_TH_WIDTH;
					h = MACRO_POS_TH_TITLE_TEXTSIZE;
				};

				class Title_Separator : GVAR(RscFrame) {
					idc = MACRO_IDC_TH_TITLE_SEPARATOR;
					colorBackground[] = CURLY(MACRO_COLOUR_A100_WHITE);
					x = pixelW * MACRO_POS_SPACER_X;
					y = MACRO_POS_TH_TITLE_TEXTSIZE + pixelH * MACRO_POS_SPACER_Y;
					w = MACRO_POS_TH_WIDTH - 2 * pixelW * MACRO_POS_SPACER_X;
					h = pixelH;
				};

				class Body : GVAR(RscStructuredText) {
					idc = MACRO_IDC_TH_BODY_TEXT;
					text = "This is a hint.<br/>It has multiple lines.<br/><br/>Wow.";
					sizeEx = MACRO_POS_TH_BODY_TEXTSIZE;
					y = MACRO_POS_TH_TITLE_TEXTSIZE + pixelH * (1 + 2 * MACRO_POS_SPACER_Y);
					w = MACRO_POS_TH_WIDTH;
					h = 999;
				};
			};
		};
	};
};
