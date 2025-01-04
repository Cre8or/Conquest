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
		"NATO",

		// Faction name (long format, ideally up to 40 characters)
		"North Atlantic Treaty Organisation",

		// Texture path to a flag representing this faction (tip: ArmA 3 has many country flags you can use)
		"a3\data_f\flags\flag_nato_co.paa",

		// The face presets that AI units of this faction should use.
		// Possible values: "african", "african_camo", "asian", "asian_camo", "greek", "greek_camo", "livonian", "persian", "persian_camo", "russian", "tanoan", "white", "white_camo"
		// NOTE: This setting either accepts a single value (e.g. "greek"), or an array of values (e.g. ["african", "african_camo"])
		["white", "white_camo", "livonian", "african"],

		// The voice presets that AI units of this faction should use (for things like automatic call-outs).
		// Possible values: "chinese", "english_fr", "english_gr", "english_uk", "english_us", "farsi", "french", "polish", "russian"
		// NOTE: This setting accepts a single value (e.g. "farsi"), or an array of values (e.g. ["english_uk", "english_us"])
		"english_us"
	],



	// Loadouts
	[
		[	// Spec Ops
			MACRO_ENUM_ROLE_SPECOPS,
			[["arifle_MX_Black_F","","acc_flashlight","optic_Aco",["30Rnd_65x39_caseless_black_mag_Tracer",30],[],""],[],["hgun_Pistol_heavy_01_F","muzzle_snds_acp","acc_flashlight_pistol","",["11Rnd_45ACP_Mag",15],[],""],["U_B_CombatUniform_mcam",[]],["V_PlateCarrier2_rgr",[["30Rnd_65x39_caseless_black_mag_Tracer",7,30],["HandGrenade",1,1],["11Rnd_45ACP_Mag",2,15]]],[],"H_Cap_headphones","G_Combat",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],

		[	// Sniper
			MACRO_ENUM_ROLE_SNIPER,
			[["srifle_DMR_02_camo_F","","acc_flashlight","optic_AMS",["10Rnd_338_Mag",10],[],"bipod_01_F_blk"],[],["hgun_P07_F","","","",["16Rnd_9x21_red_Mag",17],[],""],["U_B_FullGhillie_sard",[]],["V_Chestrig_rgr",[["HandGrenade",1,1],["16Rnd_9x21_red_Mag",2,17],["10Rnd_338_Mag",5,10]]],[],"","G_Bandanna_tan",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],

		[	// Assault
			MACRO_ENUM_ROLE_ASSAULT,
			[["arifle_MX_GL_Black_F","","acc_flashlight","optic_Aco",["30Rnd_65x39_caseless_black_mag_Tracer",30],["1Rnd_HE_Grenade_shell",1],""],[],["hgun_P07_F","","","",["16Rnd_9x21_red_Mag",17],[],""],["U_B_CombatUniform_mcam",[]],["V_PlateCarrier1_rgr",[["30Rnd_65x39_caseless_black_mag_Tracer",7,30],["16Rnd_9x21_red_Mag",2,17],["1Rnd_HE_Grenade_shell",4,1]]],["B_TacticalPack_mcamo",[]],"H_HelmetB_sand","",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],

		[	// Support
			MACRO_ENUM_ROLE_SUPPORT,
			[["LMG_03_F","","acc_flashlight","",["200Rnd_556x45_Box_Tracer_Red_F",200],[],""],[],["hgun_P07_F","","","",["16Rnd_9x21_red_Mag",17],[],""],["U_B_CombatUniform_mcam_vest",[]],["V_PlateCarrier1_rgr",[["200Rnd_556x45_Box_Tracer_Red_F",2,200],["HandGrenade",1,1],["16Rnd_9x21_red_Mag",2,17]]],["B_Kitbag_mcamo",[]],"H_HelmetSpecB","G_Combat",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],

		[	// Engineer
			MACRO_ENUM_ROLE_ENGINEER,
			[["SMG_02_F","","acc_flashlight","optic_Aco",["30Rnd_9x21_Mag_SMG_02_Tracer_Red",30],[],""],[],["hgun_P07_F","","","",["16Rnd_9x21_red_Mag",17],[],""],["U_B_CombatUniform_mcam",[["MineDetector",1]]],["V_PlateCarrier2_rgr",[["16Rnd_9x21_red_Mag",2,17],["HandGrenade",1,1],["30Rnd_9x21_Mag_SMG_02_Tracer_Red",9,30]]],["B_AssaultPack_khk",[]],"H_HelmetB_grass","G_Balaclava_TI_blk_F",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],

		[	// Medic
			MACRO_ENUM_ROLE_MEDIC,
			[["arifle_SPAR_01_blk_F","","acc_flashlight","optic_Holosight_blk_F",["30Rnd_556x45_Stanag_Tracer_Red",30],[],""],[],["hgun_P07_F","","","",["16Rnd_9x21_red_Mag",17],[],""],["U_B_CombatUniform_mcam",[]],["V_PlateCarrier1_rgr",[["16Rnd_9x21_red_Mag",2,17],["30Rnd_556x45_Stanag_Tracer_Red",7,30],["SmokeShell",2,1]]],["B_AssaultPack_mcamo",[]],"H_HelmetB_camo","G_Combat",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],

		[	// Anti Tank
			MACRO_ENUM_ROLE_ANTITANK,
			[["arifle_MX_Black_F","","acc_flashlight","optic_Aco",["30Rnd_65x39_caseless_black_mag_Tracer",30],[],""],["launch_MRAWS_sand_rail_F","","","",["MRAWS_HEAT_F",1],[],""],["hgun_P07_F","","","",["16Rnd_9x21_red_Mag",17],[],""],["U_B_CombatUniform_mcam_vest",[]],["V_PlateCarrier_Kerry",[["16Rnd_9x21_red_Mag",2,17],["30Rnd_65x39_caseless_black_mag_Tracer",7,30]]],["B_Kitbag_rgr",[["MRAWS_HEAT_F",2,1]]],"H_HelmetB_snakeskin","",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
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
				["B_Quadbike_01_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_CAR_UNARMED_LIGHT,
			[
				["B_LSV_01_unarmed_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_CAR_UNARMED_HEAVY,
			[
				["B_MRAP_01_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_CAR_ARMED_LIGHT,
			[
				["B_LSV_01_armed_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_CAR_ARMED_HEAVY,
			[
				["B_MRAP_01_gmg_F"],
				["B_LSV_01_AT_F"],
				["B_MRAP_01_hmg_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_TRUCK_TRANSPORT,
			[
				["B_Truck_01_covered_F"],
				["B_Truck_01_transport_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_APC_LIGHT,
			[
				["B_APC_Wheeled_01_cannon_F"],
				["B_APC_Tracked_01_rcws_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_APC_HEAVY,
			[
				["B_APC_Wheeled_01_cannon_F","",[["showSLATHull",1],["showSLATTurret",1]]],
				["B_AFV_Wheeled_01_up_cannon_F","",[["showSLATHull",1]]],
				["B_APC_Wheeled_01_cannon_F","",[["showCamonetHull",1],["showCamonetTurret",1],["showSLATHull",1],["showSLATTurret",1]]]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_AMPHIBIOUS_LIGHT,
			[
				["B_APC_Wheeled_01_cannon_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_AMPHIBIOUS_HEAVY,
			[
				["B_APC_Wheeled_01_cannon_F","",[["showSLATHull",1],["showSLATTurret",1]]]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_AA_LIGHT,
			[
				["B_APC_Tracked_01_AA_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_AA_HEAVY,
			[
				["B_APC_Tracked_01_AA_F","",[["showCamonetTurret",1],["showCamonetHull",1]]]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_TANK_LIGHT,
			[
				["B_MBT_01_cannon_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_TANK_HEAVY,
			[
				["B_MBT_01_TUSK_F","",[["showCamonetTurret",1],["showCamonetHull",1]]]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_HELI_TRANSPORT_LIGHT,
			[

				["B_Heli_Light_01_F"],
				["B_Heli_Transport_01_F","Green"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_HELI_TRANSPORT_HEAVY,
			[
				["B_Heli_Transport_01_F","Green"],
				["B_Heli_Transport_03_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_HELI_ATTACK_LIGHT,
			[
				["B_Heli_Light_01_dynamicLoadout_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_HELI_ATTACK_HEAVY,
			[
				["B_Heli_Attack_01_dynamicLoadout_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_PLANE_AA,
			[
				["B_Plane_Fighter_01_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_PLANE_CAS,
			[
				["B_Plane_CAS_01_dynamicLoadout_F"]
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
				["B_Boat_Armed_01_minigun_F"]
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



	// Recoil balancing
	[
		["LMG_03_F", 2.0],
		["arifle_SPAR_01_blk_F", 1.25]
	]
]
