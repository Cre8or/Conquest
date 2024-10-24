// Sector HUD
class GVAR(RscScoreBoard) {
	idd = -1;
	fadeIn = 0;
	fadeOut = 0;
	duration = 999999;
	movingEnable = 0;
	movingEnabled = 0;
	name = QGVAR(RscScoreBoard);
	onLoad = __EVAL(format ["uiNamespace setVariable ['%1', _this select 0]", QGVAR(RscScoreBoard)]);

	class controls {

		// Background Controls Group
		class Background_CtrlGrp : RscControlsGroupNoScrollbars {
			idc = MACRO_IDC_SB_CTRLGRP;
			x = safeZoneX + safezoneW / 2 - MACRO_POS_SB_WIDTH_COLUMN * 3 / 2;
			y = safeZoneY + safezoneH / 2 - MACRO_POS_SB_HEIGHT / 2;
			w = MACRO_POS_SB_WIDTH_COLUMN * 3;
			h = MACRO_POS_SB_HEIGHT;

			class controls {

				class Background : GVAR(RscFrame) {
					w = 3 * MACRO_POS_SB_WIDTH_COLUMN;
					h = MACRO_POS_SB_HEIGHT;
					colorBackground[] = CURLY(MACRO_COLOUR_A75_BLACK);
				};

				// Focus Frame
				class Focus_Frame : GVAR(RscFrameFocused) {
					idc = MACRO_IDC_SB_FOCUS_FRAME;
				};

				// Separators
				class Horizontal_Separator_Left : GVAR(RscFrame) {
					colorBackground[] = CURLY(MACRO_COLOUR_A100_WHITE);
					x = pixelW * MACRO_POS_SPACER_X;
					y = MACRO_POS_SB_SIDE_HEADER_HEIGHT + 2 * pixelH * MACRO_POS_SPACER_Y;
					w = MACRO_POS_SB_LISTBOX_WIDTH;
					h = pixelH;
				};

				class Horizontal_Separator_Middle : Horizontal_Separator_Left {
					x = MACRO_POS_SB_WIDTH_COLUMN + pixelW * MACRO_POS_SPACER_X;
				};

				class Horizontal_Separator_Right : Horizontal_Separator_Left {
					x = 2 * MACRO_POS_SB_WIDTH_COLUMN + pixelW * MACRO_POS_SPACER_X;
				};

				class Vertical_Separator_Left_Middle : Horizontal_Separator_Left {
					x = MACRO_POS_SB_WIDTH_COLUMN;
					y = pixelH * MACRO_POS_SPACER_Y;
					w = pixelW;
					h = MACRO_POS_SB_HEIGHT - 2 * pixelH * MACRO_POS_SPACER_Y;
				};

				class Vertical_Separator_Middle_Right : Vertical_Separator_Left_Middle {
					x = 2 * MACRO_POS_SB_WIDTH_COLUMN;
				};

				class Vertical_Separator_Side_Name_Left : Vertical_Separator_Left_Middle {
					x = 0.5 * MACRO_POS_SB_WIDTH_COLUMN;
					h = MACRO_POS_SB_SIDE_HEADER_HEIGHT;
				};

				class Vertical_Separator_Side_Name_Middle : Vertical_Separator_Side_Name_Left {
					x = 1.5 * MACRO_POS_SB_WIDTH_COLUMN;
				};

				class Vertical_Separator_Side_Name_Right : Vertical_Separator_Side_Name_Left {
					x = 2.5 * MACRO_POS_SB_WIDTH_COLUMN;
				};

				// ------------------------------------------------------------------------------------------------------------------------------------------------
				// Side Flag, Left
				class Side_Flag_Left : GVAR(RscPictureNoAR) {
					idc = MACRO_IDC_SB_SIDE_FLAG_LEFT_PICTURE;
					text = MACRO_TEXTURE_FLAG_EMPTY;
					x = pixelW * MACRO_POS_SPACER_X;
					y = pixelH * MACRO_POS_SPACER_Y;
					w = MACRO_POS_SB_SIDE_FLAG_WIDTH;
					h = MACRO_POS_SB_SIDE_HEADER_HEIGHT;
				};

				// Side Flag, Middle
				class Side_Flag_Middle : Side_Flag_Left {
					idc = MACRO_IDC_SB_SIDE_FLAG_MIDDLE_PICTURE;
					x = MACRO_POS_SB_WIDTH_COLUMN + pixelW * MACRO_POS_SPACER_X;
				};

