#include "..\..\macros\fnc_addRoleCtrls.inc"





// Spawn Menu
class GVAR(RscSpawnMenu) {
	idd = -1;
	name = QGVAR(RscSpawnMenu);
	onLoad = __EVAL(format ["uiNamespace setVariable ['%1', _this select 0]", QGVAR(RscSpawnMenu)]);

	class controls {

		// Background Controls Group
		class Background_CtrlGrp : RscControlsGroupNoScrollbars {
			idc = MACRO_IDC_SM_CTRLGROUP;
			x = safeZoneX + (1 - MACRO_POS_SM_WIDTH / safezoneW) * (safezoneW / 2);
			y = safeZoneY + (1 - MACRO_POS_SM_HEIGHT / safezoneH) * (safezoneH / 2);
			w = MACRO_POS_SM_WIDTH;
			h = MACRO_POS_SM_HEIGHT;
			onChar = __EVAL(format ["['ui_char_entered', _this] call %1", QFUNC(ui_spawnMenu)]);

			class controls {

				// Background
				class Background : GVAR(RscFrameFocused) { // Has to be RscFrameFocused for the UI events to fire
					idc = MACRO_IDC_SM_BACKGROUND;
					colorBackground[] = CURLY(MACRO_COLOUR_A75_BLACK);
					w = MACRO_POS_SM_WIDTH;
					h = MACRO_POS_SM_HEIGHT;
					onMouseButtonDown     = __EVAL(format ["['ui_focus_reset'] call %1", QFUNC(ui_spawnMenu)]);
					onMouseButtonDblClick = __EVAL(format ["['ui_focus_reset'] call %1", QFUNC(ui_spawnMenu)]);
				};

				// Focus Frame
				class Focus_Frame  : GVAR(RscFrameFocused) {
					idc = MACRO_IDC_SM_FOCUS_FRAME;
				};

				class Menu_Separator : GVAR(RscFrame) {
					idc = MACRO_IDC_SM_MENU_SEPARATOR; // This control needs an IDC for some reason, otherwise it won't show (perhaps because it's the first RscFrame?)
					colorBackground[] = CURLY(MACRO_COLOUR_A100_WHITE);
					x = 0;
					y = MACRO_POS_SM_MENU_HEIGHT + pixelH * MACRO_POS_SPACER_Y;
					w = MACRO_POS_SM_WIDTH;
					h = pixelH;
				};

				// Side Button Frame
				class Side_Button_Frame : GVAR(RscFrame) {
					idc = MACRO_IDC_SM_SIDE_FRAME;
					colorBackground[] = CURLY(MACRO_COLOUR_BUTTON_ACTIVE);
					x = pixelW * MACRO_POS_SPACER_X;
					y = MACRO_POS_SM_MENU_HEIGHT + pixelH * (MACRO_POS_SPACER_Y * 2 + 1);
					w = safeZoneW * 0.1 - pixelW * MACRO_POS_SPACER_X;
					h = (MACRO_POS_SM_HEIGHT - MACRO_POS_SM_MENU_HEIGHT) - pixelH * (MACRO_POS_SPACER_Y * 3 + 1);
				};

				// Side Button
				class Side_Button : GVAR(RscButton) {
					idc = MACRO_IDC_SM_SIDE_BUTTON;
					text = "SIDE";
					x = pixelW * MACRO_POS_SPACER_X;
					y = MACRO_POS_SM_MENU_HEIGHT + pixelH * (MACRO_POS_SPACER_Y * 2 + 1);
					w = safeZoneW * 0.1 - pixelW * MACRO_POS_SPACER_X;
					h = (MACRO_POS_SM_HEIGHT - MACRO_POS_SM_MENU_HEIGHT) - pixelH * (MACRO_POS_SPACER_Y * 3 + 1);
					onButtonClick         = __EVAL(format ["['ui_button_click', _this] call %1", QFUNC(ui_spawnMenu)]);
					onButtonDown          = __EVAL(format ["['ui_focus_reset'] call %1", QFUNC(ui_spawnMenu)]);
					onMouseButtonDblClick = __EVAL(format ["['ui_focus_reset'] call %1", QFUNC(ui_spawnMenu)]);
				};

				// Role Button Frame
				class Role_Button_Frame : Side_Button_Frame {
					idc = MACRO_IDC_SM_ROLE_FRAME;
					x = safeZoneW * 0.1 + pixelW * MACRO_POS_SPACER_X;
				};

				// Role Button
				class Role_Button : Side_Button {
					idc = MACRO_IDC_SM_ROLE_BUTTON;
					text = "ROLE";
					x = safeZoneW * 0.1 + pixelW * MACRO_POS_SPACER_X;
				};

				// Deploy Button Frame
				class Deploy_Button_Frame : Side_Button_Frame {
					idc = MACRO_IDC_SM_DEPLOY_FRAME;
					x = safeZoneW * 0.2 + pixelW * MACRO_POS_SPACER_X;
				};

				// Deploy Button
				class Deploy_Button : Side_Button {
					idc = MACRO_IDC_SM_DEPLOY_BUTTON;
					text = "DEPLOYMENT";
					x = safeZoneW * 0.2 + pixelW * MACRO_POS_SPACER_X;
				};

