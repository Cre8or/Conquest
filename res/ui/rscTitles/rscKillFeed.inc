// Kill Feed
class GVAR(RscKillFeed) {
	idd = -1;
	fadeIn = 0;
	fadeOut = 0;
	duration = 999999;
	movingEnable = 0;
	movingEnabled = 0;
	name = QGVAR(RscKillFeed);
	onLoad = __EVAL(format ["uiNamespace setVariable ['%1', _this select 0]", QGVAR(RscKillFeed)]);

	class controls {

		// Background Controls Group
		class Background_CtrlGrp : RscControlsGroupNoScrollbars {
			idc = MACRO_IDC_KF_CTRLGRP;
			x = safeZoneX + safeZoneW - MACRO_POS_KF_WIDTH;
			y = safeZoneY + MACRO_POS_KF_Y;
			w = MACRO_POS_KF_WIDTH;
			h = MACRO_POS_KF_ENTRY_HEIGHT * MACRO_POS_KF_ENTRY_MAXCOUNT;

			class controls {
				// Will be filled dynamically by script
			};
		};
	};
};