				// Side Flag, Right
				class Side_Flag_Right : Side_Flag_Left {
					idc = MACRO_IDC_SB_SIDE_FLAG_RIGHT_PICTURE;
					x = 2 * MACRO_POS_SB_WIDTH_COLUMN+ pixelW * MACRO_POS_SPACER_X;
				};

				// Side Name Text, Left
				class Side_Name_Left : GVAR(RscText) {
					idc = MACRO_IDC_SB_SIDE_NAME_LEFT_TEXT;
					style = ST_RIGHT;
					shadow = 2;
					text = "SIDE NAME";
					sizeEx = MACRO_POS_SB_SIDE_NAME_TEXTSIZE;
					x = MACRO_POS_SB_SIDE_FLAG_WIDTH + 2 * pixelW * MACRO_POS_SPACER_X;
					y = pixelH * MACRO_POS_SPACER_Y;
					w = 0.5 * MACRO_POS_SB_WIDTH_COLUMN - MACRO_POS_SB_SIDE_FLAG_WIDTH - 3 * pixelW * MACRO_POS_SPACER_X;
					h = MACRO_POS_SB_SIDE_HEADER_HEIGHT;
				};

				// Side Name Text, Middle
				class Side_Name_Middle : Side_Name_Left {
					idc = MACRO_IDC_SB_SIDE_NAME_MIDDLE_TEXT;
					x = MACRO_POS_SB_WIDTH_COLUMN + MACRO_POS_SB_SIDE_FLAG_WIDTH + 2 * pixelW * MACRO_POS_SPACER_X;
				};

				// Side Name Text, Right
				class Side_Name_Right : Side_Name_Left {
					idc = MACRO_IDC_SB_SIDE_NAME_RIGHT_TEXT;
					x = 2 * MACRO_POS_SB_WIDTH_COLUMN + MACRO_POS_SB_SIDE_FLAG_WIDTH + 2 * pixelW * MACRO_POS_SPACER_X;
				};

				// Side Tickets Text, Left
				class Side_Tickets_Left : Side_Name_Left {
					idc = MACRO_IDC_SB_SIDE_TICKETS_LEFT_TEXT;
					style = ST_LEFT;
					text = "999";
					x = 0.5 * MACRO_POS_SB_WIDTH_COLUMN + pixelW * MACRO_POS_SPACER_X;
					w = 0.5 * MACRO_POS_SB_LISTBOX_WIDTH;
				};

				// Side Tickets Text, Middle
				class Side_Tickets_Middle : Side_Tickets_Left {
					idc = MACRO_IDC_SB_SIDE_TICKETS_MIDDLE_TEXT;
					x = 1.5 * MACRO_POS_SB_WIDTH_COLUMN + pixelW * MACRO_POS_SPACER_X;
				};

				// Side Tickets Text, Right
				class Side_Tickets_Right : Side_Tickets_Left {
					idc = MACRO_IDC_SB_SIDE_TICKETS_RIGHT_TEXT;
					x = 2.5 * MACRO_POS_SB_WIDTH_COLUMN + pixelW * MACRO_POS_SPACER_X;
				};

				// ------------------------------------------------------------------------------------------------------------------------------------------------
				// Scorboard Column Backgrounds, Left
				class Background_Column_Name_Left : GVAR(RscFrame) {
					x = pixelW * MACRO_POS_SPACER_X + MACRO_POS_SB_COLUMN_X_NAME * MACRO_POS_SB_LISTBOX_WIDTH;
					y = MACRO_POS_SB_SIDE_HEADER_HEIGHT + 2 * pixelH * MACRO_POS_SPACER_Y;
					w = MACRO_POS_SB_LISTBOX_WIDTH * (MACRO_POS_SB_COLUMN_X_SCORE - MACRO_POS_SB_COLUMN_X_NAME);
					h = MACRO_POS_SB_HEIGHT - MACRO_POS_SB_SIDE_HEADER_HEIGHT - 3 * pixelH * MACRO_POS_SPACER_Y;
					colorBackground[] = CURLY(MACRO_COLOUR_A10_WHITE);
				};

				class Background_Column_Kills_Left : Background_Column_Name_Left {
					x = pixelW * MACRO_POS_SPACER_X + MACRO_POS_SB_COLUMN_X_KILLS * MACRO_POS_SB_LISTBOX_WIDTH;
					w = MACRO_POS_SB_LISTBOX_WIDTH * (MACRO_POS_SB_COLUMN_X_DEATHS - MACRO_POS_SB_COLUMN_X_KILLS);
				};