				// Spawn Button Frame
				class Spawn_Button_Frame : Side_Button_Frame {
					idc = MACRO_IDC_SM_SPAWN_FRAME;
					colorBackground[] = CURLY(MACRO_COLOUR_BUTTON_INACTIVE);
					x = MACRO_POS_SM_WIDTH - safeZoneW * 0.1;
				};

				// Spawn Button
				class Spawn_Button : Side_Button {
					idc = MACRO_IDC_SM_SPAWN_BUTTON;
					text = "SPAWN";
					x = MACRO_POS_SM_WIDTH - safeZoneW * 0.1;
				};
			};
				};

		// ------------------------------------------------------------------------------------------------------------------------------------------------
		// Side Control Group
		class Side_CtrlGrp : Background_CtrlGrp {
			idc = MACRO_IDC_SM_SIDE_CTRLGROUP;
					h = MACRO_POS_SM_MENU_HEIGHT;

			class controls {

				// Flag, Left
				class Flag_Picture_Left : GVAR(RscPictureNoAR) {
					idc = MACRO_IDC_SM_SIDE_FLAG_LEFT_PICTURE;
					text = MACRO_TEXTURE_FLAG_EMPTY;
					x = pixelW * MACRO_POS_SPACER_X;
					y = pixelH * MACRO_POS_SPACER_Y;
					w = MACRO_POS_SM_WIDTH / 3 - pixelW * (MACRO_POS_SPACER_X * 2 + 1);
					h = MACRO_POS_SM_MENU_HEIGHT * (0.32 - 0.05) - pixelH * MACRO_POS_SPACER_Y;
				};

				// Flag Gradient, Left
				class Flag_Gradient_Left : GVAR(RscPictureNoAR) {
					idc = MACRO_IDC_SM_SIDE_FLAG_LEFT_GRADIENT;
					text = "a3\ui_f\data\GUI\Rsc\RscDisplayFieldManual\gradient_ca.paa";
					colorText[] = CURLY(MACRO_COLOUR_A100_BLACK);
					x = pixelW * MACRO_POS_SPACER_X;
					y = MACRO_POS_SM_MENU_HEIGHT * (0.32 - 0.15);
					w = MACRO_POS_SM_WIDTH / 3 - pixelW * (MACRO_POS_SPACER_X * 2 + 1);
					h = MACRO_POS_SM_MENU_HEIGHT * 0.1;
				};

				// Flag Fill, Left
				class Flag_Fill_Left : GVAR(RscFrame) {
					idc = MACRO_IDC_SM_SIDE_FLAG_LEFT_FILL;
					colorBackground[] = CURLY(MACRO_COLOUR_A100_BLACK);
					x = pixelW * MACRO_POS_SPACER_X;
					y = MACRO_POS_SM_MENU_HEIGHT * (0.32 - 0.05);
					w = MACRO_POS_SM_WIDTH / 3 - pixelW * (MACRO_POS_SPACER_X * 2 + 1);
					h = MACRO_POS_SM_MENU_HEIGHT * 0.05 - pixelH * MACRO_POS_SPACER_Y;
				};

				// Flag Fill Separator, Left
				class Flag_Fill_Separator_Left : GVAR(RscFrame) {
					idc = MACRO_IDC_SM_SIDE_FLAG_LEFT_SEPARATOR;
					colorBackground[] = CURLY(MACRO_COLOUR_A100_WHITE);
					x = MACRO_POS_SM_WIDTH * (1 / 6) - pixelW;
					y = MACRO_POS_SM_MENU_HEIGHT * (0.32 - 0.05);
					w = pixelW;
					h = MACRO_POS_SM_MENU_HEIGHT * 0.05 - pixelH * MACRO_POS_SPACER_Y;
				};

				// Separator, Left
				class Separator_Left : GVAR(RscFrame) {
					colorBackground[] = CURLY(MACRO_COLOUR_A100_WHITE);
					x = MACRO_POS_SM_WIDTH / 3 - pixelW;
					y = 0;
					w = pixelW;
					h = MACRO_POS_SM_MENU_HEIGHT;
				};

				// Flag, Middle
				class Flag_Picture_Middle : Flag_Picture_Left {
					idc = MACRO_IDC_SM_SIDE_FLAG_MIDDLE_PICTURE;
					x = MACRO_POS_SM_WIDTH / 3 + pixelW * MACRO_POS_SPACER_X;
					w = MACRO_POS_SM_WIDTH / 3 - pixelW * MACRO_POS_SPACER_X * 2;
				};

				// Flag Gradient, Middle
				class Flag_Gradient_Middle : Flag_Gradient_Left {
					idc = MACRO_IDC_SM_SIDE_FLAG_MIDDLE_GRADIENT;
					x = MACRO_POS_SM_WIDTH / 3 + pixelW * MACRO_POS_SPACER_X;
					w = MACRO_POS_SM_WIDTH / 3 - pixelW * MACRO_POS_SPACER_X * 2;
				};

				// Flag Fill, Middle
				class Flag_Fill_Middle : Flag_Fill_Left {
					idc = MACRO_IDC_SM_SIDE_FLAG_MIDDLE_FILL;
					x = MACRO_POS_SM_WIDTH / 3 + pixelW * MACRO_POS_SPACER_X;
					w = MACRO_POS_SM_WIDTH / 3 - pixelW * MACRO_POS_SPACER_X * 2;
				};

