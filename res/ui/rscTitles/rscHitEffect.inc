// Hit Effect
class GVAR(RscHitEffect) {
	idd = -1;
	fadeIn = 0;
	fadeOut = 0;
	duration = 999999;
	movingEnable = 0;
	movingEnabled = 0;
	name = QGVAR(RscHitEffect);
	onLoad = __EVAL(format ["uiNamespace setVariable ['%1', _this select 0]", QGVAR(RscHitEffect)]);

	class controls {

		class Background_CtrlGrp : RscControlsGroupNoScrollbars {
			idc = MACRO_IDC_HFX_CTRLGRP;
			x = 0.5 - MACRO_POS_HFX_WIDTH / 2;
			y = 0.5 - MACRO_POS_HFX_HEIGHT / 2;
			w = MACRO_POS_HFX_WIDTH;
			h = MACRO_POS_HFX_HEIGHT;

			class controls {

				class Hit_Effect_Image : GVAR(RscPicture) {
					idc = MACRO_IDC_HFX_HIT_EFFECT_IMAGE;
					text = "res\images\splatter.paa";
					x = 0;
					y = 0;
					w = MACRO_POS_HFX_WIDTH;
					h = MACRO_POS_HFX_HEIGHT;
				};
			};
		};
	};
};
