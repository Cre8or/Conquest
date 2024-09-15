// Custom resource classes
class GVAR(RscFrame) : RscFrame {
	style = ST_LEFT;
	font = MACRO_FONT_UI_MEDIUM;
	sizeEx = 0.02 * safeZoneW;
	colorBackground[] = CURLY(MACRO_COLOUR_INGAME_BACKGROUND);
};

class GVAR(RscFrameFocused) : RscText {
	style = ST_MULTI;
	font = MACRO_FONT_UI_MEDIUM;
	colorText[] = CURLY(MACRO_COLOUR_A0);
	w = 0;
	h = 0;
};

class GVAR(RscOutline) : RscFrame {
	style = ST_WITH_RECT;
	colorBackground[] = CURLY(MACRO_COLOUR_A0);
};

class GVAR(RscPicture) : RscPicture {
	style = ST_PICTURE + ST_KEEP_ASPECT_RATIO;
};

class GVAR(RscPictureNoAR) : RscPicture {
	style = ST_PICTURE;
};

class GVAR(RscButton) : RscButton {
	font = MACRO_FONT_UI_MEDIUM;
	sizeEx = 0.02 * safeZoneW;
	colorBackground[] = CURLY(MACRO_COLOUR_A0);
	colorBackgroundActive[] = CURLY(MACRO_COLOUR_A0);
	colorDisabled[] = CURLY(MACRO_COLOUR_A0);
	colorBackgroundDisabled[] = CURLY(MACRO_COLOUR_A0);
};

class GVAR(RscText) : RscText {
	shadow = 2;
	style = ST_CENTER;
	font = MACRO_FONT_UI_MEDIUM;
	sizeEx = MACRO_UI_TEXTSIZE_1;
};

class GVAR(RscTextHeader) : GVAR(RscText) {
	style = ST_LEFT;
	disableOverflow = 1;
};

class GVAR(RscListBox) : RscListBox {
	disableOverflow = 1;
};

class GVAR(RscListNBox) : RscListNBox {
	idc = -1;
	default = 0;
	disableOverflow = 1;
	font = MACRO_FONT_UI_MEDIUM;
	sizeEx = 0.015 * safeZoneW;
	colorSelect[] = CURLY(MACRO_COLOUR_A100_BLACK);
	colorSelect2[] = CURLY(MACRO_COLOUR_A100_BLACK);
	colorSelectBackground[] = CURLY(MACRO_COLOUR_A100_WHITE);
	colorSelectBackground2[] = CURLY(MACRO_COLOUR_A100_WHITE);
};

class GVAR(RscEdit) : RscEdit {
	style = ST_SINGLE + ST_CENTER;
	font = MACRO_FONT_UI_MEDIUM;
	sizeEx = 0.015 * safeZoneW;
	maxChars = 32;
};





// Scripted controls
class GVAR(RscScoreFeed_Text) : GVAR(RscText) {
	style = ST_RIGHT;
	sizeEx = MACRO_POS_SF_ENTRY_TEXTSIZE;
};

class GVAR(RscScoreFeed_Text_Left) : GVAR(RscScoreFeed_Text) {
	style = ST_LEFT;
};

class GVAR(RscKillFeed_Name_Killer) : GVAR(RscText) {
	style = ST_RIGHT;
	sizeEx = MACRO_POS_KF_ENTRY_TEXTSIZE;
};
class GVAR(RscKillFeed_Name_Victim) : GVAR(RscKillFeed_Name_Killer) {
	style = ST_LEFT;
};





class RscTitles {

	// Empty display
        class Default {
                idd = -1;
                fadeIn = 0;
                fadeOut = 0;
                duration = 999999;
        };

	#include "rscTitles\rscBlackScreen.inc"
	#include "rscTitles\rscCombatArea.inc"
	#include "rscTitles\rscEndScreen.inc"
	#include "rscTitles\rscKillFeed.inc"
	#include "rscTitles\rscScoreBoard.inc"
	#include "rscTitles\rscScoreFeed.inc"
	#include "rscTitles\rscSectorHUD.inc"
	#include "rscTitles\rscHealthBar.inc"
	#include "rscTitles\rscHitEffect.inc"
	#include "rscTitles\rscSpawnStatus.inc"
	#include "rscTitles\rscUnconsciousHUD.inc"
};





#include "dialogs\rscSpawnMenu.inc"
#include "dialogs\rscUserInputBlocker.inc"