				// Flag Fill Separator, Middle
				class Flag_Fill_Separator_Middle : Flag_Fill_Separator_Left {
					idc = MACRO_IDC_SM_SIDE_FLAG_MIDDLE_SEPARATOR;
					x = MACRO_POS_SM_WIDTH * (3 / 6) - pixelW;
				};

				// Separator, Right
				class Separator_Right : GVAR(RscFrame) {
					colorBackground[] = CURLY(MACRO_COLOUR_A100_WHITE);
					x = MACRO_POS_SM_WIDTH * (2 / 3);
					y = 0;
					w = pixelW;
					h = MACRO_POS_SM_MENU_HEIGHT;
				};

				// Flag, Right
				class Flag_Picture_Right : Flag_Picture_Left {
					idc = MACRO_IDC_SM_SIDE_FLAG_RIGHT_PICTURE;
					x = MACRO_POS_SM_WIDTH * (2 / 3) + pixelW * (MACRO_POS_SPACER_X + 1);
				};

				// Flag Gradient, Right
				class Flag_Gradient_Right : Flag_Gradient_Left {
					idc = MACRO_IDC_SM_SIDE_FLAG_RIGHT_GRADIENT;
					x = MACRO_POS_SM_WIDTH * (2 / 3) + pixelW * (MACRO_POS_SPACER_X + 1);
				};

				// Flag Fill, Right
				class Flag_Fill_Right : Flag_Fill_Left {
					idc = MACRO_IDC_SM_SIDE_FLAG_RIGHT_FILL;
					x = MACRO_POS_SM_WIDTH * (2 / 3) + pixelW * MACRO_POS_SPACER_X;
				};

				// Flag Fill Separator, Right
				class Flag_Fill_Separator_Right : Flag_Fill_Separator_Left {
					idc = MACRO_IDC_SM_SIDE_FLAG_RIGHT_SEPARATOR;
					x = MACRO_POS_SM_WIDTH * (5 / 6) - pixelW;
				};

				// ------------------------------------------------------------------------------------------------------------------------------------------------
				// Side Name, Left
				class Side_Name_Left : GVAR(RscText) {
					idc = MACRO_IDC_SM_SIDE_NAME_LEFT_TEXT;
					shadow = 0;
					sizeEx = MACRO_POS_SM_SIDE_NAME_TEXTSIZE;
					style = ST_RIGHT;
					text = "SIDE 1";
					x = pixelW * MACRO_POS_SPACER_X;
					y = MACRO_POS_SM_MENU_HEIGHT * (0.32 - 0.05) + pixelH * MACRO_POS_SPACER_Y;
					w = MACRO_POS_SM_WIDTH * (1 / 6) - pixelW * (MACRO_POS_SPACER_X * 2 + 1);
					h = MACRO_POS_SM_MENU_HEIGHT * 0.05 - pixelH * MACRO_POS_SPACER_Y * 2;
				};

				// Side Name, Middle
				class Side_Name_Middle : Side_Name_Left {
					idc = MACRO_IDC_SM_SIDE_NAME_MIDDLE_TEXT;
					text = "SIDE 2";
					x = MACRO_POS_SM_WIDTH / 3 + pixelW * MACRO_POS_SPACER_X;
					w = MACRO_POS_SM_WIDTH * (1 / 6) - pixelW * MACRO_POS_SPACER_X * 2;
				};

				// Side Name, Right
				class Side_Name_Right : Side_Name_Left {
					idc = MACRO_IDC_SM_SIDE_NAME_RIGHT_TEXT;
					text = "SIDE 3";
					x = MACRO_POS_SM_WIDTH * (2 / 3) + pixelW * (MACRO_POS_SPACER_X + 1);
				};

				// ------------------------------------------------------------------------------------------------------------------------------------------------
				// Side Tickets, Left
				class Side_Tickets_Left : GVAR(RscText) {
					idc = MACRO_IDC_SM_SIDE_TICKETS_LEFT_TEXT;
					shadow = 0;
					sizeEx = MACRO_POS_SM_SIDE_TICKETS_TEXTSIZE;
					style = ST_LEFT;
					text = "200";
					x = MACRO_POS_SM_WIDTH * (1 / 6) + pixelW * MACRO_POS_SPACER_X * 1;
					y = MACRO_POS_SM_MENU_HEIGHT * (0.32 - 0.05) + pixelH * MACRO_POS_SPACER_Y;
					w = MACRO_POS_SM_WIDTH * (1 / 6) - pixelW * (MACRO_POS_SPACER_X * 2 + 1);
					h = MACRO_POS_SM_MENU_HEIGHT * 0.05 - pixelH * MACRO_POS_SPACER_Y * 2;
				};

				// Side Tickets, Middle
				class Side_Tickets_Middle : Side_Tickets_Left {
					idc = MACRO_IDC_SM_SIDE_TICKETS_MIDDLE_TEXT;
					x = MACRO_POS_SM_WIDTH * (3 / 6) + pixelW * MACRO_POS_SPACER_X;
					w = MACRO_POS_SM_WIDTH * (1 / 6) - pixelW * MACRO_POS_SPACER_X * 2;
				};

