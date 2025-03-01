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
		"AAF",

		// Faction name (long format, ideally up to 40 characters)
		"Altis Armed Forces",

		// Texture path to a flag representing this faction (tip: ArmA 3 has many country flags you can use)
		"a3\data_f\flags\flag_aaf_co.paa",

		// The face presets that AI units of this faction should use.
		// Possible values: "african", "african_camo", "asian", "asian_camo", "greek", "greek_camo", "livonian", "persian", "persian_camo", "russian", "tanoan", "white", "white_camo"
		// NOTE: This setting either accepts a single value (e.g. "greek"), or an array of values (e.g. ["african", "african_camo"])
		["greek", "greek_camo"],

		// The voice presets that AI units of this faction should use (for things like automatic call-outs).
		// Possible values: "chinese", "english_fr", "english_gr", "english_uk", "english_us", "farsi", "french", "polish", "russian"
		// NOTE: This setting accepts a single value (e.g. "farsi"), or an array of values (e.g. ["english_uk", "english_us"])
		"english_gr"
	],



	// Loadouts
	[
		[	// Spec Ops
			MACRO_ENUM_ROLE_SPECOPS,
			[["arifle_Mk20C_F","","acc_flashlight","optic_ACO_grn_smg",["30Rnd_556x45_Stanag_Tracer_Yellow",30],[],""],[],["hgun_Pistol_heavy_01_green_F","muzzle_snds_acp","acc_flashlight_pistol","",["11Rnd_45ACP_Mag",15],[],""],["U_I_CombatUniform",[]],["V_PlateCarrierIA2_dgtl",[["30Rnd_556x45_Stanag_Tracer_Yellow",7,30],["HandGrenade",1,1],["11Rnd_45ACP_Mag",2,15]]],["B_AssaultPack_dgtl",[]],"H_MilCap_dgtl","G_Bandanna_oli",["Binocular","","","",[],[],""],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],

		[	// Sniper
			MACRO_ENUM_ROLE_SNIPER,
			[["srifle_DMR_06_olive_F","","","optic_KHS_blk",["20Rnd_762x51_Mag",20],[],"bipod_02_F_blk"],[],["hgun_P07_khk_F","","","",["16Rnd_9x21_yellow_Mag",17],[],""],["U_I_FullGhillie_lsh",[]],["V_Chestrig_oli",[["HandGrenade",1,1],["16Rnd_9x21_yellow_Mag",2,17],["20Rnd_762x51_Mag",5,20]]],[],"","G_Bandanna_oli",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],

		[	// Assault
			MACRO_ENUM_ROLE_ASSAULT,
			[["arifle_Mk20_GL_plain_F","","acc_flashlight","optic_Holosight",["30Rnd_556x45_Stanag_Tracer_Yellow",30],["1Rnd_HE_Grenade_shell",1],""],[],["hgun_P07_blk_F","","","",["16Rnd_9x21_yellow_Mag",17],[],""],["U_I_CombatUniform",[]],["V_PlateCarrierIA2_dgtl",[["30Rnd_556x45_Stanag_Tracer_Yellow",7,30],["16Rnd_9x21_yellow_Mag",2,17],["1Rnd_HE_Grenade_shell",4,1]]],["B_Kitbag_sgg",[]],"H_HelmetIA","G_Combat_Goggles_tna_F",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],

		[	// Support
			MACRO_ENUM_ROLE_SUPPORT,
			[["LMG_Mk200_black_F","","acc_flashlight","optic_ACO_grn_smg",["200Rnd_65x39_cased_Box_Tracer",200],[],""],[],["hgun_P07_blk_F","","","",["16Rnd_9x21_yellow_Mag",17],[],""],["U_I_CombatUniform_shortsleeve",[]],["V_PlateCarrierIA1_dgtl",[["200Rnd_65x39_cased_Box_Tracer",2,200],["HandGrenade",1,1],["16Rnd_9x21_yellow_Mag",2,17]]],["B_Carryall_oli",[]],"H_HelmetIA","G_Combat_Goggles_tna_F",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],

		[	// Engineer
			MACRO_ENUM_ROLE_ENGINEER,
			[["SMG_03C_TR_khaki","","","optic_Yorris",["50Rnd_570x28_SMG_03",50],[],""],[],["hgun_P07_blk_F","","","",["16Rnd_9x21_yellow_Mag",17],[],""],["U_I_CombatUniform",[["MineDetector",1]]],["V_PlateCarrierIA2_dgtl",[["HandGrenade",1,1],["16Rnd_9x21_yellow_Mag",2,17],["50Rnd_570x28_SMG_03",7,50]]],["B_AssaultPack_sgg",[]],"H_HelmetCrew_I","G_Combat_Goggles_tna_F",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],

		[	// Medic
			MACRO_ENUM_ROLE_MEDIC,
			[["arifle_Mk20_F","","acc_flashlight","optic_Holosight_lush_F",["30Rnd_556x45_Stanag_Tracer_Yellow",30],[],""],[],["hgun_P07_blk_F","","","",["16Rnd_9x21_yellow_Mag",17],[],""],["U_I_CombatUniform",[]],["V_PlateCarrierIA2_dgtl",[["16Rnd_9x21_yellow_Mag",2,17],["SmokeShell",2,1],["30Rnd_556x45_Stanag_Tracer_Yellow",7,30]]],["B_AssaultPack_dgtl",[]],"H_HelmetIA","G_Combat_Goggles_tna_F",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
		],

		[	// Anti Tank
			MACRO_ENUM_ROLE_ANTITANK,
			[["arifle_Mk20_plain_F","","acc_flashlight","optic_ACO_grn_smg",["30Rnd_556x45_Stanag_Tracer_Yellow",30],[],""],["launch_MRAWS_olive_rail_F","","","",["MRAWS_HEAT_F",1],[],""],["hgun_P07_blk_F","","","",["16Rnd_9x21_yellow_Mag",17],[],""],["U_I_CombatUniform_shortsleeve",[]],["V_PlateCarrierIA1_dgtl",[["16Rnd_9x21_yellow_Mag",2,17],["30Rnd_556x45_Stanag_Tracer_Yellow",7,30],["HandGrenade",1,1]]],["B_Kitbag_sgg",[["MRAWS_HEAT_F",2,1]]],"H_HelmetIA","G_Bandanna_oli",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]]
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
				["I_Quadbike_01_F"]
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
				["I_MRAP_03_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_CAR_ARMED_LIGHT,
			[
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_CAR_ARMED_HEAVY,
			[
				["I_MRAP_03_hmg_F"],
				["I_MRAP_03_gmg_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_TRUCK_TRANSPORT,
			[
				["I_Truck_02_covered_F"],
				["I_Truck_02_transport_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_APC_LIGHT,
			[
				//["B_APC_Tracked_01_rcws_F",[[0,"a3\armor_f_beta\apc_tracked_01\data\apc_tracked_01_body_indp_co.paa"],[2,"a3\data_f\vehicles\turret_indp_co.paa"],[3,"a3\armor_f\data\camonet_aaf_digi_green_co.paa"]],[["showCamonetHull",1]]],
				["I_APC_Wheeled_03_cannon_F","",[["showCamonetHull",1]]],
				["I_APC_Wheeled_03_cannon_F"],
				["I_LT_01_cannon_F","",[["showCamonetHull",1]]]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_APC_HEAVY,
			[
				["I_APC_tracked_03_cannon_F","",[["showCamonetHull",1],["showCamonetTurret",1],["showSLATHull",1],["showSLATTurret",1]]],
				["I_APC_Wheeled_03_cannon_F","",[["showCamonetHull",1],["showSLATHull",1]]],
				["I_LT_01_AT_F","",[["showCamonetHull",1],["showSLATHull",1]]],
				["I_APC_tracked_03_cannon_F","",[["showSLATHull",1],["showSLATTurret",1]]]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_AMPHIBIOUS_LIGHT,
			[
				["I_APC_Wheeled_03_cannon_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_AMPHIBIOUS_HEAVY,
			[
				["I_APC_Wheeled_03_cannon_F","",[["showSLATHull",1]]]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_AA_LIGHT,
			[
				["I_LT_01_AA_F","",[["showCamonetHull",1]]],
				["I_LT_01_AA_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_AA_HEAVY,
			[
				["B_APC_Tracked_01_AA_F",[[0,"a3\armor_f_beta\apc_tracked_01\data\apc_tracked_01_body_indp_co.paa"],[1,"a3\armor_f_exp\mbt_01\data\MBT_01_body_olive_CO.paa"],[2,"a3\armor_f_exp\apc_tracked_01\data\apc_tracked_01_aa_tower_olive_co.paa"],[3,"a3\armor_f\data\camonet_aaf_digi_green_co.paa"]],[["showCamonetTurret",1],["showCamonetHull",1]]]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_TANK_LIGHT,
			[
				["I_MBT_03_cannon_F",""]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_TANK_HEAVY,
			[
				["I_MBT_03_cannon_F","",[["showCamonetHull",1],["showCamonetTurret",1]]]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_HELI_TRANSPORT_LIGHT,
			[
				["B_Heli_Light_01_F",[[0,"a3\air_f\heli_light_01\data\heli_light_01_ext_indp_co.paa"]]],
				["I_Heli_light_03_unarmed_F","Indep"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_HELI_TRANSPORT_HEAVY,
			[
				["O_Heli_Light_02_unarmed_F",[[0,"a3\air_f\heli_light_02\data\heli_light_02_ext_indp_co.paa"]]],
				["I_Heli_light_03_unarmed_F","Indep"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_HELI_ATTACK_LIGHT,
			[
				["B_Heli_Light_01_dynamicLoadout_F",[[0,"a3\air_f\heli_light_01\data\heli_light_01_ext_indp_co.paa"]]]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_HELI_ATTACK_HEAVY,
			[
				["I_Heli_light_03_dynamicLoadout_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_PLANE_AA,
			[
				["I_Plane_Fighter_04_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_PLANE_CAS,
			[
				["I_Plane_Fighter_03_dynamicLoadout_F"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_BOAT_LIGHT,
			[
				["B_Boat_Transport_01_F","Digital"]
			]
		],

		[
			MACRO_ENUM_VEHICLETYPE_BOAT_HEAVY,
			[
				["B_Boat_Armed_01_minigun_F","Indep"]
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
		["SMG_03C_TR_khaki", 1.25]
	],



	// Weapon damage balancing
	[
		["launch_MRAWS_olive_rail_F", 0.75]
	],



	// Vehicle health balancing
	[
		["I_MBT_03_cannon_F", 0.75]
	]
]
