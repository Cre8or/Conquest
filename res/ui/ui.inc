// Custom resource classes
class GVAR(RscFrame) : RscFrame {
	style = ST_LEFT;
	font = MACRO_FONT_UI_MEDIUM;
	sizeEx = 0.02 * safeZoneW;
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
	sizeEx = 0.015 * safeZoneW;
};

class GVAR(RscTextHeader) : GVAR(RscText) {
	style = ST_LEFT;
	shadow = 2;
};

class GVAR(RscListBox) : RscListBox {

};

class GVAR(RscListNBox) : RscListNBox {
	idc = -1;
	default = 0;
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
	font = MACRO_FONT_UI_MEDIUM;
	sizeEx = MACRO_POS_SF_ENTRY_TEXTSIZE;
	shadow = 2;
};

class GVAR(RscKillFeed_Name_Killer) : GVAR(RscText) {
	style = ST_LEFT;
	font = MACRO_FONT_UI_MEDIUM;
	sizeEx = MACRO_POS_KF_ENTRY_TEXTSIZE;
	shadow = 2;
};
class GVAR(RscKillFeed_Name_Victim) : GVAR(RscKillFeed_Name_Killer) {
	style = ST_RIGHT;
};





class RscTitles {

	// Empty display
        class Default {
                idd = -1;
                fadeIn = 0;
                fadeOut = 0;
                duration = 999999;
        };

	// Black Screen
	#include "rscTitles\rscBlackScreen.inc"

	// Combat Area
	#include "rscTitles\rscCombatArea.inc"

	// End Screen
	#include "rscTitles\rscEndScreen.inc"

	// Kill Feed
	#include "rscTitles\rscKillFeed.inc"

	// Score Feed
	#include "rscTitles\rscScoreFeed.inc"

	// Sector HUD
	#include "rscTitles\rscSectorHUD.inc"

	// Health Bar
	#include "rscTitles\rscHealthBar.inc"

	// Hit Effect
	#include "rscTitles\rscHitEffect.inc"

	// Spawn Status
	#include "rscTitles\rscSpawnStatus.inc"
};





// Spawn Menu
#include "dialogs\rscSpawnMenu.inc"

// User Input Blocker
#include "dialogs\rscUserInputBlocker.inc"