				// Side Tickets, Right
				class Side_Tickets_Right : Side_Tickets_Left {
					idc = MACRO_IDC_SM_SIDE_TICKETS_RIGHT_TEXT;
					x = MACRO_POS_SM_WIDTH * (5 / 6) + pixelW * (MACRO_POS_SPACER_X + 1);
				};

				// ------------------------------------------------------------------------------------------------------------------------------------------------
				// Players Listbox Background, Left
				class Players_Listbox_Background_Left : GVAR(RscFrame) {
					idc = MACRO_IDC_SM_SIDE_PLAYERS_LEFT_BACKGROUND;
					colorBackground[] = CURLY(MACRO_COLOUR_A100_BLACK);
					x = pixelW * MACRO_POS_SPACER_X;
					y = MACRO_POS_SM_MENU_HEIGHT * 0.32;
					w = MACRO_POS_SM_WIDTH / 3 - pixelW * (MACRO_POS_SPACER_X * 2 + 1);
					h = MACRO_POS_SM_MENU_HEIGHT * 0.6 - pixelH * MACRO_POS_SPACER_Y;
				};

				// Players Listbox Outline, Left
				class Players_Listbox_Outline_Left : GVAR(RscOutline) {
					idc = MACRO_IDC_SM_SIDE_PLAYERS_LEFT_OUTLINE;
					x = pixelW * MACRO_POS_SPACER_X;
					y = MACRO_POS_SM_MENU_HEIGHT * 0.32;
					w = MACRO_POS_SM_WIDTH / 3 - pixelW * (MACRO_POS_SPACER_X * 2 + 1);
					h = MACRO_POS_SM_MENU_HEIGHT * 0.6 - pixelH * MACRO_POS_SPACER_Y;
				};

				// Players Listbox, Left
				class Players_Listbox_Left : GVAR(RscListNBox) {
					idc = MACRO_IDC_SM_SIDE_PLAYERS_LEFT_LISTBOX;
					columns[] = {0, 0.1};
					x = pixelW * MACRO_POS_SPACER_X;
					y = MACRO_POS_SM_MENU_HEIGHT * 0.32;
					w = MACRO_POS_SM_WIDTH / 3 - pixelW * (MACRO_POS_SPACER_X * 2 + 1);
					h = MACRO_POS_SM_MENU_HEIGHT * 0.6 - pixelH * MACRO_POS_SPACER_Y;
				};

				// Players Listbox Background, Middle
				class Players_Listbox_Background_Middle : Players_Listbox_Background_Left {
					idc = MACRO_IDC_SM_SIDE_PLAYERS_MIDDLE_BACKGROUND;
					x = MACRO_POS_SM_WIDTH / 3 + pixelW * MACRO_POS_SPACER_X;
					w = MACRO_POS_SM_WIDTH / 3 - pixelW * MACRO_POS_SPACER_X * 2;
				};

				// Players Listbox Outline, Middle
				class Players_Listbox_Outline_Middle : Players_Listbox_Outline_Left {
					idc = MACRO_IDC_SM_SIDE_PLAYERS_MIDDLE_OUTLINE;
					x = MACRO_POS_SM_WIDTH / 3 + pixelW * MACRO_POS_SPACER_X;
					w = MACRO_POS_SM_WIDTH / 3 - pixelW * MACRO_POS_SPACER_X * 2;
				};

				// Players Listbox, Middle
				class Players_Listbox_Middle : Players_Listbox_Left {
					idc = MACRO_IDC_SM_SIDE_PLAYERS_MIDDLE_LISTBOX;
					x = MACRO_POS_SM_WIDTH / 3 + pixelW * MACRO_POS_SPACER_X;
					w = MACRO_POS_SM_WIDTH / 3 - pixelW * MACRO_POS_SPACER_X * 2;
				};

				// Players Listbox Background, Right
				class Players_Listbox_Background_Right : Players_Listbox_Background_Left {
					idc = MACRO_IDC_SM_SIDE_PLAYERS_RIGHT_BACKGROUND;
					x = MACRO_POS_SM_WIDTH * (2 / 3) + pixelW * (MACRO_POS_SPACER_X + 1);
				};

				// Players Listbox Outline, Right
				class Players_Listbox_Outline_Right : Players_Listbox_Outline_Left {
					idc = MACRO_IDC_SM_SIDE_PLAYERS_RIGHT_OUTLINE;
					x = MACRO_POS_SM_WIDTH * (2 / 3) + pixelW * (MACRO_POS_SPACER_X + 1);
				};

				// Players Listbox, Right
				class Players_Listbox_Right : Players_Listbox_Left {
					idc = MACRO_IDC_SM_SIDE_PLAYERS_RIGHT_LISTBOX;
					x = MACRO_POS_SM_WIDTH * (2 / 3) + pixelW * (MACRO_POS_SPACER_X + 1);
				};

				// ------------------------------------------------------------------------------------------------------------------------------------------------
				// Join Button Frame, Left
				class Join_Button_Frame_Left : GVAR(RscFrame) {
					idc = MACRO_IDC_SM_SIDE_JOIN_LEFT_FRAME;
					colorBackground[] = CURLY(MACRO_COLOUR_BUTTON_INACTIVE);
					x = pixelW * MACRO_POS_SPACER_X;
					y = MACRO_POS_SM_MENU_HEIGHT * 0.92;
					w = MACRO_POS_SM_WIDTH / 3 - pixelW * (MACRO_POS_SPACER_X * 2 + 1);
					h = MACRO_POS_SM_MENU_HEIGHT * 0.08;
				};

