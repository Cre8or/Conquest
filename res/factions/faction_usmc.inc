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
		"USMC",

		// Faction name (long format, ideally up to 40 characters)
		"United States Marine Corps",

		// Texture path to a flag representing this faction (tip: ArmA 3 has many country flags you can use)
		"a3\data_f\flags\flag_us_co.paa",

		// The face presets that AI units of this faction should use.
		// Possible values: "african", "african_camo", "asian", "asian_camo", "greek", "greek_camo", "livonian", "persian", "persian_camo", "russian", "tanoan", "white", "white_camo"
		// NOTE: This setting either accepts a single value (e.g. "greek"), or an array of values (e.g. ["african", "african_camo"])
		["white", "livonian", "african"],

		// The voice presets that AI units of this faction should use (for things like automatic call-outs).
		// Possible values: "chinese", "english_fr", "english_gr", "english_uk", "english_us", "farsi", "french", "polish", "russian"
		// NOTE: This setting accepts a single value (e.g. "farsi"), or an array of values (e.g. ["english_uk", "english_us"])
		"english_us"
	],



	// Loadouts
	[
		[	// Spec Ops
			MACRO_ENUM_ROLE_SPECOPS,
			[["CUP_arifle_M4A1_camo","","CUP_acc_Flashlight_wdl","CUP_optic_HoloWdl",["CUP_30Rnd_556x45_Stanag_Tracer_Red",30],[],""],[],["CUP_hgun_M9","CUP_muzzle_snds_M9","","",["CUP_15Rnd_9x19_M9",15],[],""],["CUP_U_B_USMC_FROG1_WMARPAT",[]],["CUP_V_B_Eagle_SPC_TL",[["CUP_15Rnd_9x19_M9",2,15],["CUP_30Rnd_556x45_Stanag_Tracer_Red",7,30],["HandGrenade",1,1]]],[],"CUP_H_FR_Cap_Headset_Green","CUP_G_ESS_BLK_Scarf_Grn",["Binocular","","","",[],[],""],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],

		[	// Sniper
			MACRO_ENUM_ROLE_SNIPER,
			//[["CUP_srifle_m110_kac_black","","CUP_acc_Flashlight","optic_KHS_blk",["CUP_20Rnd_TE1_Red_Tracer_762x51_M110",20],[],"CUP_bipod_Harris_1A2_L_BLK"],[],["CUP_hgun_M9","","","",["CUP_15Rnd_9x19_M9",15],[],""],["CUP_U_B_USMC_MCCUU_MARPAT_M81_roll_gloves",[]],["CUP_V_B_Eagle_SPC_DMR",[["HandGrenade",1,1],["CUP_20Rnd_TE1_Red_Tracer_762x51_M110",4,20],["CUP_15Rnd_9x19_M9",2,15]]],[],"CUP_H_FR_BoonieMARPAT","CUP_FR_NeckScarf2",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
			[["CUP_srifle_M24_blk","","","optic_AMS",["CUP_5Rnd_762x51_M24",5],[],"CUP_bipod_Harris_1A2_L_BLK"],[],["CUP_hgun_M9","","","",["CUP_15Rnd_9x19_M9",15],[],""],["CUP_U_B_USMC_MCCUU_MARPAT_M81_roll_gloves",[]],["CUP_V_B_Eagle_SPC_DMR",[["HandGrenade",1,1],["CUP_15Rnd_9x19_M9",2,15],["CUP_5Rnd_762x51_M24",9,5]]],[],"CUP_H_FR_BoonieMARPAT","CUP_G_Scarf_Face_Tan",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
			//[["CUP_srifle_CZ750","","","optic_AMS",["CUP_10Rnd_762x51_CZ750_Tracer",10],[],"bipod_01_F_blk"],[],["CUP_hgun_M9","","","",["CUP_15Rnd_9x19_M9",15],[],""],["CUP_U_B_USMC_MCCUU_MARPAT_M81_roll_gloves",[]],["CUP_V_B_Eagle_SPC_DMR",[["HandGrenade",1,1],["CUP_15Rnd_9x19_M9",2,15],["CUP_10Rnd_762x51_CZ750_Tracer",7,10]]],[],"CUP_H_FR_BoonieMARPAT","CUP_FR_NeckScarf2",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],

		[	// Assault
			MACRO_ENUM_ROLE_ASSAULT,
			[["CUP_arifle_M4A1_GL_carryhandle","","CUP_acc_Flashlight","",["CUP_30Rnd_556x45_Stanag_Tracer_Red",30],["1Rnd_HE_Grenade_shell",1],""],[],["CUP_hgun_M9","","","",["CUP_15Rnd_9x19_M9",15],[],""],["CUP_U_B_USMC_MCCUU_pads_gloves",[]],["CUP_V_B_Eagle_SPC_GL",[["CUP_30Rnd_556x45_Stanag_Tracer_Red",7,30],["CUP_15Rnd_9x19_M9",2,15],["1Rnd_HE_Grenade_shell",4,1]]],["B_Kitbag_cbr",[]],"CUP_H_LWHv2_MARPAT_NVG_gog_cov2","CUP_FR_NeckScarf2",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],

		[	// Support
			MACRO_ENUM_ROLE_SUPPORT,
			[["CUP_lmg_M249_E2","","","",["CUP_200Rnd_TE1_Red_Tracer_556x45_M249",200],[],""],[],["CUP_hgun_M9","","","",["CUP_15Rnd_9x19_M9",15],[],""],["CUP_U_B_USMC_MCCUU_roll_gloves",[]],["CUP_V_B_Eagle_SPC_MG",[["CUP_15Rnd_9x19_M9",2,15],["HandGrenade",1,1],["CUP_200Rnd_TE1_Red_Tracer_556x45_M249",2,200]]],["B_Carryall_green_F",[]],"CUP_H_LWHv2_MARPAT_comms_cov_fr","CUP_TK_NeckScarf",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],

		[	// Engineer
			MACRO_ENUM_ROLE_ENGINEER,
			[["CUP_arifle_Mk16_CQC","","","CUP_optic_Aimpoint_5000",["CUP_30Rnd_556x45_Stanag_Mk16_Tracer_Red",30],[],""],[],["CUP_hgun_M9","","","",["CUP_15Rnd_9x19_M9",15],[],""],["CUP_U_B_USMC_MCCUU_M81_MARPAT_roll_gloves",[]],["CUP_V_B_Eagle_SPC_RTO",[["CUP_15Rnd_9x19_M9",2,15],["HandGrenade",1,1],["CUP_30Rnd_556x45_Stanag_Mk16_Tracer_Red",7,30]]],["CUP_B_USMC_MOLLE_WDL",[]],"CUP_H_CZ_Helmet10","CUP_G_ESS_KHK_Dark",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],

		[	// Medic
			MACRO_ENUM_ROLE_MEDIC,
			[["CUP_arifle_M16A4_Base","","CUP_acc_Flashlight","CUP_optic_CompM2_Black",["CUP_30Rnd_556x45_Stanag_Tracer_Red",30],[],""],[],["CUP_hgun_M9","","","",["CUP_15Rnd_9x19_M9",15],[],""],["CUP_U_B_USMC_FROG3_WMARPAT",[]],["CUP_V_B_Eagle_SPC_Corpsman",[["CUP_15Rnd_9x19_M9",2,15],["CUP_30Rnd_556x45_Stanag_Tracer_Red",7,30],["SmokeShell",2,1]]],["B_Kitbag_rgr",[]],"CUP_H_LWHv2_MARPAT","CUP_G_ESS_KHK_Scarf_Tan",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],

		[	// Anti Tank
			MACRO_ENUM_ROLE_ANTITANK,
			[["CUP_smg_MP5A5","","CUP_acc_Flashlight_MP5","CUP_optic_MicroT1_low",["CUP_30Rnd_Red_Tracer_9x19_MP5",30],[],""],["CUP_launch_Mk153Mod0","","","",["CUP_SMAW_HEDP_M",1],[],""],["CUP_hgun_M9","","","",["CUP_15Rnd_9x19_M9",15],[],""],["CUP_U_B_USMC_FROG4_WMARPAT",[]],["CUP_V_B_Eagle_SPC_AT",[["CUP_15Rnd_9x19_M9",2,15],["CUP_30Rnd_Red_Tracer_9x19_MP5",7,30],["HandGrenade",1,1]]],["B_Kitbag_rgr",[["CUP_SMAW_HEDP_M",2,1]]],"CUP_H_USArmy_MICH_GCOVERED_Headset_M81","",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
			//[["CUP_smg_MP7","","acc_flashlight","CUP_optic_MicroT1_low",["CUP_40Rnd_46x30_MP7_Red_Tracer",40],[],""],["CUP_launch_Mk153Mod0","","","",["CUP_SMAW_HEDP_M",1],[],""],["CUP_hgun_M9","","","",["CUP_15Rnd_9x19_M9",15],[],""],["CUP_U_B_USMC_FROG4_WMARPAT",[]],["CUP_V_B_Eagle_SPC_AT",[["CUP_15Rnd_9x19_M9",2,15],["HandGrenade",1,1],["CUP_40Rnd_46x30_MP7_Red_Tracer",7,40]]],["B_Kitbag_rgr",[["CUP_SMAW_HEDP_M",2,1]]],"CUP_H_USArmy_MICH_GCOVERED_Headset_M81","",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
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
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_CAR_UNARMED_HEAVY,
			[
				["CUP_B_nM1025_Unarmed_USMC_WDL","Woodland",[["hide_front_right_antenna",1],["hide_rear_right_antenna",0],["hide_radio_small",1]]]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_CAR_ARMED_LIGHT,
			[
				["CUP_B_nM1025_M240_USMC_WDL","Woodland",[["hide_front_right_antenna",1],["hide_rear_right_antenna",0],["hide_radio_small",1]]],
				["CUP_B_nM1025_SOV_M2_USMC_WDL","Woodland",[["hide_door_rear_left",1],["hide_door_rear_right",1],["hide_radio_small",1],["hide_backpacks",1]]]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_CAR_ARMED_HEAVY,
			[
				["CUP_B_nM1151_ogpk_m2_USA_WDL","Woodland",[["hide_overhead_protection",1],["hide_mudflaps",0],["hide_rear_left_antenna",1],["hide_spare_tire",1],["hide_spare_tire_mount",1],["hide_heavy_bumper",0]]],
				["CUP_B_nM1036_TOW_USMC_WDL","Woodland",[["hide_front_right_antenna",1],["hide_rear_right_antenna",0],["hide_radio_small",1]]],
				["CUP_B_nM1025_Mk19_USMC_WDL","Woodland",[["hide_front_right_antenna",1],["hide_rear_right_antenna",0],["hide_radio_small",1]]]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_TRUCK_TRANSPORT,
			[
				["CUP_B_MTVR_USMC"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_APC_LIGHT,
			[
				["CUP_B_LAV25M240_USMC"],
				["CUP_B_M1130_CV_M2_Woodland"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_APC_HEAVY,
			[
				["CUP_B_M7Bradley_USA_W"],
				["CUP_B_M7Bradley_USA_W"],
				["CUP_B_M1128_MGS_Woodland"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_AMPHIBIOUS_LIGHT,
			[
				["CUP_B_LAV25_USMC"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_AMPHIBIOUS_HEAVY,
			[
				["CUP_B_AAV_USMC","Woodland",[["Hide_Deployment",1]]]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_AA_LIGHT,
			[
				["CUP_B_nM1097_AVENGER_USMC_WDL","Woodland",[["hide_rear_left_antenna",0],["hide_rear_right_antenna",0],["hide_radio_small",1]]]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_AA_HEAVY,
			[
				["CUP_B_M6LineBacker_USA_W"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_TANK_LIGHT,
			[
				["CUP_B_M1A1SA_Woodland_US_Army","",[["hide_cip_panel_bustle",1],["hide_cip_panel_rear",1],["hide_front_ti_panels",1],["hide_Deployment_1_1",1],["hide_Deployment_1_2",1],["hide_Deployment_1_3",1],["hide_Deployment_2_1",1],["hide_Deployment_2_2",1],["hide_Deployment_2_3",1]]]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_TANK_HEAVY,
			[
				["CUP_B_M1A2C_TUSK_II_Woodland_US_Army","",[["hide_cip_panel_bustle",1],["hide_cip_panel_rear",1],["hide_front_ti_panels",1],["hide_Deployment_1_1",1],["hide_Deployment_1_2",1],["hide_Deployment_1_3",1],["hide_Deployment_2_1",1],["hide_Deployment_2_2",1],["hide_Deployment_2_3",1]]]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_HELI_TRANSPORT_LIGHT,
			[
				["CUP_B_UH1Y_UNA_USMC"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_HELI_TRANSPORT_HEAVY,
			[
				["CUP_B_UH60M_US","Grey",[["Navyclan_hide",0],["Filters_Hide",1]]]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_HELI_ATTACK_LIGHT,
			[
				["CUP_B_AH6J_USA","",[["hideFLIR",1],["hideUSARMY",1]]]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_HELI_ATTACK_HEAVY,
			[
				["CUP_B_AH1Z_Dynamic_USMC"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_PLANE_AA,
			[
				["CUP_B_F35B_USMC"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_PLANE_CAS,
			[
				["CUP_B_A10_DYN_USA","GreyShark"],
				["CUP_B_AV8B_DYN_USMC"]
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
		0.25 * MACRO_AI_SKILL_BASEACCURACY, // Overall accuracy multiplier

		// Per-role accuracy multipliers (cumulative with the overall multiplier)
		[
			[MACRO_ENUM_ROLE_SPECOPS,  0.8],
			[MACRO_ENUM_ROLE_SNIPER,   3.0],
			[MACRO_ENUM_ROLE_ASSAULT,  1.0],
			[MACRO_ENUM_ROLE_SUPPORT,  0.8],
			[MACRO_ENUM_ROLE_ENGINEER, 1.0],
			[MACRO_ENUM_ROLE_MEDIC,    0.8],
			[MACRO_ENUM_ROLE_ANTITANK, 0.8]
		]
	],



	// Weapon recoil balancing
	[
		["CUP_arifle_M4A1_camo", 1.75],
		["CUP_srifle_m110_kac_black", 1.5],
		["CUP_arifle_M4A1_GL_carryhandle", 1.5],
		["CUP_lmg_M249_E2", 1.5],
		["CUP_arifle_Mk16_CQC", 2.0],
		["CUP_arifle_M16A4_Base", 1.75],
		["CUP_smg_MP5A5", 1.25]
	],



	// Weapon damage balancing
	[
		["CUP_srifle_M24_blk", 1.5],
		["CUP_smg_MP5A5", 1.25],
		["CUP_launch_Mk153Mod0", 1.5]
	]
]