				class Background_Column_Revives_Left : Background_Column_Name_Left {
					x = pixelW * MACRO_POS_SPACER_X + MACRO_POS_SB_COLUMN_X_REVIVES * MACRO_POS_SB_LISTBOX_WIDTH;
					w = MACRO_POS_SB_LISTBOX_WIDTH * (MACRO_POS_SB_COLUMN_X_PING - MACRO_POS_SB_COLUMN_X_REVIVES);
				};

				class Background_Column_Scrollbar_Left : Background_Column_Name_Left {
					x = pixelW * MACRO_POS_SPACER_X + MACRO_POS_SB_COLUMN_X_SCROLLBAR * MACRO_POS_SB_LISTBOX_WIDTH;
					w = MACRO_POS_SB_LISTBOX_WIDTH * (1 - MACRO_POS_SB_COLUMN_X_SCROLLBAR);
				};

				// Scorboard Column Backgrounds, Middle
				class Background_Column_Name_Middle : Background_Column_Name_Left {
					x = MACRO_POS_SB_WIDTH_COLUMN + pixelW * MACRO_POS_SPACER_X + MACRO_POS_SB_COLUMN_X_NAME * MACRO_POS_SB_LISTBOX_WIDTH;
				};

				class Background_Column_Kills_Middle : Background_Column_Kills_Left {
					x = MACRO_POS_SB_WIDTH_COLUMN + pixelW * MACRO_POS_SPACER_X + MACRO_POS_SB_COLUMN_X_KILLS * MACRO_POS_SB_LISTBOX_WIDTH;
				};

				class Background_Column_Revives_Middle : Background_Column_Revives_Left {
					x = MACRO_POS_SB_WIDTH_COLUMN + pixelW * MACRO_POS_SPACER_X + MACRO_POS_SB_COLUMN_X_REVIVES * MACRO_POS_SB_LISTBOX_WIDTH;
				};

				class Background_Column_Scrollbar_Middle : Background_Column_Scrollbar_Left {
					x = MACRO_POS_SB_WIDTH_COLUMN + pixelW * MACRO_POS_SPACER_X + MACRO_POS_SB_COLUMN_X_SCROLLBAR * MACRO_POS_SB_LISTBOX_WIDTH;
				};

				// Scorboard Column Backgrounds, Right
				class Background_Column_Name_Right : Background_Column_Name_Left {
					x = 2 * MACRO_POS_SB_WIDTH_COLUMN + pixelW * MACRO_POS_SPACER_X + MACRO_POS_SB_COLUMN_X_NAME * MACRO_POS_SB_LISTBOX_WIDTH;
				};

				class Background_Column_Kills_Right : Background_Column_Kills_Left {
					x = 2 * MACRO_POS_SB_WIDTH_COLUMN + pixelW * MACRO_POS_SPACER_X + MACRO_POS_SB_COLUMN_X_KILLS * MACRO_POS_SB_LISTBOX_WIDTH;
				};

				class Background_Column_Revives_Right : Background_Column_Revives_Left {
					x = 2 * MACRO_POS_SB_WIDTH_COLUMN + pixelW * MACRO_POS_SPACER_X + MACRO_POS_SB_COLUMN_X_REVIVES * MACRO_POS_SB_LISTBOX_WIDTH;
				};

				class Background_Column_Scrollbar_Right : Background_Column_Scrollbar_Left {
					x = 2 * MACRO_POS_SB_WIDTH_COLUMN + pixelW * MACRO_POS_SPACER_X + MACRO_POS_SB_COLUMN_X_SCROLLBAR * MACRO_POS_SB_LISTBOX_WIDTH;
				};

				// ------------------------------------------------------------------------------------------------------------------------------------------------
				// Scoreboard Icons, Left
				class Icon_Score_Left : GVAR(RscPicture) {
					text = "a3\ui_f\data\GUI\Rsc\RscDisplayConfigViewer\bookmark_gs.paa";
					x = pixelW * MACRO_POS_SPACER_X + MACRO_POS_SB_LISTBOX_WIDTH * (MACRO_POS_SB_COLUMN_X_KILLS - MACRO_POS_SB_IMAGE_WIDTH);
					y = MACRO_POS_SB_SIDE_HEADER_HEIGHT + 3 * pixelH * MACRO_POS_SPACER_Y;
					w = MACRO_POS_SB_LISTBOX_WIDTH * MACRO_POS_SB_IMAGE_WIDTH;
					h = MACRO_UI_TEXTSIZE_1;
				};

