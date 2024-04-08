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
			y = safeZoneY + safezoneH / 2 - MACRO_POS_CA_HEIGHT;
			w = MACRO_POS_CA_WIDTH;
			h = MACRO_POS_CA_HEIGHT;

			class controls {

				class Background : GVAR(RscFrame) {
					w = MACRO_POS_CA_WIDTH;
					h = MACRO_POS_CA_HEIGHT;
				};

				class Background_Title : Background {
					h = MACRO_POS_CA_HEIGHT * 0.3;
					colorBackground[] = CURLY(MACRO_COLOUR_A100_RED);
				};

				class Warning_Title : GVAR(RscText) {
					style = ST_CENTER;
					text = "WARNING";
					sizeEx = MACRO_UI_TEXTSIZE_4;
					w = MACRO_POS_CA_WIDTH;
					h = MACRO_POS_CA_HEIGHT * 0.3;
				};

				class Warning_Message : Warning_Title {
					text = "Return to the combat area!";
					sizeEx = MACRO_UI_TEXTSIZE_2;
					y = MACRO_POS_CA_HEIGHT * 0.3;
				};

				class Countdown : Warning_Title {
					idc = MACRO_IDC_CA_TEXT_COUNTDOWN;
					text = "99";
					y = MACRO_POS_CA_HEIGHT * 0.6; // Intentionally not filling out 100% of the remaining height
				};
			};
		};
	};
};
