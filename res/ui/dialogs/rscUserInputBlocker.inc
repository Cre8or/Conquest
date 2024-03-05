// User Input Blocker
class GVAR(RscUserInputBlocker) {
        idd = -1;
        name = QGVAR(RscUserInputBlocker);
	onLoad = __EVAL(format ["uiNamespace setVariable ['%1', _this select 0]", QGVAR(RscUserInputBlocker)]);

        class controls {

		// Focus Frame
		class Focus_Frame  : GVAR(RscFrameFocused) {
			idc = MACRO_IDC_UIB_FOCUS_FRAME;
		};
	};
};