				// Join Button, Left
				class Join_Button_Left : GVAR(RscButton) {
					idc = MACRO_IDC_SM_SIDE_JOIN_LEFT_BUTTON;
					text = "CLICK TO SELECT";
					x = pixelW * MACRO_POS_SPACER_X;
					y = MACRO_POS_SM_MENU_HEIGHT * 0.92;
					w = MACRO_POS_SM_WIDTH / 3 - pixelW * (MACRO_POS_SPACER_X * 2 + 1);
					h = MACRO_POS_SM_MENU_HEIGHT * 0.08;
					onButtonClick         = __EVAL(format ["['ui_button_click', _this] call %1", QFUNC(ui_spawnMenu)]);
					onButtonDown          = __EVAL(format ["['ui_focus_reset'] call %1", QFUNC(ui_spawnMenu)]);
					onMouseButtonDblClick = __EVAL(format ["['ui_focus_reset'] call %1", QFUNC(ui_spawnMenu)]);
				};

				// Join Button Frame, Middle
				class Join_Button_Frame_Middle : Join_Button_Frame_Left {
					idc = MACRO_IDC_SM_SIDE_JOIN_MIDDLE_FRAME;
					x = MACRO_POS_SM_WIDTH / 3 + pixelW * MACRO_POS_SPACER_X;
					w = MACRO_POS_SM_WIDTH / 3 - pixelW * MACRO_POS_SPACER_X * 2;
				};

				// Join Button, Middle
				class Join_Button_Middle : Join_Button_Left {
					idc = MACRO_IDC_SM_SIDE_JOIN_MIDDLE_BUTTON;
					x = MACRO_POS_SM_WIDTH / 3 + pixelW * MACRO_POS_SPACER_X;
					w = MACRO_POS_SM_WIDTH / 3 - pixelW * MACRO_POS_SPACER_X * 2;
				};

				// Join Button Frame, Right
				class Join_Button_Frame_Right : Join_Button_Frame_Left {
					idc = MACRO_IDC_SM_SIDE_JOIN_RIGHT_FRAME;
					x = MACRO_POS_SM_WIDTH * (2 / 3) + pixelW * (MACRO_POS_SPACER_X + 1);
				};

				// Join Button, Right
				class Join_Button_Right : Join_Button_Left {
					idc = MACRO_IDC_SM_SIDE_JOIN_RIGHT_BUTTON;
					x = MACRO_POS_SM_WIDTH * (2 / 3) + pixelW * (MACRO_POS_SPACER_X + 1);
				};

			};
		};

		// ------------------------------------------------------------------------------------------------------------------------------------------------
		// Role Control Group
		class Role_CtrlGrp : Side_CtrlGrp {
			idc = MACRO_IDC_SM_ROLE_CTRLGROUP;

			class controls {

				// Separator, Left
				class Separator_Left : GVAR(RscFrame) {
					colorBackground[] = CURLY(MACRO_COLOUR_A100_WHITE);
					x = MACRO_POS_SM_WIDTH / 3 - pixelW;
					y = 0;
					w = pixelW;
					h = MACRO_POS_SM_MENU_HEIGHT;
				};

				// Separator, Right
				class Separator_Right : Separator_Left {
					x = MACRO_POS_SM_WIDTH * (2 / 3);
				};

				// ------------------------------------------------------------------------------------------------------------------------------------------------
				// PIP Warning Text (Top)
				class PIP_Warning_Top_Text : GVAR(RscText) {
					shadow = 0;
					sizeEx = MACRO_POS_SM_ROLE_PIP_TOP_TEXTSIZE;
					text = "PIP DISABLED";
					x = MACRO_POS_SM_WIDTH / 3 + pixelW * MACRO_POS_SPACER_X;
					y = pixelH * MACRO_POS_SPACER_Y;
					w = MACRO_POS_SM_WIDTH / 3 - pixelW * MACRO_POS_SPACER_X * 2;
					h = MACRO_POS_SM_MENU_HEIGHT * 0.15;
				};

				// PIP Warning Text (Bottom)
				class PIP_Warning_Bottom_Text : PIP_Warning_Top_Text {
					style = ST_CENTER + ST_MULTI;
					sizeEx = MACRO_POS_SM_ROLE_PIP_BOTTOM_TEXTSIZE;
					text = "This panel is where you can preview your selected role. However, this requires Picture-In-Picture (PIP) to be enabled.\n\nPlease enable it in your video options.";
					y = MACRO_POS_SM_MENU_HEIGHT * 0.15 + pixelH * MACRO_POS_SPACER_Y;
					h = MACRO_POS_SM_MENU_HEIGHT * 0.2;
				};

				// PIP Warning Picture
				class PIP_Warning_Picture : GVAR(RscPicture) {
					text = "res\images\pip.paa";
					x = MACRO_POS_SM_WIDTH / 3 + pixelW * MACRO_POS_SPACER_X;
					y = MACRO_POS_SM_MENU_HEIGHT * 0.35 + pixelH * MACRO_POS_SPACER_Y;
					w = MACRO_POS_SM_WIDTH / 3 - pixelW * MACRO_POS_SPACER_X * 2;
					h = MACRO_POS_SM_MENU_HEIGHT * 0.65 - pixelH * MACRO_POS_SPACER_Y;
				};

