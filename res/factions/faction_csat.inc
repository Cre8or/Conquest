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
		"CSAT",

		// Faction name (long format, ideally up to 40 characters)
		"Canton Protocol Strategic Alliance Treaty",

		// Texture path to a flag representing this faction (tip: ArmA 3 has many country flags you can use)
		"a3\data_f\Flags\flag_CSAT_co.paa",

		// The face presets that AI units of this faction should use.
		// Possible values: "african", "african_camo", "asian", "asian_camo", "greek", "greek_camo", "livonian", "persian", "persian_camo", "russian", "tanoan", "white", "white_camo"
		// NOTE: This setting either accepts a single value (e.g. "greek"), or an array of values (e.g. ["african", "african_camo"])
		["persian", "persian_camo"],

		// The voice presets that AI units of this faction should use (for things like automatic call-outs).
		// Possible values: "chinese", "english_fr", "english_gr", "english_uk", "english_us", "farsi", "french", "polish", "russian"
		// NOTE: This setting accepts a single value (e.g. "farsi"), or an array of values (e.g. ["english_uk", "english_us"])
		"farsi"
	],



	// Loadouts
	[
		[	// Spec Ops
			MACRO_ENUM_ROLE_SPECOPS,
			[["arifle_ARX_blk_F","","acc_flashlight","optic_Holosight_smg_blk_F",["30Rnd_65x39_caseless_green_mag_Tracer",30],[],""],[],["hgun_Pistol_heavy_01_F","muzzle_snds_acp","acc_flashlight_pistol","",["11Rnd_45ACP_Mag",15],[],""],["U_O_CombatUniform_ocamo",[]],["V_TacVest_brn",[["11Rnd_45ACP_Mag",2,15],["30Rnd_65x39_caseless_green_mag_Tracer",7,30],["HandGrenade",1,1]]],["B_ViperHarness_hex_F",[]],"H_ShemagOpen_tan","",["Binocular","","","",[],[],""],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],

		[	// Sniper
			MACRO_ENUM_ROLE_SNIPER,
			[["srifle_DMR_05_tan_f","","acc_flashlight","optic_DMS",["10Rnd_93x64_DMR_05_Mag",10],[],"bipod_02_F_hex"],[],["hgun_Rook40_F","","","",["16Rnd_9x21_green_Mag",17],[],""],["U_O_FullGhillie_sard",[]],["V_Chestrig_rgr",[["HandGrenade",1,1],["10Rnd_93x64_DMR_05_Mag",5,10],["16Rnd_9x21_green_Mag",2,17]]],[],"","G_Balaclava_oli",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],

		[	// Assault
			MACRO_ENUM_ROLE_ASSAULT,
			[["arifle_Katiba_GL_F","","acc_flashlight","optic_ACO_grn",["30Rnd_65x39_caseless_green_mag_Tracer",30],["1Rnd_HE_Grenade_shell",1],""],[],["hgun_Rook40_F","","","",["16Rnd_9x21_green_Mag",17],[],""],["U_O_CombatUniform_ocamo",[]],["V_TacVest_brn",[["1Rnd_HE_Grenade_shell",4,1],["16Rnd_9x21_green_Mag",2,17],["30Rnd_65x39_caseless_green_mag_Tracer",7,30]]],["B_TacticalPack_ocamo",[]],"H_HelmetO_ocamo","",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],

		[	// Support
			MACRO_ENUM_ROLE_SUPPORT,
			[["LMG_Zafir_F","","acc_flashlight","",["150Rnd_762x54_Box_Tracer",150],[],""],[],["hgun_Rook40_F","","","",["16Rnd_9x21_green_Mag",17],[],""],["U_O_CombatUniform_ocamo",[]],["V_TacVest_khk",[["16Rnd_9x21_green_Mag",2,17],["150Rnd_762x54_Box_Tracer",1,150],["HandGrenade",1,1]]],["B_FieldPack_cbr",[["150Rnd_762x54_Box_Tracer",2,150]]],"H_HelmetO_ocamo","G_Bandanna_beast",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],

		[	// Engineer
			MACRO_ENUM_ROLE_ENGINEER,
			[["SMG_01_F","","acc_flashlight_smg_01","optic_ACO_grn_smg",["30Rnd_45ACP_Mag_SMG_01_Tracer_Green",25],[],""],[],["hgun_Rook40_F","","","",["16Rnd_9x21_green_Mag",17],[],""],["U_O_CombatUniform_ocamo",[["MineDetector",1]]],["V_TacVest_brn",[["16Rnd_9x21_green_Mag",2,17],["HandGrenade",1,1],["30Rnd_45ACP_Mag_SMG_01_Tracer_Green",9,25]]],["B_AssaultPack_ocamo",[]],"H_HelmetCrew_O","G_Bandanna_tan",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],

		[	// Medic
			MACRO_ENUM_ROLE_MEDIC,
			[["arifle_CTAR_hex_F","","acc_flashlight","optic_ACO_grn",["30Rnd_580x42_Mag_Tracer_F",30],[],""],[],["hgun_Rook40_F","","","",["16Rnd_9x21_green_Mag",17],[],""],["U_O_CombatUniform_ocamo",[]],["V_TacVest_khk",[["16Rnd_9x21_green_Mag",2,17],["30Rnd_580x42_Mag_Tracer_F",7,30],["SmokeShell",2,1]]],["B_AssaultPack_cbr",[]],"H_HelmetSpecO_ocamo","",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],

		[	// Anti Tank
			MACRO_ENUM_ROLE_ANTITANK,
			[["arifle_Katiba_C_F","","acc_flashlight","optic_Holosight_smg_blk_F",["30Rnd_65x39_caseless_green_mag_Tracer",30],[],""],["launch_RPG32_F","","","",["RPG32_F",1],[],""],["hgun_Rook40_F","","","",["16Rnd_9x21_green_Mag",17],[],""],["U_O_CombatUniform_ocamo",[]],["V_TacVest_khk",[["16Rnd_9x21_green_Mag",2,17],["30Rnd_65x39_caseless_green_mag_Tracer",7,30],["HandGrenade",1,1]]],["B_Kitbag_cbr",[["RPG32_F",2,1]]],"H_HelmetO_ocamo","G_Balaclava_blk",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
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
				["O_Quadbike_01_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_CAR_UNARMED_LIGHT,
			[
				["O_LSV_02_unarmed_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_CAR_UNARMED_HEAVY,
			[
				["O_MRAP_02_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_CAR_ARMED_LIGHT,
			[
				["O_LSV_02_armed_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_CAR_ARMED_HEAVY,
			[
				["O_MRAP_02_hmg_F"],
				["O_LSV_02_AT_F"],
				["O_MRAP_02_gmg_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_TRUCK_TRANSPORT,
			[
				["O_Truck_02_covered_F"],
				["O_Truck_02_transport_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_APC_LIGHT,
			[
				["O_APC_Tracked_02_cannon_F","",[["showCamonetHull",1]]],
				["O_APC_Wheeled_02_rcws_v2_F","",[["showCamonetHull",1]]]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_APC_HEAVY,
			[
				["O_APC_Tracked_02_cannon_F","",[["showSLATHull",1]]],
				["O_APC_Tracked_02_cannon_F","",[["showCamonetHull",1],["showSLATHull",1]]],
				["O_APC_Wheeled_02_rcws_v2_F","",[["showSLATHull",1]]]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_AMPHIBIOUS_LIGHT,
			[
				["O_APC_Wheeled_02_rcws_v2_F"],
				["O_APC_Tracked_02_cannon_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_AMPHIBIOUS_HEAVY,
			[
				["O_APC_Tracked_02_cannon_F","",[["showSLATHull",1]]]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_AA_LIGHT,
			[
				["O_APC_Tracked_02_AA_F","",[["showCamonetHull",1],["showCamonetTurret",1]]],
				["O_APC_Tracked_02_AA_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_AA_HEAVY,
			[
				["O_APC_Tracked_02_AA_F","",[["showSLATHull",1]]],
				["O_APC_Tracked_02_AA_F","",[["showCamonetHull",1],["showCamonetTurret",1],["showSLATHull",1]]]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_TANK_LIGHT,
			[
				["O_MBT_02_cannon_F","",[["showLog",1]]]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_TANK_HEAVY,
			[
				["O_MBT_02_cannon_F","",[["showCamonetHull",1],["showCamonetTurret",1],["showLog",1]]],
				["O_MBT_02_cannon_F","",[["showCamonetHull",1],["showCamonetTurret",1],["showLog",1]]],
				["O_MBT_02_railgun_F","",[["showCamonetHull",1],["showCamonetTurret",1],["showLog",1]]]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_HELI_TRANSPORT_LIGHT,
			[
				["O_Heli_Light_02_unarmed_F","Opfor"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_HELI_TRANSPORT_HEAVY,
			[
				["O_Heli_Transport_04_covered_F"],
				["O_Heli_Light_02_unarmed_F","Opfor"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_HELI_ATTACK_LIGHT,
			[
				["O_Heli_Light_02_dynamicLoadout_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_HELI_ATTACK_HEAVY,
			[
				["O_Heli_Attack_02_dynamicLoadout_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_PLANE_AA,
			[
				["O_Plane_Fighter_02_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_PLANE_CAS,
			[
				["O_Plane_CAS_02_dynamicLoadout_F"],
				["I_Plane_Fighter_03_dynamicLoadout_F",[[0,"a3\air_f_gamma\plane_fighter_03\data\plane_fighter_03_body_1_brownhex_co.paa"],[1,"a3\air_f_gamma\plane_fighter_03\data\plane_fighter_03_body_2_brownhex_co.paa"]]]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_BOAT_LIGHT,
			[
				["O_Boat_Transport_01_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_BOAT_HEAVY,
			[
				["B_Boat_Armed_01_minigun_F","Opfor"]
			]
		]
	],



	// AI Balancing
	[
		MACRO_AI_SKILL_BASEACCURACY, // Overall accuracy multiplier

		// Per-role accuracy multipliers (cumulative with the overall multiplier)
		[
			[MACRO_ENUM_ROLE_SPECOPS,  1.0],
			[MACRO_ENUM_ROLE_SNIPER,   2.0],
			[MACRO_ENUM_ROLE_ASSAULT,  1.0],
			[MACRO_ENUM_ROLE_SUPPORT,  1.0],
			[MACRO_ENUM_ROLE_ENGINEER, 1.0],
			[MACRO_ENUM_ROLE_MEDIC,    1.0],
			[MACRO_ENUM_ROLE_ANTITANK, 1.0]
		]
	],



	// Weapon recoil balancing
	[
		["arifle_ARX_blk_F", 1.75],
		["LMG_Zafir_F", 1.25],
		["SMG_01_F", 0.5],
		["arifle_CTAR_hex_F", 1.75]
	],



	// Weapon damage balancing
	[
		["launch_RPG32_F", 0.75]
	],



	// Vehicle health balancing
	[
		["O_MRAP_02_F", 0.5],
		["O_MRAP_02_hmg_F", 0.5],
		["O_MRAP_02_gmg_F", 0.5],

		["O_APC_Wheeled_02_rcws_v2_F", 0.85],
		["O_APC_Tracked_02_cannon_F", 0.5],

		["O_MBT_02_cannon_F", 0.65],
		["O_MBT_02_railgun_F", 0.75],

		["O_Heli_Light_02_unarmed_F", 0.75],
		["O_Heli_Transport_04_covered_F", 0.85],

		["O_Heli_Light_02_dynamicLoadout_F", 0.75],
		["O_Heli_Attack_02_dynamicLoadout_F", 0.75],

		["O_Plane_Fighter_02_F", 0.65],
		["O_Plane_CAS_02_dynamicLoadout_F", 0.5]
	]
]
