#define MACRO_FNC_ADDROLECTRLS(INPUTINDEX,INPUTROLENAME)											 \
																		 \
	class Role_##INPUTINDEX##_Weapon_Background : GVAR(RscFrame) {										 \
		idc = __EVAL([															 \
			MACRO_IDC_SM_ROLE_SPECOPS_BACKGROUND,											 \
			MACRO_IDC_SM_ROLE_SNIPER_BACKGROUND,											 \
			MACRO_IDC_SM_ROLE_ASSAULT_BACKGROUND,											 \
			MACRO_IDC_SM_ROLE_SUPPORT_BACKGROUND,											 \
			MACRO_IDC_SM_ROLE_ENGINEER_BACKGROUND,											 \
			MACRO_IDC_SM_ROLE_MEDIC_BACKGROUND,											 \
			MACRO_IDC_SM_ROLE_ANTITANK_BACKGROUND											 \
		] select INPUTINDEX);														 \
		colorBackground[] = CURLY(MACRO_COLOUR_A50_WHITE);										 \
		x = pixelW * MACRO_POS_SPACER_X;												 \
		y = MACRO_POS_SM_MENU_HEIGHT * (INPUTINDEX / 7) + pixelH * MACRO_POS_SPACER_Y;							 \
		w = MACRO_POS_SM_WIDTH / 3 - pixelW * (MACRO_POS_SPACER_X * 2 + 1);								 \
		h = MACRO_POS_SM_MENU_HEIGHT / 7 - pixelH * MACRO_POS_SPACER_Y;									 \
	};																	 \
																		 \
	class Role_##INPUTINDEX##_Frame : GVAR(RscFrame) {											 \
		idc = __EVAL([															 \
			MACRO_IDC_SM_ROLE_SPECOPS_FRAME,											 \
			MACRO_IDC_SM_ROLE_SNIPER_FRAME,												 \
			MACRO_IDC_SM_ROLE_ASSAULT_FRAME,											 \
			MACRO_IDC_SM_ROLE_SUPPORT_FRAME,											 \
			MACRO_IDC_SM_ROLE_ENGINEER_FRAME,											 \
			MACRO_IDC_SM_ROLE_MEDIC_FRAME,												 \
			MACRO_IDC_SM_ROLE_ANTITANK_FRAME											 \
		] select INPUTINDEX);														 \
		text = INPUTROLENAME;														 \
		colorBackground[] = CURLY(MACRO_COLOUR_BUTTON_ACTIVE);										 \
		x = pixelW * MACRO_POS_SPACER_X;												 \
		y = MACRO_POS_SM_MENU_HEIGHT * (INPUTINDEX / 7) + pixelH * MACRO_POS_SPACER_Y;							 \
		w = MACRO_POS_SM_WIDTH / 3 - pixelW * (MACRO_POS_SPACER_X * 2 + 1);								 \
		h = safeZoneH * 0.03;														 \
	};																	 \
																		 \
	class Role_##INPUTINDEX##_Shadow_Picture : GVAR(RscPicture) {										 \
		idc = __EVAL([															 \
			MACRO_IDC_SM_ROLE_SPECOPS_SHADOW_PICTURE,										 \
			MACRO_IDC_SM_ROLE_SNIPER_SHADOW_PICTURE,										 \
			MACRO_IDC_SM_ROLE_ASSAULT_SHADOW_PICTURE,										 \
			MACRO_IDC_SM_ROLE_SUPPORT_SHADOW_PICTURE,										 \
			MACRO_IDC_SM_ROLE_ENGINEER_SHADOW_PICTURE,										 \
			MACRO_IDC_SM_ROLE_MEDIC_SHADOW_PICTURE,											 \
			MACRO_IDC_SM_ROLE_ANTITANK_SHADOW_PICTURE										 \
		] select INPUTINDEX);														 \
		colorText[] = {0, 0, 0, 0.25};													 \
		text = "\A3\Weapons_F_EPB\Rifles\MX_Black\Data\UI\gear_mx_rifle_gl_black_X_CA.paa";						 \
		x = pixelW * MACRO_POS_SPACER_X;												 \
		y = MACRO_POS_SM_MENU_HEIGHT * (INPUTINDEX / 7) + pixelH * MACRO_POS_SPACER_Y + safeZoneH * 0.03;				 \
		w = MACRO_POS_SM_WIDTH / 3 - pixelW * (MACRO_POS_SPACER_X * 2 + 1) - safeZoneW * 0.1;						 \
		h = MACRO_POS_SM_MENU_HEIGHT / 7 - pixelH * MACRO_POS_SPACER_Y - safeZoneH * 0.03;						 \
	};																	 \
																		 \
	class Role_##INPUTINDEX##_Weapon_Picture : Role_##INPUTINDEX##_Shadow_Picture {								 \
		idc = __EVAL([															 \
			MACRO_IDC_SM_ROLE_SPECOPS_WEAPON_PICTURE,										 \
			MACRO_IDC_SM_ROLE_SNIPER_WEAPON_PICTURE,										 \
			MACRO_IDC_SM_ROLE_ASSAULT_WEAPON_PICTURE,										 \
			MACRO_IDC_SM_ROLE_SUPPORT_WEAPON_PICTURE,										 \
			MACRO_IDC_SM_ROLE_ENGINEER_WEAPON_PICTURE,										 \
			MACRO_IDC_SM_ROLE_MEDIC_WEAPON_PICTURE,											 \
			MACRO_IDC_SM_ROLE_ANTITANK_WEAPON_PICTURE										 \
		] select INPUTINDEX);														 \
		colorText[] = {1, 1, 1, 1};													 \
		x = 0;																 \
		y = MACRO_POS_SM_MENU_HEIGHT * (INPUTINDEX / 7) + safeZoneH * 0.03;								 \
	};																	 \
																		 \
	class Role_##INPUTINDEX##_Outline : GVAR(RscOutline) {											 \
		x = pixelW * MACRO_POS_SPACER_X;												 \
		y = MACRO_POS_SM_MENU_HEIGHT * (INPUTINDEX / 7) + pixelH * MACRO_POS_SPACER_Y;							 \
		w = MACRO_POS_SM_WIDTH / 3 - pixelW * (MACRO_POS_SPACER_X * 2 + 1);								 \
		h = MACRO_POS_SM_MENU_HEIGHT / 7 - pixelH * MACRO_POS_SPACER_Y;									 \
	};																	 \
																		 \
	class Role_##INPUTINDEX##_Button : GVAR(RscFrameFocused) {										 \
		idc = __EVAL([															 \
			MACRO_IDC_SM_ROLE_SPECOPS_BUTTON,											 \
			MACRO_IDC_SM_ROLE_SNIPER_BUTTON,											 \
			MACRO_IDC_SM_ROLE_ASSAULT_BUTTON,											 \
			MACRO_IDC_SM_ROLE_SUPPORT_BUTTON,											 \
			MACRO_IDC_SM_ROLE_ENGINEER_BUTTON,											 \
			MACRO_IDC_SM_ROLE_MEDIC_BUTTON,												 \
			MACRO_IDC_SM_ROLE_ANTITANK_BUTTON											 \
		] select INPUTINDEX);														 \
		x = pixelW * MACRO_POS_SPACER_X;												 \
		y = MACRO_POS_SM_MENU_HEIGHT * (INPUTINDEX / 7) + pixelH * MACRO_POS_SPACER_Y;							 \
		w = MACRO_POS_SM_WIDTH / 3 - pixelW * (MACRO_POS_SPACER_X * 2 + 1);								 \
		h = MACRO_POS_SM_MENU_HEIGHT / 7 - pixelH * MACRO_POS_SPACER_Y;									 \
		onMouseButtonDown =		__EVAL(format ["['ui_button_click', _this] call %1", QFUNC(ui_spawnMenu)]);			 \
		onMouseButtonDblClick =		__EVAL(format ["['ui_focus_reset'] call %1", QFUNC(ui_spawnMenu)]);				 \
	};																	 \

