// ------------------------------------------------------------------------------------------------------------------------------------------------
//	MISSION SETTINGS
// ------------------------------------------------------------------------------------------------------------------------------------------------

	#define MACRO_MISSION_NAME                                      "Gulf of Malden"

	#define MACRO_MISSION_OVERVIEW_IMAGE                            "mission\res\overview.paa"
	#define MACRO_MISSION_LOADING_BANNER                            "mission\res\banner.paa"





// ----------------------------------------------------------------------------------------------------------------------------------
//	AI SETTINGS
// ----------------------------------------------------------------------------------------------------------------------------------
	#define MACRO_AI_MAXCOUNT                                       2 // How many AI units can exist at most at any given time
	#define MACRO_AI_INCLUDEPLAYERS                                 false // Whether or not players are counted towards the AI limit
	#define MACRO_AI_ALLOWVEHICLES                                  true // Whether or not the AI is allowed to use any vehicles at all. Only affects vehicles that would otherwise be allowed for AI use
	#define MACRO_AI_PEACEFULMODE                                   false // Whether or not the AI is allowed to engage other units.
	#define MACRO_AI_MAXUNITSPERGROUP                               6 // How many AI units are allowed to form up in a group

	#define MACRO_AI_SPAWNWEIGHT_EAST                               0 // The weight towards spawning AI on the "east" (OPFOR) side
	#define MACRO_AI_SPAWNWEIGHT_RESISTANCE                         1 // The weight towards spawning AI on the "resistance" (INDFOR) side
	#define MACRO_AI_SPAWNWEIGHT_WEST                               0 // The weight towards spawning AI on the "west" (BLUFOR) side

	// NOTE: Faces and voices parameters can either accept a single value (e.g. "farsi"), or an array of values (e.g. ["polish", "russian"])
	// Accepted values for voices are: "chinese", "english_fr", "english_gr", "english_uk", "english_us", "farsi", "french", "polish", "russian"
	#define MACRO_AI_VOICES_EAST                                    "farsi"
	#define MACRO_AI_VOICES_RESISTANCE                              "english_gr"
	#define MACRO_AI_VOICES_WEST                                    "english_us"

	// Accepted values for faces are: "african", "african_camo", "asian", "asian_camo", "greek", "greek_camo", "livonian", "persian", "persian_camo", "russian", "tanoan", "white", "white_camo"
	#define MACRO_AI_FACES_EAST                                     ["persian", "persian_camo"]
	#define MACRO_AI_FACES_RESISTANCE                               "greek"
	#define MACRO_AI_FACES_WEST                                     ["white", "livonian", "african"]





// ----------------------------------------------------------------------------------------------------------------------------------
//	GAMEPLAY SETTINGS
// ----------------------------------------------------------------------------------------------------------------------------------
	// To modify the following properties, refer to the code snippets in the respective comments behind them
	#define MACRO_MISSION_CAMERAPOSITION                            [5233.83,9852.79,223.421]		// The position of the camera when showing the spawn menu	- acquired via:		getPosWorld get3DENCamera
	#define MACRO_MISSION_CAMERADIRECTION                           [0.996809,-0.0793498,0.0157021]		// The diorection of the camera when showing the spawn menu	- acquired via:		vectorDir get3DENCamera

	// Gamemode
	#define MACRO_GM_STARTINGTICKETS                                200 // How many respawn tickets each side should start with
	#define MACRO_GM_UNIT_RESPAWNDELAY                              15 // How long, in seconds, a unit must wait before being able to respawn
	#define MACRO_GM_UNIT_REVIVEDURATION                            20 // How long, in seconds, a unit can be revived for after being incapacitated
	#define MACRO_GM_UNIT_SPAWNPROTECTIONDURATION                   2 // How long, in seconds, the spawn protection (invincibility) for freshly respawned units should last for
	#define MACRO_GM_SAFESTARTDURATION                              10 // How long the safestart countdown should last, in seconds
	#define MACRO_GM_SECTOR_CAPTUREDURATION                         30 // How long it takes to neutralise or to capture a sector, in seconds

	// Damage balancing
	#define MACRO_GM_UNIT_DAMAGEMUL_HEADSHOT                        3 // Multiplier for the damage dealt by headshots
	#define MACRO_GM_UNIT_DAMAGEMUL_BULLET                          1 // Multiplier for the damage units receive from that bullet hits
	#define MACRO_GM_UNIT_DAMAGEMUL_EXPLOSIVE                       1 // Multiplier for the damage units receive from explosions
	#define MACRO_GM_UNIT_DAMAGEMUL_FALLDAMAGE                      1 // Multiplier for the damage units receive from falling
	#define MACRO_GM_UNIT_DAMAGEMUL_ROADKILL                        1 // Multiplier for the damage units receive when getting hit/run over by vehicles

	// Combat Area
	#define MACRO_CA_DELAYUNTILDEATH                                10 // How long, in seconds, a unit may be outside of the combat area before getting killed





// ----------------------------------------------------------------------------------------------------------------------------------
//	SIDES
// ----------------------------------------------------------------------------------------------------------------------------------
	#define MACRO_SIDE_NAME_EAST                                    "CSAT"
	#define MACRO_SIDE_NAME_RESISTANCE                              "AAF"
	#define MACRO_SIDE_NAME_WEST                                    "NATO"

	#define MACRO_FLAG_TEXTURE_EAST                                 "a3\data_f\Flags\flag_CSAT_co.paa"
	#define MACRO_FLAG_TEXTURE_RESISTANCE                           "a3\data_f\Flags\flag_AAF_co.paa"
	#define MACRO_FLAG_TEXTURE_WEST                                 "a3\data_f\Flags\flag_nato_co.paa"





// ----------------------------------------------------------------------------------------------------------------------------------
//	LOADOUTS
// ----------------------------------------------------------------------------------------------------------------------------------
	// These settings define which magazine classes should be detected for the respective abilities
	#define MACRO_LOADOUT_MAGAZINES_GRENADELAUNCHER                 ["1Rnd_HE_Grenade_shell", "3Rnd_HE_Grenade_shell"]
	#define MACRO_LOADOUT_EXPLOSIVES                                ["WIP_Some_Mine_Class"]
	#define MACRO_LOADOUT_MINES_AP                                  ["WIP_Some_Mine_Class"]
	#define MACRO_LOADOUT_MINES_AT                                  ["WIP_Some_Mine_Class"]
