/*
---------------------------------------- SIDE DATA FILE (OPFOR / EAST) ----------------------------------------

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
	"CSAT",

	// Side name (long format, ideally up to 40 characters)
	"Canton Protocol Strategic Alliance Treaty",

	// Texture path to a flag representing this side (ArmA 3 has many country flags you can use)
	"a3\data_f\Flags\flag_CSAT_co.paa",

	// The sets of faces that AI units on this side should use. Intended for immersion.
	// Possible values: "african", "african_camo", "asian", "asian_camo", "greek", "greek_camo", "livonian", "persian", "persian_camo", "russian", "tanoan", "white", "white_camo"
	// NOTE: This setting accepts a single value (e.g. "greek"), or an array of values (e.g. ["african", "african_camo"])
	["persian", "persian_camo"],

	// The spoken voice presets that AI units on this side should use (for things like automatic call-outs). Intended for immersion.
	// Possible values: "chinese", "english_fr", "english_gr", "english_uk", "english_us", "farsi", "french", "polish", "russian"
	// NOTE: This setting accepts a single value (e.g. "farsi"), or an array of values (e.g. ["english_uk", "english_us"])
	"farsi",





	// Loadouts
	[
		[	// Spec Ops
			MACRO_ENUM_ROLE_SPECOPS,
			[["arifle_Katiba_F","","acc_flashlight","optic_ACO_grn",["30Rnd_65x39_caseless_green_mag_Tracer",30],[],""],[],["hgun_ACPC2_F","muzzle_snds_acp","","",["9Rnd_45ACP_Mag",8],[],""],["U_O_CombatUniform_ocamo",[]],["V_TacVest_brn",[["9Rnd_45ACP_Mag",3,8],["30Rnd_65x39_caseless_green_mag_Tracer",6,30],["HandGrenade",1,1]]],[],"H_ShemagOpen_tan","",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],





		[	// Sniper
			MACRO_ENUM_ROLE_SNIPER,
			[["srifle_DMR_05_tan_f","","acc_flashlight","optic_KHS_blk",["10Rnd_93x64_DMR_05_Mag",10],[],"bipod_02_F_hex"],[],["hgun_Rook40_F","","","",["16Rnd_9x21_green_Mag",17],[],""],["U_O_FullGhillie_sard",[]],["V_Chestrig_rgr",[["HandGrenade",1,1],["10Rnd_93x64_DMR_05_Mag",7,10],["16Rnd_9x21_green_Mag",2,17]]],[],"","G_Balaclava_oli",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],





		[	// Assault
			MACRO_ENUM_ROLE_ASSAULT,
			[["arifle_Katiba_GL_F","","acc_flashlight","optic_ACO_grn",["30Rnd_65x39_caseless_green_mag_Tracer",30],["1Rnd_HE_Grenade_shell",1],""],[],["hgun_Rook40_F","","","",["16Rnd_9x21_green_Mag",17],[],""],["U_O_CombatUniform_ocamo",[]],["V_TacVest_brn",[["1Rnd_HE_Grenade_shell",4,1],["16Rnd_9x21_green_Mag",2,17],["30Rnd_65x39_caseless_green_mag_Tracer",6,30]]],[],"H_HelmetO_ocamo","",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],





		[	// Support
			MACRO_ENUM_ROLE_SUPPORT,
			[["LMG_Zafir_F","","acc_flashlight","optic_ACO_grn",["150Rnd_762x54_Box_Tracer",150],[],""],[],["hgun_Rook40_F","","","",["16Rnd_9x21_green_Mag",17],[],""],["U_O_CombatUniform_ocamo",[]],["V_TacVest_khk",[["16Rnd_9x21_green_Mag",2,17],["150Rnd_762x54_Box_Tracer",1,150],["HandGrenade",1,1]]],["B_FieldPack_cbr",[["150Rnd_762x54_Box_Tracer",2,150]]],"H_HelmetO_ocamo","G_Bandanna_beast",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]],
			[MACRO_ENUM_LOADOUT_ABILITY_RESUPPLY]
		],





		[	// Engineer
			MACRO_ENUM_ROLE_ENGINEER,
			[["arifle_ARX_hex_F","","acc_flashlight","optic_ACO_grn",["30Rnd_65x39_caseless_green_mag_Tracer",30],[],""],[],["hgun_Rook40_F","","","",["16Rnd_9x21_green_Mag",17],[],""],["U_O_CombatUniform_ocamo",[["MineDetector",1]]],["V_TacVest_brn",[["16Rnd_9x21_green_Mag",2,17],["HandGrenade",1,1],["30Rnd_65x39_caseless_green_mag_Tracer",7,30]]],["B_AssaultPack_ocamo",[["SLAMDirectionalMine_Wire_Mag",3,1]]],"H_HelmetO_ocamo","G_Bandanna_blk",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]],
			[MACRO_ENUM_LOADOUT_ABILITY_REPAIR]
		],





		[	// Medic
			MACRO_ENUM_ROLE_MEDIC,
			[["arifle_CTAR_hex_F","","acc_flashlight","optic_ACO_grn",["30Rnd_580x42_Mag_Tracer_F",30],[],""],[],["hgun_Rook40_F","","","",["16Rnd_9x21_green_Mag",17],[],""],["U_O_CombatUniform_ocamo",[]],["V_TacVest_khk",[["16Rnd_9x21_green_Mag",2,17],["30Rnd_580x42_Mag_Tracer_F",7,30],["SmokeShell",2,1]]],["B_AssaultPack_cbr",[]],"H_HelmetSpecO_ocamo","",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]],
			[MACRO_ENUM_LOADOUT_ABILITY_HEAL]
		],





		[	// Anti Tank
			MACRO_ENUM_ROLE_ANTITANK,
			[["arifle_Katiba_F","","acc_flashlight","optic_ACO_grn",["30Rnd_65x39_caseless_green_mag_Tracer",30],[],""],["launch_RPG32_F","","","",["RPG32_F",1],[],""],["hgun_Rook40_F","","","",["16Rnd_9x21_green_Mag",17],[],""],["U_O_CombatUniform_ocamo",[]],["V_TacVest_khk",[["16Rnd_9x21_green_Mag",2,17],["30Rnd_65x39_caseless_green_mag_Tracer",7,30],["HandGrenade",1,1]]],["B_Kitbag_cbr",[["RPG32_F",2,1]]],"H_HelmetO_ocamo","G_Balaclava_blk",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		]
	]
]