				class Icon_Kills_Left : Icon_Score_Left {
					text = "a3\ui_f\data\GUI\Cfg\RespawnRoles\recon_ca.paa";
					x = pixelW * MACRO_POS_SPACER_X + MACRO_POS_SB_LISTBOX_WIDTH * (MACRO_POS_SB_COLUMN_X_DEATHS - MACRO_POS_SB_IMAGE_WIDTH);
				};

				class Icon_Deaths_Left : Icon_Score_Left {
					text = MACRO_KF_ICON_SUICIDE;
					x = pixelW * MACRO_POS_SPACER_X + MACRO_POS_SB_LISTBOX_WIDTH * (MACRO_POS_SB_COLUMN_X_REVIVES - MACRO_POS_SB_IMAGE_WIDTH);
				};

				class Icon_Revives_Left : Icon_Score_Left {
					text = "res\images\revive.paa";
					x = pixelW * MACRO_POS_SPACER_X + MACRO_POS_SB_LISTBOX_WIDTH * (MACRO_POS_SB_COLUMN_X_PING - MACRO_POS_SB_IMAGE_WIDTH);
				};

				class Icon_Ping_Left : Icon_Score_Left {
					text = "res\images\connection.paa";
					x = pixelW * MACRO_POS_SPACER_X + MACRO_POS_SB_LISTBOX_WIDTH * (MACRO_POS_SB_COLUMN_X_SCROLLBAR - MACRO_POS_SB_IMAGE_WIDTH);
				};

				// Scoreboard Icons, Middle
				class Icon_Score_Middle : Icon_Score_Left {
					x = MACRO_POS_SB_WIDTH_COLUMN + pixelW * MACRO_POS_SPACER_X + MACRO_POS_SB_LISTBOX_WIDTH * (MACRO_POS_SB_COLUMN_X_KILLS - MACRO_POS_SB_IMAGE_WIDTH);
				};

				class Icon_Kills_Middle : Icon_Kills_Left {
					x = MACRO_POS_SB_WIDTH_COLUMN + pixelW * MACRO_POS_SPACER_X + MACRO_POS_SB_LISTBOX_WIDTH * (MACRO_POS_SB_COLUMN_X_DEATHS - MACRO_POS_SB_IMAGE_WIDTH);
				};

				class Icon_Deaths_Middle : Icon_Deaths_Left {
					x = MACRO_POS_SB_WIDTH_COLUMN + pixelW * MACRO_POS_SPACER_X + MACRO_POS_SB_LISTBOX_WIDTH * (MACRO_POS_SB_COLUMN_X_REVIVES - MACRO_POS_SB_IMAGE_WIDTH);
				};

				class Icon_Revives_Middle : Icon_Revives_Left {
					x = MACRO_POS_SB_WIDTH_COLUMN + pixelW * MACRO_POS_SPACER_X + MACRO_POS_SB_LISTBOX_WIDTH * (MACRO_POS_SB_COLUMN_X_PING - MACRO_POS_SB_IMAGE_WIDTH);
				};

				class Icon_Ping_Middle : Icon_Ping_Left {
					x = MACRO_POS_SB_WIDTH_COLUMN + pixelW * MACRO_POS_SPACER_X + MACRO_POS_SB_LISTBOX_WIDTH * (MACRO_POS_SB_COLUMN_X_SCROLLBAR - MACRO_POS_SB_IMAGE_WIDTH);
				};

				// Scoreboard Icons, Right
				class Icon_Score_Right : Icon_Score_Left {
					x = 2 * MACRO_POS_SB_WIDTH_COLUMN+ pixelW * MACRO_POS_SPACER_X + MACRO_POS_SB_LISTBOX_WIDTH * (MACRO_POS_SB_COLUMN_X_KILLS - MACRO_POS_SB_IMAGE_WIDTH);
				};

				class Icon_Kills_Right : Icon_Kills_Left {
					x = 2 * MACRO_POS_SB_WIDTH_COLUMN+ pixelW * MACRO_POS_SPACER_X + MACRO_POS_SB_LISTBOX_WIDTH * (MACRO_POS_SB_COLUMN_X_DEATHS - MACRO_POS_SB_IMAGE_WIDTH);
				};

