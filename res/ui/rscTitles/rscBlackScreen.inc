// Black Screen
class GVAR(RscBlackScreenIn) {
	idd = -1;
	fadeIn = 1;
	fadeOut = 0;
	duration = 999999;
	movingEnable = 0;
	movingEnabled = 0;
	name = QGVAR(RscBlackScreenIn);
	onLoad = __EVAL(format ["uiNamespace setVariable ['%1', _this select 0]", QGVAR(RscBlackScreenIn)]);

	class controls {

		class Background : GVAR(RscFrame) {
			idc = MACRO_IDC_BS_BACKGROUND;
			colorBackground[] = CURLY(MACRO_COLOUR_A100_BLACK);
			x = safeZoneXAbs;
			y = safeZoneY;
			w = safeZoneWAbs;
			h = safeZoneH;
		};
	};
};

class GVAR(RscBlackScreenOut) : GVAR(RscBlackScreenIn) {
	fadeIn = 0;
	fadeOut = 1;
	duration = 0;
	name = QGVAR(RscBlackScreenOut);
	onLoad = __EVAL(format ["uiNamespace setVariable ['%1', _this select 0]", QGVAR(RscBlackScreenOut)]);
};
