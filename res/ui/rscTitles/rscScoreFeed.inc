// Score Feed
class GVAR(RscScoreFeed) {
	idd = -1;
	fadeIn = 0;
	fadeOut = 0;
	duration = 999999;
	movingEnable = 0;
	movingEnabled = 0;
	name = QGVAR(RscScoreFeed);
	onLoad = __EVAL(format ["uiNamespace setVariable ['%1', _this select 0]", QGVAR(RscScoreFeed)]);

	class controls {

		// Background Controls Group
		class Background_CtrlGrp : RscControlsGroupNoScrollbars {
			idc = MACRO_IDC_SF_CTRLGRP;
			x = 0.5 - MACRO_POS_SF_WIDTH / 2;
			y = 0.7;
			w = MACRO_POS_SF_WIDTH;
			h = MACRO_POS_SF_ENTRY_TEXTSIZE * MACRO_POS_SF_ENTRY_MAXCOUNT;

			class controls {
				// Will be filled dynamically by script
			};
		};
	};
};
