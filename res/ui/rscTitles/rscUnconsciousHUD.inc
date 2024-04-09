// Unconscious HUD
class GVAR(RscUnconsciousHUD) {
	idd = -1;
	fadeIn = 0;
	fadeOut = 0;
	duration = 999999;
	movingEnable = 0;
	movingEnabled = 0;
	name = QGVAR(RscUnconsciousHUD);
	onLoad = __EVAL(format ["uiNamespace setVariable ['%1', _this select 0]", QGVAR(RscUnconsciousHUD)]);

	class controls {

		class Background_CtrlGrp : RscControlsGroupNoScrollbars {
			idc = MACRO_IDC_UHUD_CTRLGRP;
			x = safeZoneX + safezoneW / 2 - MACRO_POS_UHUD_WIDTH / 2;
			y = safeZoneY + safezoneH / 2 - MACRO_POS_UHUD_HEIGHT;
			w = MACRO_POS_UHUD_WIDTH;
			h = MACRO_POS_UHUD_HEIGHT;

			class controls {

				class Background : GVAR(RscFrame) {
					w = MACRO_POS_UHUD_WIDTH;
					h = MACRO_POS_UHUD_HEIGHT;
				};

				class Title : GVAR(RscText) {
					style = ST_CENTER;
					text = "UNCONSCIOUS";
					sizeEx = MACRO_UI_TEXTSIZE_3;
					w = MACRO_POS_UHUD_WIDTH;
					h = MACRO_POS_UHUD_HEIGHT * 0.25;
				};

				class Countdown : Title {
					idc = MACRO_IDC_UHUD_TEXT_COUNTDOWN;
					text = "99";
					sizeEx = MACRO_UI_TEXTSIZE_4;
					y = MACRO_POS_UHUD_HEIGHT * 0.25;
					h = MACRO_POS_UHUD_HEIGHT * 0.35;
				};

				class Medic_None_Text : Title {
					idc = MACRO_IDC_UHUD_TEXT_MEDIC_NONE;
					text = "No medic nearby";
					sizeEx = MACRO_POS_UHUD_MEDIC_TEXTSIZE;
					y = MACRO_POS_UHUD_HEIGHT * 0.6;
					h = MACRO_POS_UHUD_HEIGHT * 0.2;
				};

				class Medic_Distance_Text : Medic_None_Text {
					idc = MACRO_IDC_UHUD_TEXT_MEDIC_DISTANCE;
					style = ST_RIGHT;
					text = "Nearest medic (99 m): nobody lol ur screwed";
				};

				class Medic_Name_Text : Medic_None_Text {
					idc = MACRO_IDC_UHUD_TEXT_MEDIC_NAME;
					style = ST_LEFT;
					text = "";
				};

				class Give_Up_Text : Medic_None_Text {
					idc = MACRO_IDC_UHUD_TEXT_GIVE_UP;
					text = "Hold [my beer], I'll do a backflip";
					y = MACRO_POS_UHUD_HEIGHT * 0.8;
				};
			};
		};
	};
};