				// Role Preview Controls Group
				class Role_Preview_CtrlGrp : Background_CtrlGrp {
					idc = MACRO_IDC_SM_ROLE_PREVIEW_CTRLGROUP;
					x = MACRO_POS_SM_WIDTH / 3 + pixelW * MACRO_POS_SPACER_X;
					y = pixelH * MACRO_POS_SPACER_Y;
					w = MACRO_POS_SM_WIDTH / 3 - pixelW * MACRO_POS_SPACER_X * 2;
					h = MACRO_POS_SM_MENU_HEIGHT - pixelH * MACRO_POS_SPACER_Y;

					class controls {

						// Focus Frame
						class Focus_Frame  : GVAR(RscFrameFocused) {
							idc = MACRO_IDC_SM_ROLE_PREVIEW_FOCUS_FRAME;
						};

						// Role Preview Rendertarget
						class Role_Preview_Rendertarget_Picture : GVAR(RscPictureNoAR) {
							idc = MACRO_IDC_SM_ROLE_PREVIEW_PICTURE;
							text = __EVAL(format ["%1%2%3", "#(argb,512,512,1)r2t(", QGVAR(tex_r2t_role), ",1.0)"]);
							x = -MACRO_POS_SM_WIDTH / 3 - pixelW * MACRO_POS_SPACER_X;
							y = 0;
							w = MACRO_POS_SM_WIDTH;
							h = MACRO_POS_SM_MENU_HEIGHT - pixelH * MACRO_POS_SPACER_Y;
							onMouseMoving = __EVAL(format ["['ui_mouse_moving', _this] call %1", QFUNC(ui_spawnMenu)]);

						};

						// Controls Text
						class Controls_Text : GVAR(RscText) {
							idc = MACRO_IDC_SM_ROLE_PREVIEW_CONTROLS_TEXT;
							style = ST_MULTI;
							sizeEx = MACRO_UI_TEXTSIZE_1;
							shadow = 2;
							text = "Hold LMB to pan/rotate\nScroll to zoom\nPress N to toggle NVG";
							x = 0;
							y = 0;
							w = MACRO_POS_SM_WIDTH / 3 - pixelW * MACRO_POS_SPACER_X * 2;
							h = MACRO_POS_SM_MENU_HEIGHT - pixelH * MACRO_POS_SPACER_Y;
						};

						// Role Preview Rendertarget
						class Role_Preview_Rendertarget_Frame : GVAR(RscFrameFocused) {
							idc = MACRO_IDC_SM_ROLE_PREVIEW_FRAME;
							w = MACRO_POS_SM_WIDTH / 3 - pixelW * MACRO_POS_SPACER_X * 2;
							h = MACRO_POS_SM_MENU_HEIGHT - pixelH * MACRO_POS_SPACER_Y;
							onMouseMoving         = __EVAL(format ["['ui_mouse_moving', _this] call %1", QFUNC(ui_spawnMenu)]);
							onMouseZChanged       = __EVAL(format ["['ui_mousez_changed', _this] call %1", QFUNC(ui_spawnMenu)]);
							onMouseButtonDown     = __EVAL(format ["['ui_button_click', _this] call %1", QFUNC(ui_spawnMenu)]);
							onMouseButtonDblClick = __EVAL(format ["['ui_focus_reset'] call %1", QFUNC(ui_spawnMenu)]);
						};
					};
				};

				// ------------------------------------------------------------------------------------------------------------------------------------------------
				// Specops Role
				MACRO_FNC_ADDROLECTRLS(0,"SPECIAL FORCES")

				// Sniper
				MACRO_FNC_ADDROLECTRLS(1,"SNIPER")

				// Assault
				MACRO_FNC_ADDROLECTRLS(2,"ASSAULT")

				// Support
				MACRO_FNC_ADDROLECTRLS(3,"SUPPORT")

				// Engineer
				MACRO_FNC_ADDROLECTRLS(4,"ENGINEER")

				// Medic
				MACRO_FNC_ADDROLECTRLS(5,"MEDIC")

				// Anti-Tank
				MACRO_FNC_ADDROLECTRLS(6,"ANTI-TANK")

				// ------------------------------------------------------------------------------------------------------------------------------------------------
				// Groups Listbox Text
				class Groups_Listbox_Text : GVAR(RscText) {
					shadow = 0;
					sizeEx = MACRO_POS_SM_GROUP_LISTBOX_TEXTSIZE;
					text = "GROUPS";
					x = MACRO_POS_SM_WIDTH * (2 / 3) + pixelW * (MACRO_POS_SPACER_X + 1);
					y = pixelH * MACRO_POS_SPACER_Y;
					w = MACRO_POS_SM_WIDTH / 6 - pixelW * (MACRO_POS_SPACER_X + 2);
					h = MACRO_POS_SM_MENU_HEIGHT * 0.05;
				};