//	class Role_##INPUTINDEX##_Weapon_Highlight : GVAR(RscPictureNoAR) {									 \
//		colorText[] = {1, 1, 1, 0.25};													 \
//		text = "res\images\weapon_background.paa";											 \
//		x = pixelW * MACRO_POS_SPACER_X;												 \
//		y = MACRO_POS_SM_MENU_HEIGHT * (INPUTINDEX / 7) + pixelH * MACRO_POS_SPACER_Y + safeZoneH * 0.03;				 \
//		w = MACRO_POS_SM_WIDTH / 3 - pixelW * (MACRO_POS_SPACER_X * 2 + 1);								 \
//		h = MACRO_POS_SM_MENU_HEIGHT / 7 - pixelH * MACRO_POS_SPACER_Y - safeZoneH * 0.03;						 \
//	};																	 \
//																		 \

//	class Role_##INPUTINDEX##_Icon_Picture : GVAR(RscPicture) {										 \
//		text = __EVAL(format ["%1%2%3", "res\images\roles\role_", 'INPUTROLE', ".paa"]);						 \
//		x = MACRO_POS_SM_WIDTH / 3 - pixelW * (MACRO_POS_SPACER_X + 1) - safeZoneW * 0.03;						 \
//		y = MACRO_POS_SM_MENU_HEIGHT * (INPUTINDEX / 7) + pixelH * MACRO_POS_SPACER_Y;							 \
//		w = safeZoneW * 0.03;														 \
//		h = safeZoneH * 0.03;														 \
//	};																	 \
