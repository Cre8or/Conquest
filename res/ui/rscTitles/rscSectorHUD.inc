// Sector HUD
class GVAR(RscSectorHUD) {
	idd = -1;
	fadeIn = 0;
	fadeOut = 0;
	duration = 999999;
	movingEnable = 0;
	movingEnabled = 0;
	name = QGVAR(RscSectorHUD);
	onLoad = __EVAL(format ["uiNamespace setVariable ['%1', _this select 0]", QGVAR(RscSectorHUD)]);

	class controls {

		// Background Controls Group
		class Background_CtrlGrp : RscControlsGroupNoScrollbars {
			idc = MACRO_IDC_SHUD_CTRLGRP;
			x = safeZoneX + 0.5 * safezoneW - (MACRO_POS_SHUD_FLAG_WIDTH + MACRO_POS_SHUD_SIDE_WIDTH * 2) / 2;
			y = safeZoneY;
			w = MACRO_POS_SHUD_FLAG_WIDTH + MACRO_POS_SHUD_SIDE_WIDTH * 2;
			h = MACRO_POS_SHUD_HEIGHT;

			class controls {

				class Background : GVAR(RscFrame) {
					colorBackground[] = CURLY(MACRO_COLOUR_INGAME_BACKGROUND);
					w = MACRO_POS_SHUD_FLAG_WIDTH + MACRO_POS_SHUD_SIDE_WIDTH * 2;
					h = MACRO_POS_SHUD_HEIGHT;
				};

				class Sector_Letter_Text : GVAR(RscText) {
					idc = MACRO_IDC_SHUD_LETTER_TEXT;
					font = MACRO_FONT_UI_MEDIUM;
					text = "?";
					sizeEx = MACRO_POS_SHUD_TEXTSIZE;
					w = MACRO_POS_SHUD_SIDE_WIDTH;
					h = MACRO_POS_SHUD_HEIGHT;
				};

				class Sector_Flag : GVAR(RscPictureNoAR) {
					idc = MACRO_IDC_SHUD_FLAG_PICTURE;
					text = MACRO_TEXTURE_FLAG_EMPTY;
					x = MACRO_POS_SHUD_SIDE_WIDTH;
					w = MACRO_POS_SHUD_FLAG_WIDTH;
					h = MACRO_POS_SHUD_HEIGHT;
				};

				class Sector_Level_Back : GVAR(RscFrame) {
					idc = MACRO_IDC_SHUD_LEVEL_BACK;
					colorBackground[] = CURLY(MACRO_COLOUR_A100_WHITE);
					x = MACRO_POS_SHUD_FLAG_WIDTH + MACRO_POS_SHUD_SIDE_WIDTH;
					w = MACRO_POS_SHUD_SIDE_WIDTH;
					h = MACRO_POS_SHUD_HEIGHT;
				};

				class Sector_Level_Front : GVAR(RscFrame) {
					idc = MACRO_IDC_SHUD_LEVEL_FRONT;
					colorBackground[] = CURLY(MACRO_COLOUR_A100_SIDE_WEST);
					x = MACRO_POS_SHUD_FLAG_WIDTH + MACRO_POS_SHUD_SIDE_WIDTH;
					y = MACRO_POS_SHUD_HEIGHT;
					w = MACRO_POS_SHUD_SIDE_WIDTH;
				};

				class Sector_Lock_Icon : GVAR(RscPicture) {
					idc = MACRO_IDC_SHUD_LOCK_ICON;
					text = "res\images\sector_locked_full.paa";
					x = MACRO_POS_SHUD_FLAG_WIDTH + MACRO_POS_SHUD_SIDE_WIDTH;
					w = MACRO_POS_SHUD_SIDE_WIDTH;
					h = MACRO_POS_SHUD_HEIGHT;
				};
			};
		};
	};
};
