// Sector HUD
class GVAR(RscScoreBoard) {
	idd = -1;
	fadeIn = 0;
	fadeOut = 0;
	duration = 999999;
	movingEnable = 0;
	movingEnabled = 0;
	name = QGVAR(RscScoreBoard);
	onLoad = __EVAL(format ["uiNamespace setVariable ['%1', _this select 0]", QGVAR(RscScoreBoard)]);

	class controls {

		// Background Controls Group
		class Background_CtrlGrp : RscControlsGroupNoScrollbars {
			idc = MACRO_IDC_SB_CTRLGRP;
			x = safeZoneX + safezoneW / 2 - MACRO_POS_SB_WIDTH_COLUMN * 3 / 2;
			y = safeZoneY + safezoneH / 2 - MACRO_POS_SB_HEIGHT / 2;
			w = MACRO_POS_SB_WIDTH_COLUMN * 3;
			h = MACRO_POS_SB_HEIGHT;

			class controls {

				class Background : GVAR(RscFrame) {
					w = 3 * MACRO_POS_SB_WIDTH_COLUMN;
					h = MACRO_POS_SB_HEIGHT;
					colorBackground[] = CURLY(MACRO_COLOUR_A75_BLACK);
				};

				// Focus Frame
				class Focus_Frame  : GVAR(RscFrameFocused) {
					idc = MACRO_IDC_SB_FOCUS_FRAME;
				};

				// Side Name Text, Left
				class Side_Name_Left : GVAR(RscText) {
					idc = MACRO_IDC_SB_SIDE_NAME_LEFT_TEXT;
					shadow = 2;
					text = "SIDE NAME";
					sizeEx = MACRO_POS_SB_SIDE_NAME_TEXTSIZE;
					x = 0;
					y = 0;
					w = MACRO_POS_SB_WIDTH_COLUMN;
					h = MACRO_POS_SB_SIDE_NAME_TEXTSIZE;
				};

				// Side Name Text, Middle
				class Side_Name_Middle : Side_Name_Left {
					idc = MACRO_IDC_SB_SIDE_NAME_MIDDLE_TEXT;
					x = MACRO_POS_SB_WIDTH_COLUMN;
				};

				// Side Name Text, Right
				class Side_Name_Right : Side_Name_Left {
					idc = MACRO_IDC_SB_SIDE_NAME_RIGHT_TEXT;
					x = 2 * MACRO_POS_SB_WIDTH_COLUMN;
				};

				class Side_Name_Left_Separator : GVAR(RscFrame) {
					idc = -1
					colorBackground[] = CURLY(MACRO_COLOUR_A100_WHITE);
					x = pixelW * MACRO_POS_SPACER_X;
					y = MACRO_POS_SB_SIDE_NAME_TEXTSIZE + pixelH * MACRO_POS_SPACER_Y;
					w = MACRO_POS_SB_WIDTH_COLUMN - 2 * pixelW * MACRO_POS_SPACER_X;
					h = pixelH;
				};

				class Side_Name_Middle_Separator : Side_Name_Left_Separator {
					//idc = -1;
					x = MACRO_POS_SB_WIDTH_COLUMN + pixelW * MACRO_POS_SPACER_X;
				};

				class Side_Name_Right_Separator : Side_Name_Left_Separator {
					//idc = -1;
					x = 2 * MACRO_POS_SB_WIDTH_COLUMN + pixelW * MACRO_POS_SPACER_X;
				};

				class Vertical_Separator_1 : Side_Name_Left_Separator {
					x = MACRO_POS_SB_WIDTH_COLUMN;
					y = pixelH * MACRO_POS_SPACER_Y;
					w = pixelW;
					h = MACRO_POS_SB_HEIGHT - 2 * pixelH * MACRO_POS_SPACER_Y;
				};

				class Vertical_Separator_2 : Vertical_Separator_1 {
					x = 2 * MACRO_POS_SB_WIDTH_COLUMN;
				};
			};
		};
	};
};