				class Icon_Deaths_Right : Icon_Deaths_Left {
					x = 2 * MACRO_POS_SB_WIDTH_COLUMN+ pixelW * MACRO_POS_SPACER_X + MACRO_POS_SB_LISTBOX_WIDTH * (MACRO_POS_SB_COLUMN_X_REVIVES - MACRO_POS_SB_IMAGE_WIDTH);
				};

				class Icon_Revives_Right : Icon_Revives_Left {
					x = 2 * MACRO_POS_SB_WIDTH_COLUMN+ pixelW * MACRO_POS_SPACER_X + MACRO_POS_SB_LISTBOX_WIDTH * (MACRO_POS_SB_COLUMN_X_PING - MACRO_POS_SB_IMAGE_WIDTH);
				};

				class Icon_Ping_Right : Icon_Ping_Left {
					x = 2 * MACRO_POS_SB_WIDTH_COLUMN+ pixelW * MACRO_POS_SPACER_X + MACRO_POS_SB_LISTBOX_WIDTH * (MACRO_POS_SB_COLUMN_X_SCROLLBAR - MACRO_POS_SB_IMAGE_WIDTH);
				};

				// ------------------------------------------------------------------------------------------------------------------------------------------------
				// Players Listbox, Left
				class Players_Listbox_Left : GVAR(RscListNBox) {
					idc = MACRO_IDC_SB_SIDE_PLAYERS_LEFT_LISTBOX;
					columns[] = {0, MACRO_POS_SB_COLUMN_X_NAME, MACRO_POS_SB_COLUMN_X_SCORE, MACRO_POS_SB_COLUMN_X_KILLS, MACRO_POS_SB_COLUMN_X_DEATHS, MACRO_POS_SB_COLUMN_X_REVIVES, MACRO_POS_SB_COLUMN_X_PING, MACRO_POS_SB_COLUMN_X_SCROLLBAR};
					x = pixelW * MACRO_POS_SPACER_X;
					y = MACRO_POS_SB_SIDE_HEADER_HEIGHT + MACRO_UI_TEXTSIZE_1 + 3 * pixelH * MACRO_POS_SPACER_Y;
					w = MACRO_POS_SB_LISTBOX_WIDTH;
					h = MACRO_POS_SB_HEIGHT - MACRO_POS_SB_SIDE_HEADER_HEIGHT - MACRO_UI_TEXTSIZE_1 - 4 * pixelH * MACRO_POS_SPACER_Y;
					onLBSelChanged = __EVAL(format ["['ui_lbselection_changed', _this] call %1", QFUNC(ui_scoreBoard)]);
				};

				// Players Listbox, Middle
				class Players_Listbox_Middle : Players_Listbox_Left {
					idc = MACRO_IDC_SB_SIDE_PLAYERS_MIDDLE_LISTBOX;
					x = MACRO_POS_SB_WIDTH_COLUMN + pixelW * MACRO_POS_SPACER_X;
				};

				// Players Listbox, Right
				class Players_Listbox_Right : Players_Listbox_Left {
					idc = MACRO_IDC_SB_SIDE_PLAYERS_RIGHT_LISTBOX;
					x = 2 * MACRO_POS_SB_WIDTH_COLUMN + pixelW * MACRO_POS_SPACER_X;
				};

				// Players Listbox Outline, Left
				class Players_Listbox_Outline_Left : GVAR(RscOutline) {
					sizeEx = MACRO_UI_TEXTSIZE_1;
					x = pixelW * MACRO_POS_SPACER_X;
					y = MACRO_POS_SB_SIDE_HEADER_HEIGHT + 3 * pixelH * MACRO_POS_SPACER_Y;
					w = MACRO_POS_SB_WIDTH_COLUMN - 2 * pixelW * MACRO_POS_SPACER_X;
					h = MACRO_POS_SB_HEIGHT - MACRO_POS_SB_SIDE_HEADER_HEIGHT - 4 * pixelH * MACRO_POS_SPACER_Y;
				};

				// Players Listbox Outline, Middle
				class Players_Listbox_Outline_Middle : Players_Listbox_Outline_Left {
					x = MACRO_POS_SB_WIDTH_COLUMN + pixelW * MACRO_POS_SPACER_X;
				};

				// Players Listbox Outline, Right
				class Players_Listbox_Outline_Right : Players_Listbox_Outline_Left {
					x = 2 * MACRO_POS_SB_WIDTH_COLUMN + pixelW * MACRO_POS_SPACER_X;
				};
			};
		};
	};
};
