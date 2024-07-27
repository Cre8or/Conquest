/*
----------------------------------------	ROLE LOADOUTS (INDFOR / RESISTANCE)	----------------------------------------

USAGE:

	1:	Copy the loadout that you want to edit (large array under every role enum macro)
	2:	Apply the loadout onto yourself (either using ACE3's Arsenal, or the setUnitLoadout scripting command)
	3:	Modify the loadout to your heart's content
	4:	Export the edited loadout back into the array format (either using ACE3's Arsenal, or the getUnitLoad scripting command)
	5:	Paste the loadout into the corresponding role array
	6:	Save
	7:	Done!

	*DO NOT ADD ANYTHING ELSE* - NOT EVEN A COMMA (,) OR A SEMICOLON (;) AT THE END OF THE FILE! NOTHING! NYET! NADA!

	NOTE: Even if you're not using this side, DO NOT EMPTY THIS FILE! Otherwise, things WILL break! Just leave the default values in, instead.	*/





[
	[	// Spec Ops
		MACRO_ENUM_ROLE_SPECOPS,
		//[["arifle_TRG21_GL_F","muzzle_snds_M","acc_flashlight","optic_MRCO",["30Rnd_556x45_Stanag",30],["1Rnd_HE_Grenade_shell",1],""],[],["hgun_Pistol_heavy_01_F","","","optic_MRD",["11Rnd_45ACP_Mag",11],[],""],["U_B_CTRG_3",[["ACE_fieldDressing",2],["ACE_packingBandage",3],["ACE_morphine",2],["ACE_tourniquet",2],["ACE_epinephrine",1],["ACE_salineIV_250",1],["ACE_splint",2],["SmokeShell",1,1],["Chemlight_green",1,1]]],["V_TacVestIR_blk",[["11Rnd_45ACP_Mag",2,11],["SmokeShellGreen",1,1],["Chemlight_green",1,1],["1Rnd_HE_Grenade_shell",5,1],["30Rnd_556x45_Stanag_Tracer_Red",9,30],["HandGrenade",2,1]]],["B_Carryall_green_F",[["ToolKit",1],["MineDetector",1]]],"H_Cap_khaki_specops_UK","",["Binocular","","","",[],[],""],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch","ACE_NVG_Gen4"]]
		[["arifle_TRG21_F","","acc_flashlight","optic_ACO_grn_smg",["30Rnd_556x45_Stanag_Tracer_Green",30],[],""],[],["hgun_Pistol_heavy_01_green_F","muzzle_snds_acp","acc_flashlight_pistol","",["11Rnd_45ACP_Mag",15],[],""],["U_I_CombatUniform",[["ACE_elasticBandage",10],["ACE_morphine",5],["ACE_DefusalKit",1]]],["V_PlateCarrierIA2_dgtl",[["HandGrenade",1,1],["11Rnd_45ACP_Mag",2,15],["30Rnd_556x45_Stanag_Tracer_Green",7,30]]],[],"H_MilCap_dgtl","",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
	],





	[	// Sniper
		MACRO_ENUM_ROLE_SNIPER,
		[["srifle_DMR_05_tan_f","","acc_flashlight","optic_KHS_blk",["10Rnd_93x64_DMR_05_Mag",10],[],"bipod_02_F_hex"],[],["hgun_Rook40_F","","","",["16Rnd_9x21_green_Mag",17],[],""],["U_O_FullGhillie_sard",[["ACE_elasticBandage",10],["ACE_morphine",5],["ACE_DefusalKit",1]]],["V_Chestrig_rgr",[["HandGrenade",1,1],["APERSTripMine_Wire_Mag",1,1],["ACE_FlareTripMine_Mag",1,1],["10Rnd_93x64_DMR_05_Mag",4,10],["16Rnd_9x21_green_Mag",2,17]]],[],"","G_Balaclava_oli",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
	],





	[	// Assault
		MACRO_ENUM_ROLE_ASSAULT,
		[["arifle_Katiba_GL_F","","acc_flashlight","optic_ACO_grn_smg",["30Rnd_65x39_caseless_green_mag_Tracer",30],["1Rnd_HE_Grenade_shell",1],""],[],["hgun_Rook40_F","","","",["16Rnd_9x21_green_Mag",17],[],""],["U_I_CombatUniform",[["ACE_elasticBandage",10],["ACE_morphine",5]]],["V_TacVest_brn",[["1Rnd_HE_Grenade_shell",3,1],["16Rnd_9x21_green_Mag",2,17],["30Rnd_65x39_caseless_green_mag_Tracer",6,30]]],[],"H_HelmetO_ocamo","",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
	],





	[	// Support
		MACRO_ENUM_ROLE_SUPPORT,
		[["LMG_Zafir_F","","acc_flashlight","optic_ACO_grn_smg",["150Rnd_762x54_Box_Tracer",150],[],""],[],["hgun_Rook40_F","","","",["16Rnd_9x21_green_Mag",17],[],""],["U_I_CombatUniform_shortsleeve",[["ACE_elasticBandage",10],["ACE_morphine",5]]],["V_TacVest_khk",[["16Rnd_9x21_green_Mag",2,17],["150Rnd_762x54_Box_Tracer",1,150],["HandGrenade",1,1]]],["B_FieldPack_cbr",[["150Rnd_762x54_Box_Tracer",2,150]]],"H_HelmetO_ocamo","G_Bandanna_beast",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
	],





	[	// Engineer
		MACRO_ENUM_ROLE_ENGINEER,
		[["arifle_ARX_hex_F","","acc_flashlight","optic_ACO_grn_smg",["30Rnd_65x39_caseless_green_mag_Tracer",30],[],""],[],["hgun_Rook40_F","","","",["16Rnd_9x21_green_Mag",17],[],""],["U_I_CombatUniform",[["ACE_elasticBandage",10],["ACE_morphine",5],["ACE_DefusalKit",1],["MineDetector",1]]],["V_TacVest_brn",[["16Rnd_9x21_green_Mag",2,17],["HandGrenade",1,1],["30Rnd_65x39_caseless_green_mag_Tracer",7,30]]],["B_AssaultPack_ocamo",[["SLAMDirectionalMine_Wire_Mag",3,1]]],"H_HelmetO_ocamo","G_Bandanna_blk",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
	],





	[	// Medic
		MACRO_ENUM_ROLE_MEDIC,
		[["arifle_CTAR_hex_F","","acc_flashlight","optic_ACO_grn_smg",["30Rnd_580x42_Mag_Tracer_F",30],[],""],[],["hgun_Rook40_F","","","",["16Rnd_9x21_green_Mag",17],[],""],["U_I_CombatUniform",[["ACE_elasticBandage",10],["ACE_morphine",5],["ACE_personalAidKit",2]]],["V_TacVest_khk",[["16Rnd_9x21_green_Mag",2,17],["30Rnd_580x42_Mag_Tracer_F",7,30],["SmokeShell",2,1]]],["B_AssaultPack_cbr",[["ACE_personalAidKit",16]]],"H_HelmetSpecO_ocamo","",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
	],





	[	// Anti Tank
		MACRO_ENUM_ROLE_ANTITANK,
		[["arifle_Katiba_F","","acc_flashlight","optic_ACO_grn_smg",["30Rnd_65x39_caseless_green_mag_Tracer",30],[],""],["launch_RPG32_F","","","",["RPG32_F",1],[],""],["hgun_Rook40_F","","","",["16Rnd_9x21_green_Mag",17],[],""],["U_I_CombatUniform",[["ACE_elasticBandage",10],["ACE_morphine",5]]],["V_TacVest_khk",[["16Rnd_9x21_green_Mag",2,17],["30Rnd_65x39_caseless_green_mag_Tracer",7,30],["HandGrenade",1,1]]],["B_Kitbag_cbr",[["RPG32_F",2,1]]],"H_HelmetO_ocamo","G_Balaclava_blk",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
	]
]
