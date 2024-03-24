/*
----------------------------------------	ROLE LOADOUTS (BLUFOR / WEST)		----------------------------------------

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
		[["arifle_MX_Black_F","","acc_flashlight","optic_Aco",["30Rnd_65x39_caseless_black_mag_Tracer",30],[],""],[],["hgun_Pistol_heavy_01_MRD_F","muzzle_snds_acp","acc_flashlight_pistol","",["11Rnd_45ACP_Mag",11],[],""],["U_B_CombatUniform_mcam",[["ACE_elasticBandage",10],["ACE_morphine",5],["ACE_DefusalKit",1]]],["V_PlateCarrier2_rgr",[["30Rnd_65x39_caseless_black_mag_Tracer",7,30],["HandGrenade",1,1],["11Rnd_45ACP_Mag",2,11]]],[],"H_Cap_headphones","G_Combat",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
	],





	[	// Sniper
		MACRO_ENUM_ROLE_SNIPER,
		[["srifle_DMR_02_camo_F","","acc_flashlight","optic_KHS_blk",["10Rnd_338_Mag",10],[],"bipod_01_F_blk"],[],["hgun_P07_F","","","",["16Rnd_9x21_red_Mag",16],[],""],["U_B_FullGhillie_sard",[["ACE_elasticBandage",10],["ACE_morphine",5],["ACE_DefusalKit",1]]],["V_Chestrig_rgr",[["HandGrenade",1,1],["APERSTripMine_Wire_Mag",1,1],["ACE_FlareTripMine_Mag",1,1],["16Rnd_9x21_red_Mag",2,16],["10Rnd_338_Mag",3,10]]],[],"","G_Bandanna_tan",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
	],





	[	// Assault
		MACRO_ENUM_ROLE_ASSAULT,
		[["arifle_MX_GL_Black_F","","acc_flashlight","optic_Aco",["30Rnd_65x39_caseless_black_mag_Tracer",30],["1Rnd_HE_Grenade_shell",1],""],[],["hgun_P07_F","","","",["16Rnd_9x21_red_Mag",16],[],""],["U_B_CombatUniform_mcam",[["ACE_elasticBandage",10],["ACE_morphine",5]]],["V_PlateCarrier1_rgr",[["30Rnd_65x39_caseless_black_mag_Tracer",7,30],["16Rnd_9x21_red_Mag",2,16],["1Rnd_HE_Grenade_shell",2,1]]],[],"H_HelmetSpecB","",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
	],





	[	// Support
		MACRO_ENUM_ROLE_SUPPORT,
		[["LMG_03_F","","acc_flashlight","",["200Rnd_556x45_Box_Tracer_Red_F",200],[],""],[],["hgun_P07_F","","","",["16Rnd_9x21_red_Mag",16],[],""],["U_B_CombatUniform_mcam_vest",[["ACE_elasticBandage",10],["ACE_morphine",5]]],["V_PlateCarrier1_rgr",[["200Rnd_556x45_Box_Tracer_Red_F",2,200],["HandGrenade",1,1],["16Rnd_9x21_red_Mag",2,16]]],["B_Kitbag_mcamo",[]],"H_HelmetB_sand","G_Combat",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
	],





	[	// Engineer
		MACRO_ENUM_ROLE_ENGINEER,
		[["SMG_02_F","","acc_flashlight","optic_Aco",["30Rnd_9x21_Mag_SMG_02_Tracer_Red",30],[],""],[],["hgun_P07_F","","","",["16Rnd_9x21_red_Mag",16],[],""],["U_B_CombatUniform_mcam",[["ACE_elasticBandage",10],["ACE_morphine",5],["ACE_DefusalKit",1],["MineDetector",1]]],["V_PlateCarrier2_rgr",[["16Rnd_9x21_red_Mag",2,16],["HandGrenade",1,1],["30Rnd_9x21_Mag_SMG_02_Tracer_Red",9,30]]],["B_AssaultPack_khk",[["SLAMDirectionalMine_Wire_Mag",3,1]]],"H_HelmetB_grass","G_Balaclava_TI_blk_F",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
	],





	[	// Medic
		MACRO_ENUM_ROLE_MEDIC,
		[["arifle_SPAR_01_blk_F","","acc_flashlight","optic_Holosight_blk_F",["30Rnd_556x45_Stanag_Tracer_Red",30],[],""],[],["hgun_P07_F","","","",["16Rnd_9x21_red_Mag",16],[],""],["U_B_CombatUniform_mcam",[["ACE_elasticBandage",10],["ACE_morphine",5],["ACE_personalAidKit",2]]],["V_PlateCarrier1_rgr",[["16Rnd_9x21_red_Mag",2,16],["30Rnd_556x45_Stanag_Tracer_Red",7,30],["SmokeShell",2,1]]],["B_AssaultPack_mcamo",[["ACE_personalAidKit",16]]],"H_HelmetB_camo","G_Combat",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
	],





	[	// Anti Tank
		MACRO_ENUM_ROLE_ANTITANK,
		[["arifle_MX_Black_F","","acc_flashlight","optic_Aco",["30Rnd_65x39_caseless_black_mag_Tracer",30],[],""],["launch_MRAWS_olive_rail_F","","","",["MRAWS_HEAT_F",1],[],""],["hgun_P07_F","","","",["16Rnd_9x21_red_Mag",16],[],""],["U_B_CombatUniform_mcam",[["ACE_elasticBandage",10],["ACE_morphine",5]]],["V_PlateCarrier_Kerry",[["16Rnd_9x21_red_Mag",2,16],["30Rnd_65x39_caseless_black_mag_Tracer",7,30]]],["B_Kitbag_rgr",[["MRAWS_HEAT_F",2,1]]],"H_HelmetB_snakeskin","",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
	]
]
