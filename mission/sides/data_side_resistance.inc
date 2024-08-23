/*
---------------------------------------- SIDE DATA FILE (INDFOR / RESISTANCE) ----------------------------------------

USAGE:

	Modifying loadouts:
		1:	Copy the loadout that you want to edit (large array under every role enum macro)
		2:	Apply the loadout onto yourself (either using ACE3's Arsenal, or the setUnitLoadout scripting command)
		3:	Modify the loadout to your heart's content
		4:	Export the edited loadout back into the array format (using the getUnitLoad scripting command)
		5:	Paste the loadout into the corresponding role array
		6:	Save
		7:	Done!

	*DO NOT ADD ANYTHING ELSE* - NOT EVEN A COMMA (,) OR A SEMICOLON (;) AT THE END OF THE FILE! NOTHING! NYET! NADA! */

#include "..\..\res\common\macros.inc"





[
	// Side name (short format, ideally 5 characters or less)
	"AAF",

	// Side name (long format, ideally up to 40 characters)
	"Altis Armed Forces",

	// Texture path to a flag representing this side (ArmA 3 has many country flags you can use)
	"a3\data_f\Flags\flag_AAF_co.paa",

	// The sets of faces that AI units on this side should use. Intended for immersion.
	// Possible values: "african", "african_camo", "asian", "asian_camo", "greek", "greek_camo", "livonian", "persian", "persian_camo", "russian", "tanoan", "white", "white_camo"
	// NOTE: This setting accepts a single value (e.g. "greek"), or an array of values (e.g. ["african", "african_camo"])
	"english_gr",

	// The spoken voice presets that AI units on this side should use (for things like automatic call-outs). Intended for immersion.
	// Possible values: "chinese", "english_fr", "english_gr", "english_uk", "english_us", "farsi", "french", "polish", "russian"
	// NOTE: This setting accepts a single value (e.g. "farsi"), or an array of values (e.g. ["english_uk", "english_us"])
	["greek", "greek_camo"],





	// Loadouts
	[
		[	// Spec Ops
			MACRO_ENUM_ROLE_SPECOPS,
			[["arifle_MX_Black_F","","acc_flashlight","optic_Aco",["30Rnd_65x39_caseless_black_mag_Tracer",30],[],""],[],["hgun_Pistol_heavy_01_MRD_F","muzzle_snds_acp","acc_flashlight_pistol","",["11Rnd_45ACP_Mag",11],[],""],["U_B_CombatUniform_mcam",[]],["V_PlateCarrier2_rgr",[["30Rnd_65x39_caseless_black_mag_Tracer",7,30],["HandGrenade",1,1],["11Rnd_45ACP_Mag",2,11]]],[],"H_Cap_headphones","G_Combat",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],





		[	// Sniper
			MACRO_ENUM_ROLE_SNIPER,
			[["srifle_DMR_02_camo_F","","acc_flashlight","optic_KHS_blk",["10Rnd_338_Mag",10],[],"bipod_01_F_blk"],[],["hgun_P07_F","","","",["16Rnd_9x21_red_Mag",17],[],""],["U_B_FullGhillie_sard",[]],["V_Chestrig_rgr",[["HandGrenade",1,1],["16Rnd_9x21_red_Mag",2,17],["10Rnd_338_Mag",7,10]]],[],"","G_Bandanna_tan",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],





		[	// Assault
			MACRO_ENUM_ROLE_ASSAULT,
			[["arifle_MX_GL_Black_F","","acc_flashlight","optic_Aco",["30Rnd_65x39_caseless_black_mag_Tracer",30],["1Rnd_HE_Grenade_shell",1],""],[],["hgun_P07_F","","","",["16Rnd_9x21_red_Mag",17],[],""],["U_B_CombatUniform_mcam",[]],["V_PlateCarrier1_rgr",[["30Rnd_65x39_caseless_black_mag_Tracer",7,30],["16Rnd_9x21_red_Mag",2,17],["1Rnd_HE_Grenade_shell",4,1]]],[],"H_HelmetSpecB","",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],





		[	// Support
			MACRO_ENUM_ROLE_SUPPORT,
			[["LMG_03_F","","acc_flashlight","",["200Rnd_556x45_Box_Tracer_Red_F",200],[],""],[],["hgun_P07_F","","","",["16Rnd_9x21_red_Mag",17],[],""],["U_B_CombatUniform_mcam_vest",[]],["V_PlateCarrier1_rgr",[["200Rnd_556x45_Box_Tracer_Red_F",2,200],["HandGrenade",1,1],["16Rnd_9x21_red_Mag",2,17]]],["B_Kitbag_mcamo",[]],"H_HelmetB_sand","G_Combat",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]],
			[MACRO_ENUM_LOADOUT_ABILITY_RESUPPLY]
		],





		[	// Engineer
			MACRO_ENUM_ROLE_ENGINEER,
			[["SMG_02_F","","acc_flashlight","optic_Aco",["30Rnd_9x21_Mag_SMG_02_Tracer_Red",30],[],""],[],["hgun_P07_F","","","",["16Rnd_9x21_red_Mag",17],[],""],["U_B_CombatUniform_mcam",[["MineDetector",1]]],["V_PlateCarrier2_rgr",[["16Rnd_9x21_red_Mag",2,17],["HandGrenade",1,1],["30Rnd_9x21_Mag_SMG_02_Tracer_Red",9,30]]],["B_AssaultPack_khk",[["SLAMDirectionalMine_Wire_Mag",3,1]]],"H_HelmetB_grass","G_Balaclava_TI_blk_F",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]],
			[MACRO_ENUM_LOADOUT_ABILITY_REPAIR]
		],





		[	// Medic
			MACRO_ENUM_ROLE_MEDIC,
			[["arifle_SPAR_01_blk_F","","acc_flashlight","optic_Holosight_blk_F",["30Rnd_556x45_Stanag_Tracer_Red",30],[],""],[],["hgun_P07_F","","","",["16Rnd_9x21_red_Mag",17],[],""],["U_B_CombatUniform_mcam",[]],["V_PlateCarrier1_rgr",[["16Rnd_9x21_red_Mag",2,17],["30Rnd_556x45_Stanag_Tracer_Red",7,30],["SmokeShell",2,1]]],["B_AssaultPack_mcamo",[]],"H_HelmetB_camo","G_Combat",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]],
			[MACRO_ENUM_LOADOUT_ABILITY_HEAL]
		],





		[	// Anti Tank
			MACRO_ENUM_ROLE_ANTITANK,
			[["arifle_MX_Black_F","","acc_flashlight","optic_Aco",["30Rnd_65x39_caseless_black_mag_Tracer",30],[],""],["launch_MRAWS_olive_rail_F","","","",["MRAWS_HEAT_F",1],[],""],["hgun_P07_F","","","",["16Rnd_9x21_red_Mag",17],[],""],["U_B_CombatUniform_mcam",[]],["V_PlateCarrier_Kerry",[["16Rnd_9x21_red_Mag",2,17],["30Rnd_65x39_caseless_black_mag_Tracer",7,30]]],["B_Kitbag_rgr",[["MRAWS_HEAT_F",2,1]]],"H_HelmetB_snakeskin","",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		]
	]
]
