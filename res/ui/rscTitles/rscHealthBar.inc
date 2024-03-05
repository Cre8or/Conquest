// Health Bar
class GVAR(RscHealthBar) {
	idd = -1;
	fadeIn = 0;
	fadeOut = 0;
	duration = 999999;
	movingEnable = 0;
	movingEnabled = 0;
	name = QGVAR(RscHealthBar);
	onLoad = __EVAL(format ["uiNamespace setVariable ['%1', _this select 0]", QGVAR(RscHealthBar)]);

	class controls {

		class Background_CtrlGrp : RscControlsGroupNoScrollbars {
			idc = MACRO_IDC_HB_CTRLGRP;
			x = safeZoneX + safezoneW - MACRO_POS_HB_WIDTH;
			y = safeZoneY + safeZoneH - MACRO_POS_HB_HEIGHT;
			w = MACRO_POS_HB_WIDTH;
			h = MACRO_POS_HB_HEIGHT;

			class controls {

				class Background : GVAR(RscFrame) {
					colorBackground[] = CURLY(MACRO_COLOUR_INGAME_BACKGROUND);
					w = MACRO_POS_HB_WIDTH;
					h = MACRO_POS_HB_HEIGHT;
				};

				class Health_Icon : GVAR(RscPicture) {
					idc = MACRO_IDC_HB_HEALTH_ICON;
					shadow = 2;
					text = "a3\ui_f\data\GUI\Cfg\Cursors\add_gs.paa";
					x = MACRO_POS_HB_ICON_SPACER;
					y = 0;
					w = MACRO_POS_HB_ICON_WIDTH - 2 * MACRO_POS_HB_ICON_SPACER;
					h = MACRO_POS_HB_HEIGHT;
				};

				class Health_Text : GVAR(RscText) {
					idc = MACRO_IDC_HB_HEALTH_TEXT;
					style = ST_RIGHT;
					shadow = 2;
					font = MACRO_FONT_UI_MEDIUM;
					text = "ÒwÓ";
					sizeEx = MACRO_POS_HB_TEXTSIZE;
					x = MACRO_POS_HB_ICON_WIDTH;
					y = 0;
					w = MACRO_POS_HB_WIDTH - MACRO_POS_HB_ICON_WIDTH;
					h = MACRO_POS_HB_HEIGHT;
				};
			};
		};
	};
};