				class Groups_Separator : GVAR(RscFrame) {
					colorBackground[] = CURLY(MACRO_COLOUR_A100_WHITE);
					x = MACRO_POS_SM_WIDTH * (5 / 6);
					y = pixelH * MACRO_POS_SPACER_Y;
					w = pixelW;
					h = MACRO_POS_SM_MENU_HEIGHT * 0.05;
				};

				class Members_Listbox_Text : Groups_Listbox_Text {
					text = "MEMBERS";
					x = MACRO_POS_SM_WIDTH * (5 / 6) + pixelW * 2;
					w = MACRO_POS_SM_WIDTH / 6 - pixelW * (MACRO_POS_SPACER_X + 2);
				};

				// ------------------------------------------------------------------------------------------------------------------------------------------------
				// Groups Listbox Background
				class Groups_Listbox_Background : GVAR(RscFrame) {
					colorBackground[] = CURLY(MACRO_COLOUR_A100_BLACK);
					x = MACRO_POS_SM_WIDTH * (2 / 3) + pixelW * (MACRO_POS_SPACER_X + 1);
					y = MACRO_POS_SM_MENU_HEIGHT * 0.05 + pixelH * MACRO_POS_SPACER_Y * 2;
					w = MACRO_POS_SM_WIDTH / 6 - pixelW * (MACRO_POS_SPACER_X + 2);
					h = MACRO_POS_SM_MENU_HEIGHT * 0.87 - pixelH * MACRO_POS_SPACER_Y * 3;
				};

				// Groups Listbox Outline
				class Groups_Listbox_Outline : GVAR(RscOutline) {
					x = MACRO_POS_SM_WIDTH * (2 / 3) + pixelW * (MACRO_POS_SPACER_X + 1);
					y = MACRO_POS_SM_MENU_HEIGHT * 0.05 + pixelH * MACRO_POS_SPACER_Y * 2;
					w = MACRO_POS_SM_WIDTH / 6 - pixelW * (MACRO_POS_SPACER_X + 2);
					h = MACRO_POS_SM_MENU_HEIGHT * 0.87 - pixelH * MACRO_POS_SPACER_Y * 3;
				};

				// Groups Listbox
				class Groups_ListBox : GVAR(RscListNBox) {
					idc = MACRO_IDC_SM_GROUP_GROUPS_LISTBOX;
					columns[] = {0, 0.05, 0.75};
					colorPicture[] = CURLY(MACRO_COLOUR_BUTTON_ACTIVE_PRESSED);
					colorPictureSelected[] = CURLY(MACRO_COLOUR_BUTTON_ACTIVE_PRESSED);
					x = MACRO_POS_SM_WIDTH * (2 / 3) + pixelW * (MACRO_POS_SPACER_X + 1);
					y = MACRO_POS_SM_MENU_HEIGHT * 0.05 + pixelH * MACRO_POS_SPACER_Y * 2;
					w = MACRO_POS_SM_WIDTH / 6 - pixelW * (MACRO_POS_SPACER_X + 2);
					h = MACRO_POS_SM_MENU_HEIGHT * 0.87 - pixelH * MACRO_POS_SPACER_Y * 3;
					onLBSelChanged = __EVAL(format ["['ui_listbox_changed', _this] call %1", QFUNC(ui_spawnMenu)]);
				};

				// Group Members Listbox Background
				class Members_Listbox_Background : Groups_Listbox_Background {
					x = MACRO_POS_SM_WIDTH * (5 / 6) + pixelW * 2;
					w = MACRO_POS_SM_WIDTH / 6 - pixelW * (MACRO_POS_SPACER_X + 2);
				};

				// Group Members Listbox Outline
				class Members_Listbox_Outline : Groups_Listbox_Outline {
					x = MACRO_POS_SM_WIDTH * (5 / 6) + pixelW * 2;
					w = MACRO_POS_SM_WIDTH / 6 - pixelW * (MACRO_POS_SPACER_X + 2);
				};

				// Group Members Listbox
				class Members_ListBox : Groups_ListBox {
					idc = MACRO_IDC_SM_GROUP_MEMBERS_LISTBOX;
					colorPicture[] = CURLY(MACRO_COLOUR_A100_WHITE);
					colorPictureSelected[] = CURLY(MACRO_COLOUR_A100_WHITE);
					columns[] = {0, 0.08, 0.25};
					x = MACRO_POS_SM_WIDTH * (5 / 6) + pixelW * 2;
					w = MACRO_POS_SM_WIDTH / 6 - pixelW * (MACRO_POS_SPACER_X + 2);
				};

				// ------------------------------------------------------------------------------------------------------------------------------------------------
				// Group Join Button Frame
				class Group_Join_Frame : GVAR(RscFrame) {
					idc = MACRO_IDC_SM_GROUP_JOIN_FRAME;
					colorBackground[] = CURLY(MACRO_COLOUR_BUTTON_ACTIVE);
					x = MACRO_POS_SM_WIDTH * (6 / 9) + pixelW * (MACRO_POS_SPACER_X + 1);
					y = MACRO_POS_SM_MENU_HEIGHT * 0.92;
					w = MACRO_POS_SM_WIDTH / 9 - pixelW * (MACRO_POS_SPACER_X * (4 / 3));
					h = MACRO_POS_SM_MENU_HEIGHT * 0.08;
				};

