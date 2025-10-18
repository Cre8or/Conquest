/*
--------------------------------------------------- FACTION DATA FILE ---------------------------------------------------

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
	// Identity
	[
		// Faction name (short format, ideally up to 5 characters)
		"AFRF",

		// Faction name (long format, ideally up to 40 characters)

		"Armed Forces of the Russian Federation",

		// Texture path to a flag representing this faction (tip: ArmA 3 has many country flags you can use)
		"ca\data\flag_rus_co.paa",

		// The face presets that AI units of this faction should use.
		// Possible values: "african", "african_camo", "asian", "asian_camo", "greek", "greek_camo", "livonian", "persian", "persian_camo", "russian", "tanoan", "white", "white_camo"
		// NOTE: This setting either accepts a single value (e.g. "greek"), or an array of values (e.g. ["african", "african_camo"])
		["livonian", "white", "white_camo"],

		// The voice presets that AI units of this faction should use (for things like automatic call-outs).
		// Possible values: "chinese", "english_fr", "english_gr", "english_uk", "english_us", "farsi", "french", "polish", "russian"
		// NOTE: This setting accepts a single value (e.g. "farsi"), or an array of values (e.g. ["english_uk", "english_us"])
		"russian"
	],



	// Loadouts
	[
		[	// Spec Ops
			MACRO_ENUM_ROLE_SPECOPS,
			[["CUP_arifle_AK104","CUP_muzzle_Bizon","acc_flashlight","CUP_optic_Kobra",["CUP_30Rnd_TE1_Green_Tracer_762x39_AK103_bakelite_M",30],[],""],[],["hgun_Rook40_F","muzzle_snds_L","","",["16Rnd_9x21_green_Mag",17],[],""],["CUP_U_O_RUS_EMR_rolled_up_gloves_pads",[]],["CUP_V_O_RUS_6B45_AK_Radio_Summer",[["16Rnd_9x21_green_Mag",2,17],["HandGrenade",1,1],["CUP_30Rnd_TE1_Green_Tracer_762x39_AK103_bakelite_M",7,30]]],["CUP_B_RUS_Backpack",[]],"CUP_H_PMC_Beanie_Headphones_Black","CUP_G_ESS_BLK_Facewrap_Black",["Binocular","","","",[],[],""],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],

		[	// Sniper
			MACRO_ENUM_ROLE_SNIPER,
			[["CUP_srifle_G22_wdl","","","optic_DMS",["CUP_5Rnd_762x67_G22",5],[],""],[],["hgun_Rook40_F","","","",["16Rnd_9x21_green_Mag",17],[],""],["CUP_U_O_RUS_VSR93_worn_VDV_rolled_up_gloves2",[]],["CUP_V_O_RUS_6B45_6Sh117_SVD_2_Summer",[["16Rnd_9x21_green_Mag",2,17],["CUP_5Rnd_762x67_G22",9,5],["HandGrenade",1,1]]],[],"CUP_H_RUS_Ratnik_Balaclava_6M21_Green_1","",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],

		[	// Assault
			MACRO_ENUM_ROLE_ASSAULT,
			[["CUP_arifle_AK74M_GL","","CUP_acc_Flashlight","",["CUP_30Rnd_TE1_Green_Tracer_545x39_AK74M_M",30],["CUP_1Rnd_HE_GP25_M",1],""],[],["hgun_Rook40_F","","","",["16Rnd_9x21_green_Mag",17],[],""],["CUP_U_O_RUS_EMR_gloves_pads",[]],["CUP_V_O_RUS_6B45_SPP_VOG_Summer",[["16Rnd_9x21_green_Mag",2,17],["CUP_30Rnd_TE1_Green_Tracer_545x39_AK74M_M",7,30],["CUP_1Rnd_HE_GP25_M",4,1]]],[],"CUP_H_RUS_6B47_6M2_6B34D_Summer","CUP_G_RUS_Ratnik_Balaclava_Green_1",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],

		[	// Support
			MACRO_ENUM_ROLE_SUPPORT,
			[["CUP_lmg_Pecheneg_woodland","","","",["150Rnd_762x54_Box_Tracer",150],[],""],[],["hgun_Rook40_F","","","",["16Rnd_9x21_green_Mag",17],[],""],["CUP_U_O_RUS_Soldier_Gorka_EMR_3",[]],["CUP_V_O_RUS_6B45_6Sh117_PKP_Radio_Summer",[["16Rnd_9x21_green_Mag",2,17],["HandGrenade",1,1],["150Rnd_762x54_Box_Tracer",2,150]]],["B_Carryall_green_F",[]],"CUP_H_RUS_Altyn_Shield_Up_black","CUP_G_RUS_Ratnik_Balaclava_Winter_Green_2",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],

		[	// Engineer
			MACRO_ENUM_ROLE_ENGINEER,
			[["CUP_arifle_AKS74U","","","CUP_optic_Kobra",["CUP_30Rnd_TE1_Green_Tracer_545x39_AK74_plum_M",30],[],""],[],["hgun_Rook40_F","","","",["16Rnd_9x21_green_Mag",17],[],""],["CUP_U_O_RUS_EMR_2_VDV",[]],["CUP_V_O_RUS_6B45_6Sh117_AK_Med_Radio_Summer",[["16Rnd_9x21_green_Mag",2,17],["HandGrenade",1,1],["CUP_30Rnd_TE1_Green_Tracer_545x39_AK74_plum_M",7,30]]],["B_Kitbag_sgg",[]],"CUP_H_RUS_6B47_6M21_6B34C_Summer","CUP_G_RUS_Ratnik_Balaclava_EMR_Summer_1",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],

		[	// Medic
			MACRO_ENUM_ROLE_MEDIC,
			[["CUP_arifle_AK74M_camo","","CUP_acc_Flashlight","CUP_optic_ekp_8_02",["CUP_30Rnd_TE1_Green_Tracer_545x39_AK_camo_M",30],[],""],[],["hgun_Rook40_F","","","",["16Rnd_9x21_green_Mag",17],[],""],["CUP_U_O_RUS_EMR_VDV_gloves_pads",[]],["CUP_V_O_RUS_6B45_6Sh117_SPP_AK_Med_Summer",[["16Rnd_9x21_green_Mag",2,17],["CUP_30Rnd_TE1_Green_Tracer_545x39_AK_camo_M",7,30],["SmokeShell",2,1]]],["B_FieldPack_green_F",[]],"CUP_H_RUS_6B47_NV_6M21_6B34C_Summer","CUP_PMC_Facewrap_Black",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],

		[	// Anti Tank
			MACRO_ENUM_ROLE_ANTITANK,
			[["CUP_smg_bizon","","","CUP_optic_ekp_8_02",["CUP_64Rnd_Green_Tracer_9x19_Bizon_M",64],[],""],["CUP_launch_RPG7V","","","",["CUP_PG7V_M",1],[],""],["hgun_Rook40_F","","","",["16Rnd_9x21_green_Mag",17],[],""],["CUP_U_O_RUS_VSR93_MSV",[]],["CUP_V_O_RUS_6B45_AK_Med_Summer",[["16Rnd_9x21_green_Mag",2,17],["CUP_64Rnd_Green_Tracer_9x19_Bizon_M",3,64],["HandGrenade",1,1]]],["CUP_B_RUS_Backpack",[["CUP_PG7V_M",3,1]]],"CUP_H_RUS_6B47_6M2_6B34D_Summer","G_Balaclava_blk",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		]
	],



	// Vehicles
	[
/*		Template:
		[
			Vehicle type macro (e.g. MACRO_ENUM_VEHICLETYPE_APC_LIGHT)
			[ <- Array of vehicle entries for this type (contains 1 or more vehicle entries)
				[ <- A vehicle entry
					Vehicle classname
					Custom textures array (optional, default: [])
					Custom selections array (optional, default: [])
					Aircraft only: custom pylons (optional, default: [])
				]
			]
		]
*/
		[
			MACRO_ENUM_VEHICLETYPE_QUADBIKE,
			[
				["B_T_Quadbike_01_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_CAR_UNARMED_LIGHT,
			[
				["CUP_O_UAZ_Unarmed_RU","Green_Soviet",[["hide_spare_wheel",0],["hide_lower_tarp",0],["hide_upper_tarp",0]]]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_CAR_UNARMED_HEAVY,
			[
				["CUP_O_Tigr_233011_GREEN_RU",[[5,""],[6,""]],[["hide_tow_rope",1],["hide_tools",1],["hide_roof_rung",1],["hide_reseve_wheel_mount",1],["hide_ReserveWheel",1]]]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_CAR_ARMED_LIGHT,
			[
				["CUP_O_Tigr_233014_GREEN_PK_RU",[[5,""],[6,""]],[["hide_tow_rope",1],["hide_tools",1],["hide_roof_rung",1],["hide_reseve_wheel_mount",1],["hide_ReserveWheel",1]]],
				["CUP_O_UAZ_MG_RU","Green_Soviet",[["hide_spare_wheel",1]]],
				["CUP_O_GAZ_Vodnik_PK_RU"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_CAR_ARMED_HEAVY,
			[
				["CUP_O_Tigr_M_233114_GREEN_KORD_RU",[[5,""],[6,""]],[["hide_tow_rope",1],["hide_tools",1],["hide_roof_rung",1],["hide_reseve_wheel_mount",1],["hide_ReserveWheel",1]]],
				["CUP_O_GAZ_Vodnik_AGS_RU"],
				["CUP_O_UAZ_METIS_RU","Green_Soviet"],
				["CUP_O_GAZ_Vodnik_KPVT_RU"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_TRUCK_TRANSPORT,
			[
				["CUP_O_Ural_RU"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_APC_LIGHT,
			[
				["CUP_O_BTR80A_GREEN_RU"],
				["CUP_O_BTR80_GREEN_RU"],
				["CUP_O_GAZ_Vodnik_BPPU_RU"],
				["CUP_O_BRDM2_RUS","TKG"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_APC_HEAVY,
			[
				["CUP_O_BMP2_RU","NAPA"],
				["CUP_O_BTR90_RU","Russia_Green"],
				["CUP_O_BMP3_RU"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_AMPHIBIOUS_LIGHT,
			[
				["CUP_O_BRDM2_RUS","TKG"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_AMPHIBIOUS_HEAVY,
			[
				["CUP_I_BMP1_TK_GUE"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_AA_LIGHT,
			[
				["CUP_O_UAZ_AA_RU","Green_Soviet",[["hide_spare_wheel",1]]]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_AA_HEAVY,
			[
				["CUP_O_2S6M_RU"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_TANK_LIGHT,
			[
				["CUP_O_T72_RU"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_TANK_HEAVY,
			[
				["CUP_O_T90_RU","",[["hideLog",0],["hideBarrels",1]]],
				["CUP_O_T90M_RU"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_HELI_TRANSPORT_LIGHT,
			[
				["O_Heli_Light_02_unarmed_F",[[0,"cup\airvehicles\cup_airvehicles_ka60\data\ka60_ext_grey_co.paa"]]]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_HELI_TRANSPORT_HEAVY,
			[
				["CUP_O_Mi8AMT_RU"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_HELI_ATTACK_LIGHT,
			[
				["CUP_O_Ka60_Grey_RU"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_HELI_ATTACK_HEAVY,
			[
				["CUP_O_Mi24_V_Dynamic_RU",[[0,"cup\airvehicles\cup_airvehicles_mi24\data\mi24p_001_co.paa"],[1,"cup\airvehicles\cup_airvehicles_mi24\data\mi24p_002_co.paa"]]],
				["CUP_O_Ka52_RU","Grey"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_PLANE_AA,
			[
				["CUP_O_SU34_RU","SLA"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_PLANE_CAS,
			[
				["CUP_O_Su25_Dyn_RU","Russia1"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_BOAT_LIGHT,
			[
				["B_Boat_Transport_01_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_BOAT_HEAVY,
			[
				["CUP_B_RHIB_USMC"]
			]
		]
	],



	// AI Balancing
	[
		1.0 * MACRO_AI_SKILL_BASEACCURACY, // Overall accuracy multiplier

		// Per-role accuracy multipliers (cumulative with the overall multiplier)
		[
			[MACRO_ENUM_ROLE_SPECOPS,  1.0],
			[MACRO_ENUM_ROLE_SNIPER,   2.0], // By default, only snipers have better accuracy
			[MACRO_ENUM_ROLE_ASSAULT,  1.0],
			[MACRO_ENUM_ROLE_SUPPORT,  1.0],
			[MACRO_ENUM_ROLE_ENGINEER, 1.0],
			[MACRO_ENUM_ROLE_MEDIC,    1.0],
			[MACRO_ENUM_ROLE_ANTITANK, 1.0]
		]
	],



	// Weapon recoil balancing
	[
		["CUP_srifle_SVD_top_rail", 1.25],
		["CUP_arifle_AK74M_GL", 1.25],
		["CUP_lmg_Pecheneg_woodland", 0.3],
		["CUP_arifle_AKS74U", 1.25],
		["CUP_arifle_AK74M_camo", 1.25],
		["CUP_smg_bizon", 1.25]
	],



	// Weapon damage balancing
	[
		["CUP_smg_bizon", 1.25],
		["CUP_launch_RPG7V", 1.5]
	],



	// Vehicle health balancing
	[
		["CUP_O_UAZ_Unarmed_RU", 0.75],
		["CUP_O_UAZ_MG_RU", 0.75],
		["CUP_O_UAZ_METIS_RU", 0.75],

		["CUP_O_BRDM2_RUS", 1.5],

		["CUP_O_BTR80_GREEN_RU", 1.5],
		["CUP_O_BTR80A_GREEN_RU", 1.5],
		["CUP_O_BTR90_RU", 1.5],
		["CUP_O_BMP2_RU", 2.5],
		["CUP_O_BMP3_RU", 3.0],

		["CUP_O_T72_RU", 0.5],
		["CUP_O_T90_RU", 0.35],
		["CUP_O_T90M_RU", 1.5]
	]
]
