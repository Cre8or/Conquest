// Combat Area
class GVAR(RscCombatArea) {
	idd = -1;
	fadeIn = 0;
	fadeOut = 0;
	duration = 999999;
	movingEnable = 0;
	movingEnabled = 0;
	name = QGVAR(RscCombatArea);
	onLoad = __EVAL(format ["uiNamespace setVariable ['%1', _this select 0]", QGVAR(RscCombatArea)]);

	class controls {

		class Background_CtrlGrp : RscControlsGroupNoScrollbars {
			idc = MACRO_IDC_CA_CTRLGRP;
			x = safeZoneX + safezoneW / 2 - MACRO_POS_CA_WIDTH / 2;
			y = safeZoneY + safezoneH / 4 - MACRO_POS_CA_HEIGHT / 2;
			w = MACRO_POS_CA_WIDTH;
			h = MACRO_POS_CA_HEIGHT;

			class controls {

				class Background : GVAR(RscFrame) {
					colorBackground[] = CURLY(MACRO_COLOUR_INGAME_BACKGROUND);
					x = 0;
					y = 0;
					w = MACRO_POS_CA_WIDTH;
					h = MACRO_POS_CA_HEIGHT;
				};

				class Warning_Title : GVAR(RscText) {
					style = ST_CENTER;
					text = "WARNING";
					sizeEx = MACRO_POS_CA_WARNING_TEXTSIZE;
					x = 0;
					y = 0;
					w = MACRO_POS_CA_WIDTH;
					h = MACRO_POS_CA_HEIGHT * 0.35;
					colorText[] = CURLY(MACRO_COLOUR_A100_RED);
				};

				class Warning_Message : GVAR(RscText) {
					style = ST_CENTER;
					text = "Return to the combat area!";
					sizeEx = MACRO_POS_CA_MESSAGE_TEXTSIZE;
					x = 0;
					y = MACRO_POS_CA_HEIGHT * 0.35;
					w = MACRO_POS_CA_WIDTH;
					h = MACRO_POS_CA_HEIGHT * 0.25;
				};

				class Countdown : GVAR(RscText) {
					idc = MACRO_IDC_CA_TEXT_COUNTDOWN;
					style = ST_CENTER;
					text = "99";
					sizeEx = MACRO_POS_CA_WARNING_TEXTSIZE;
					x = 0;
					y = MACRO_POS_CA_HEIGHT * 0.6;
					w = MACRO_POS_CA_WIDTH;
					h = MACRO_POS_CA_HEIGHT * 0.4;
				};
			};
		};
	};
};