				// Group Join Button
				class Group_Join_Button : GVAR(RscButton) {
					idc = MACRO_IDC_SM_GROUP_JOIN_BUTTON;
					text = "JOIN";
					x = MACRO_POS_SM_WIDTH * (6 / 9) + pixelW * (MACRO_POS_SPACER_X + 1);
					y = MACRO_POS_SM_MENU_HEIGHT * 0.92;
					w = MACRO_POS_SM_WIDTH / 9 - pixelW * (MACRO_POS_SPACER_X * (4 / 3));
					h = MACRO_POS_SM_MENU_HEIGHT * 0.08;
					onButtonDown          = __EVAL(format ["['ui_focus_reset'] call %1", QFUNC(ui_spawnMenu)]);
					onButtonClick         = __EVAL(format ["['ui_button_click', _this] call %1", QFUNC(ui_spawnMenu)]);
					onMouseButtonDblClick = __EVAL(format ["['ui_focus_reset'] call %1", QFUNC(ui_spawnMenu)]);
				};

				// Group Create Button Frame
				class Group_Create_Frame : Group_Join_Frame {
					idc = MACRO_IDC_SM_GROUP_CREATE_FRAME;
					x = MACRO_POS_SM_WIDTH * (7 / 9) + pixelW * (MACRO_POS_SPACER_X * (2 / 3) + 1);
					w = MACRO_POS_SM_WIDTH / 9 - pixelW * (MACRO_POS_SPACER_X * (4 / 3) + 1);
				};

				// Group Create Button
				class Group_Create_Button : Group_Join_Button {
					idc = MACRO_IDC_SM_GROUP_CREATE_BUTTON;
					text = "CREATE";
					x = MACRO_POS_SM_WIDTH * (7 / 9) + pixelW * (MACRO_POS_SPACER_X * (2 / 3) + 1);
					w = MACRO_POS_SM_WIDTH / 9 - pixelW * (MACRO_POS_SPACER_X * (4 / 3) + 1);
				};

				// Group Leave Button Frame
				class Group_Leave_Frame : Group_Join_Frame {
					idc = MACRO_IDC_SM_GROUP_LEAVE_FRAME;
					x = MACRO_POS_SM_WIDTH * (8 / 9) + pixelW * (MACRO_POS_SPACER_X * (1 / 3));
				};

				// Group Leave Button
				class Group_Leave_Button : Group_Join_Button {
					idc = MACRO_IDC_SM_GROUP_LEAVE_BUTTON;
					text = "LEAVE";
					x = MACRO_POS_SM_WIDTH * (8 / 9) + pixelW * (MACRO_POS_SPACER_X * (1 / 3));
				};
			};
		};

		// ------------------------------------------------------------------------------------------------------------------------------------------------
		// Role Control Group
		class Deploy_CtrlGrp : Side_CtrlGrp {
			idc = MACRO_IDC_SM_DEPLOY_CTRLGROUP;

			class controls {

				// Separator
				class Separator : GVAR(RscFrame) {
					colorBackground[] = CURLY(MACRO_COLOUR_A100_WHITE);
					x = MACRO_POS_SM_WIDTH / 3 - pixelW;
					y = 0;
					w = pixelW;
					h = MACRO_POS_SM_MENU_HEIGHT;
				};

				// ------------------------------------------------------------------------------------------------------------------------------------------------
				// Sectors Controls Group
				class Sectors_CtrlGrp : RscControlsGroupNoHScrollbars {
					idc = MACRO_IDC_SM_DEPLOY_SECTORS_CTRLGROUP;
					x = 0;
					y = 0;
					w = MACRO_POS_SM_WIDTH / 3;
					h = MACRO_POS_SM_MENU_HEIGHT;

					class controls {
					};
				};
			};
		};

		// ------------------------------------------------------------------------------------------------------------------------------------------------
		// Empty Control Group (for focus)
		class Empty_CtrlGrp : Side_CtrlGrp {
			idc = MACRO_IDC_SM_EMPTY_CTRLGROUP;
			w = 0;
			h = 0;

			class controls {

				// Focus Frame
				class Focus_Frame : GVAR(RscFrameFocused) {
					idc = MACRO_IDC_SM_EMPTY_FOCUS_FRAME;
				};
			};
		};

		// ------------------------------------------------------------------------------------------------------------------------------------------------
		// Deployment Map
		class Map : RscMapControl {	// The map may not be created inside a controls group, otherwise strange positioning/offset errors will arise (see https://feedback.bistudio.com/T78273)
			idc = MACRO_IDC_SM_DEPLOY_MAP;
			x = safeZoneX + (1 - MACRO_POS_SM_WIDTH / safezoneW) * (safezoneW / 2) + MACRO_POS_SM_WIDTH / 3 + pixelW * MACRO_POS_SPACER_X;
			y = safeZoneY + (1 - MACRO_POS_SM_HEIGHT / safezoneH) * (safezoneH / 2) + pixelH * MACRO_POS_SPACER_Y;
			w = MACRO_POS_SM_WIDTH * (2 / 3) - pixelW * MACRO_POS_SPACER_X * 2;
			h = MACRO_POS_SM_MENU_HEIGHT - pixelW * (MACRO_POS_SPACER_Y + 1);
			onMouseButtonDown = __EVAL(format ["['ui_button_click', _this] call %1", QFUNC(ui_spawnMenu)]);
		};
	};
};
