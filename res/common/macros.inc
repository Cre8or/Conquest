// ------------------------------------------------------------------------------------------------------------------------------------------------
//	MACRO FUNCTIONS
// ------------------------------------------------------------------------------------------------------------------------------------------------

	#define MACRO_PROJECT_PREFIX                                    cre8ive_conquest
	#define SQUARE(DATA)                                            [##DATA##]
	#define CURLY(DATA)                                             {##DATA##}
	#define QUOTE(DATA)                                             #DATA
	#define MERGE(DATA_1,DATA_2)                                    DATA_1##DATA_2
	#define DOUBLE(DATA_1,DATA_2)                                   DATA_1##_##DATA_2
	#define GVAR(VARNAME)                                           DOUBLE(MACRO_PROJECT_PREFIX,VARNAME)
	#define QGVAR(VARNAME)                                          QUOTE(GVAR(VARNAME))
	#define FUNC(VARNAME)                                           DOUBLE(DOUBLE(MACRO_PROJECT_PREFIX,fnc),VARNAME)
	#define QFUNC(VARNAME)                                          QUOTE(FUNC(VARNAME))
	//#define MACRO_FNC_LOG(DATA)                                     diag_log format ["[CONQUEST] %1", DATA]





// ------------------------------------------------------------------------------------------------------------------------------------------------
//	IDCS
// ------------------------------------------------------------------------------------------------------------------------------------------------

	// Black Screen
	#define MACRO_IDC_BS_BACKGROUND                                 100

	// Combat Area
	#define MACRO_IDC_CA_CTRLGRP                                    100
	#define MACRO_IDC_CA_TEXT_COUNTDOWN                             1000

	// End Screen
	#define MACRO_IDC_ES_CTRLGRP                                    100
	#define MACRO_IDC_ES_TOP_TEXT                                   101
	#define MACRO_IDC_ES_BOTTOM_TEXT                                102

	#define MACRO_IDC_ES_FLAG_LEFT_PICTURE                          1000
	#define MACRO_IDC_ES_TICKETS_LEFT_TEXT                          1001
	#define MACRO_IDC_ES_FLAG_MIDDLE_PICTURE                        1002
	#define MACRO_IDC_ES_TICKETS_MIDDLE_TEXT                        1003
	#define MACRO_IDC_ES_FLAG_RIGHT_PICTURE                         1004
	#define MACRO_IDC_ES_TICKETS_RIGHT_TEXT                         1005

	// Kill Feed
	#define MACRO_IDC_KF_CTRLGRP                                    100

	// Score Feed
	#define MACRO_IDC_SF_CTRLGRP                                    100

	// Sector HUD
	#define MACRO_IDC_SHUD_CTRLGRP                                  100
	#define MACRO_IDC_SHUD_LETTER_TEXT                              101
	#define MACRO_IDC_SHUD_FLAG_PICTURE                             102
	#define MACRO_IDC_SHUD_LEVEL_BACK                               103
	#define MACRO_IDC_SHUD_LEVEL_FRONT                              104
	#define MACRO_IDC_SHUD_LOCK_ICON                                105

	// Health Bar
	#define MACRO_IDC_HB_CTRLGRP                                    100
	#define MACRO_IDC_HB_HEALTH_BACKGROUND                          101
	#define MACRO_IDC_HB_HEALTH_TEXT                                102
	#define MACRO_IDC_HB_HEALTH_ICON                                103

	// Hit Effect
	#define MACRO_IDC_HFX_CTRLGRP                                   100
	#define MACRO_IDC_HFX_HIT_EFFECT_IMAGE                          101

	// Spawn Menu							// IDCs 0 to 2 are reserved for buttons and will cause the display to close when used! (hardcoded engine behaviour) - DO NOT USE THEM!
	#define MACRO_IDC_SM_CTRLGROUP                                  100
	#define MACRO_IDC_SM_BACKGROUND                                 101
	#define MACRO_IDC_SM_MENU_SEPARATOR                             102
	#define MACRO_IDC_SM_FOCUS_FRAME                                103
	#define MACRO_IDC_SM_SIDE_FRAME                                 110
	#define MACRO_IDC_SM_SIDE_BUTTON                                111
	#define MACRO_IDC_SM_ROLE_FRAME                                 112
	#define MACRO_IDC_SM_ROLE_BUTTON                                113
	#define MACRO_IDC_SM_DEPLOY_FRAME                               114
	#define MACRO_IDC_SM_DEPLOY_BUTTON                              115
	#define MACRO_IDC_SM_SPAWN_FRAME                                116
	#define MACRO_IDC_SM_SPAWN_BUTTON                               117

	#define MACRO_IDC_SM_EMPTY_CTRLGROUP                            1000
	#define MACRO_IDC_SM_EMPTY_FOCUS_FRAME                          1001

	#define MACRO_IDC_SM_SIDE_CTRLGROUP                             2000

	#define MACRO_IDC_SM_SIDE_FLAG_LEFT_PICTURE                     2100
	#define MACRO_IDC_SM_SIDE_FLAG_LEFT_GRADIENT                    2101
	#define MACRO_IDC_SM_SIDE_FLAG_LEFT_FILL                        2102
	#define MACRO_IDC_SM_SIDE_FLAG_LEFT_SEPARATOR                   2103
	#define MACRO_IDC_SM_SIDE_FLAG_MIDDLE_PICTURE                   2104
	#define MACRO_IDC_SM_SIDE_FLAG_MIDDLE_GRADIENT                  2105
	#define MACRO_IDC_SM_SIDE_FLAG_MIDDLE_FILL                      2106
	#define MACRO_IDC_SM_SIDE_FLAG_MIDDLE_SEPARATOR                 2107
	#define MACRO_IDC_SM_SIDE_FLAG_RIGHT_PICTURE                    2108
	#define MACRO_IDC_SM_SIDE_FLAG_RIGHT_GRADIENT                   2109
	#define MACRO_IDC_SM_SIDE_FLAG_RIGHT_FILL                       2110
	#define MACRO_IDC_SM_SIDE_FLAG_RIGHT_SEPARATOR                  2111

	#define MACRO_IDC_SM_SIDE_NAME_LEFT_TEXT                        2200
	#define MACRO_IDC_SM_SIDE_TICKETS_LEFT_TEXT                     2201
	#define MACRO_IDC_SM_SIDE_NAME_MIDDLE_TEXT                      2202
	#define MACRO_IDC_SM_SIDE_TICKETS_MIDDLE_TEXT                   2203
	#define MACRO_IDC_SM_SIDE_NAME_RIGHT_TEXT                       2204
	#define MACRO_IDC_SM_SIDE_TICKETS_RIGHT_TEXT                    2205

	#define MACRO_IDC_SM_SIDE_PLAYERS_LEFT_BACKGROUND               2300
	#define MACRO_IDC_SM_SIDE_PLAYERS_LEFT_OUTLINE                  2301
	#define MACRO_IDC_SM_SIDE_PLAYERS_LEFT_LISTBOX                  2302
	#define MACRO_IDC_SM_SIDE_PLAYERS_MIDDLE_BACKGROUND             2303
	#define MACRO_IDC_SM_SIDE_PLAYERS_MIDDLE_OUTLINE                2304
	#define MACRO_IDC_SM_SIDE_PLAYERS_MIDDLE_LISTBOX                2305
	#define MACRO_IDC_SM_SIDE_PLAYERS_RIGHT_BACKGROUND              2306
	#define MACRO_IDC_SM_SIDE_PLAYERS_RIGHT_OUTLINE                 2307
	#define MACRO_IDC_SM_SIDE_PLAYERS_RIGHT_LISTBOX                 2308

	#define MACRO_IDC_SM_SIDE_JOIN_LEFT_FRAME                       2400
	#define MACRO_IDC_SM_SIDE_JOIN_LEFT_BUTTON                      2401
	#define MACRO_IDC_SM_SIDE_JOIN_MIDDLE_FRAME                     2402
	#define MACRO_IDC_SM_SIDE_JOIN_MIDDLE_BUTTON                    2403
	#define MACRO_IDC_SM_SIDE_JOIN_RIGHT_FRAME                      2404
	#define MACRO_IDC_SM_SIDE_JOIN_RIGHT_BUTTON                     2405

	#define MACRO_IDC_SM_ROLE_CTRLGROUP                             3000

	#define MACRO_IDC_SM_ROLE_SPECOPS_BACKGROUND                    3100
	#define MACRO_IDC_SM_ROLE_SPECOPS_FRAME                         3101
	#define MACRO_IDC_SM_ROLE_SPECOPS_SHADOW_PICTURE                3102
	#define MACRO_IDC_SM_ROLE_SPECOPS_WEAPON_PICTURE                3103
	#define MACRO_IDC_SM_ROLE_SPECOPS_BUTTON                        3104

	#define MACRO_IDC_SM_ROLE_SNIPER_BACKGROUND                     3110
	#define MACRO_IDC_SM_ROLE_SNIPER_FRAME                          3111
	#define MACRO_IDC_SM_ROLE_SNIPER_SHADOW_PICTURE                 3112
	#define MACRO_IDC_SM_ROLE_SNIPER_WEAPON_PICTURE                 3113
	#define MACRO_IDC_SM_ROLE_SNIPER_BUTTON                         3114

	#define MACRO_IDC_SM_ROLE_ASSAULT_BACKGROUND                    3120
	#define MACRO_IDC_SM_ROLE_ASSAULT_FRAME                         3121
	#define MACRO_IDC_SM_ROLE_ASSAULT_SHADOW_PICTURE                3122
	#define MACRO_IDC_SM_ROLE_ASSAULT_WEAPON_PICTURE                3123
	#define MACRO_IDC_SM_ROLE_ASSAULT_BUTTON                        3124

	#define MACRO_IDC_SM_ROLE_SUPPORT_BACKGROUND                    3130
	#define MACRO_IDC_SM_ROLE_SUPPORT_FRAME                         3131
	#define MACRO_IDC_SM_ROLE_SUPPORT_SHADOW_PICTURE                3132
	#define MACRO_IDC_SM_ROLE_SUPPORT_WEAPON_PICTURE                3133
	#define MACRO_IDC_SM_ROLE_SUPPORT_BUTTON                        3134

	#define MACRO_IDC_SM_ROLE_ENGINEER_BACKGROUND                   3140
	#define MACRO_IDC_SM_ROLE_ENGINEER_FRAME                        3141
	#define MACRO_IDC_SM_ROLE_ENGINEER_SHADOW_PICTURE               3142
	#define MACRO_IDC_SM_ROLE_ENGINEER_WEAPON_PICTURE               3143
	#define MACRO_IDC_SM_ROLE_ENGINEER_BUTTON                       3144

	#define MACRO_IDC_SM_ROLE_MEDIC_BACKGROUND                      3150
	#define MACRO_IDC_SM_ROLE_MEDIC_FRAME                           3151
	#define MACRO_IDC_SM_ROLE_MEDIC_SHADOW_PICTURE                  3152
	#define MACRO_IDC_SM_ROLE_MEDIC_WEAPON_PICTURE                  3153
	#define MACRO_IDC_SM_ROLE_MEDIC_BUTTON                          3154

	#define MACRO_IDC_SM_ROLE_ANTITANK_BACKGROUND                   3160
	#define MACRO_IDC_SM_ROLE_ANTITANK_FRAME                        3161
	#define MACRO_IDC_SM_ROLE_ANTITANK_SHADOW_PICTURE               3162
	#define MACRO_IDC_SM_ROLE_ANTITANK_WEAPON_PICTURE               3163
	#define MACRO_IDC_SM_ROLE_ANTITANK_BUTTON                       3164

	#define MACRO_IDC_SM_ROLE_PREVIEW_CTRLGROUP                     3200
	#define MACRO_IDC_SM_ROLE_PREVIEW_FOCUS_FRAME                   3201
	#define MACRO_IDC_SM_ROLE_PREVIEW_PICTURE                       3202
	#define MACRO_IDC_SM_ROLE_PREVIEW_FRAME                         3203
	#define MACRO_IDC_SM_ROLE_PREVIEW_CONTROLS_TEXT                 3204

	#define MACRO_IDC_SM_GROUP_GROUPS_LISTBOX                       3300
	#define MACRO_IDC_SM_GROUP_MEMBERS_LISTBOX                      3301

	#define MACRO_IDC_SM_GROUP_JOIN_FRAME                           3310
	#define MACRO_IDC_SM_GROUP_JOIN_BUTTON                          3311
	#define MACRO_IDC_SM_GROUP_CREATE_FRAME                         3312
	#define MACRO_IDC_SM_GROUP_CREATE_BUTTON                        3313
	#define MACRO_IDC_SM_GROUP_LEAVE_FRAME                          3314
	#define MACRO_IDC_SM_GROUP_LEAVE_BUTTON                         3315

	#define MACRO_IDC_SM_DEPLOY_CTRLGROUP                           4000
	#define MACRO_IDC_SM_DEPLOY_SECTORS_CTRLGROUP                   4001
	#define MACRO_IDC_SM_DEPLOY_MAP                                 4100
	#define MACRO_IDC_SM_DEPLOY_SECTOR_START                        4200

	// Spawn Status
	#define MACRO_IDC_SS_CTRLGRP                                    100
	#define MACRO_IDC_SS_STATUS_TEXT                                101

	// Unconscious HUD
	#define MACRO_IDC_UHUD_CTRLGRP                                  100
	#define MACRO_IDC_UHUD_TEXT_COUNTDOWN                           101
	#define MACRO_IDC_UHUD_TEXT_MEDIC_NONE                          102
	#define MACRO_IDC_UHUD_TEXT_MEDIC_DISTANCE                      103
	#define MACRO_IDC_UHUD_TEXT_MEDIC_NAME                          104
	#define MACRO_IDC_UHUD_TEXT_GIVE_UP                             105

	// User Input Blocker
	#define MACRO_IDC_UIB_FOCUS_FRAME                               100





// ------------------------------------------------------------------------------------------------------------------------------------------------
//	UI RELATED
// ------------------------------------------------------------------------------------------------------------------------------------------------

	#define MACRO_POS_SPACER_X                                      3
	#define MACRO_POS_SPACER_Y                                      3

	// Text sizes
	#define MACRO_UI_TEXTSIZE_1                                     0.035
	#define MACRO_UI_TEXTSIZE_2                                     0.05
	#define MACRO_UI_TEXTSIZE_3                                     0.07
	#define MACRO_UI_TEXTSIZE_4                                     0.1
	#define MACRO_UI_TEXTSIZE_5                                     0.15

	// Combat Area
	#define MACRO_POS_CA_WIDTH                                      0.4
	#define MACRO_POS_CA_HEIGHT                                     0.3

	// End Screen
	#define MACRO_POS_ES_TOP_TEXTSIZE                               MACRO_UI_TEXTSIZE_5
	#define MACRO_POS_ES_TICKETS_TEXTSIZE                           MACRO_UI_TEXTSIZE_2

	// Kill Feed
	#define MACRO_POS_KF_Y                                          (0.25 * safeZoneH)
	#define MACRO_POS_KF_WIDTH                                      (0.2 * safeZoneW)
	#define MACRO_POS_KF_WEAPON_WIDTH                               (0.025 * safeZoneW)
	#define MACRO_POS_KF_ICON_WIDTH                                 (0.015 * safeZoneW)
	#define MACRO_POS_KF_ENTRY_HEIGHT                               MACRO_UI_TEXTSIZE_2
	#define MACRO_POS_KF_ENTRY_TEXTSIZE                             MACRO_UI_TEXTSIZE_1
	#define MACRO_POS_KF_ENTRY_MAXCOUNT                             8

	// Score Feed
	#define MACRO_POS_SF_WIDTH                                      (0.33 * safeZoneW)
	#define MACRO_POS_SF_X_OFFSET                                   (0.6 * MACRO_POS_SF_WIDTH)
	#define MACRO_POS_SF_SCORE_WIDTH                                (0.1 * MACRO_POS_SF_WIDTH)
	#define MACRO_POS_SF_ENTRY_HEIGHT                               MACRO_UI_TEXTSIZE_2
	#define MACRO_POS_SF_ENTRY_TEXTSIZE                             MACRO_UI_TEXTSIZE_2
	#define MACRO_POS_SF_ENTRY_MAXCOUNT                             6

	// Sector HUD
	#define MACRO_POS_SHUD_HEIGHT                                   0.07
	#define MACRO_POS_SHUD_FLAG_WIDTH                               ((3 / 2) * MACRO_POS_SHUD_HEIGHT)
	#define MACRO_POS_SHUD_SIDE_WIDTH                               0.03
	#define MACRO_POS_SHUD_TEXTSIZE                                 MACRO_UI_TEXTSIZE_2

	// Sector Flag
	#define MACRO_POS_SFLAG_TEXTSIZE                                MACRO_UI_TEXTSIZE_2

	// Health bar
	#define MACRO_POS_HB_WIDTH                                      0.1
	#define MACRO_POS_HB_HEIGHT                                     MACRO_UI_TEXTSIZE_2
	#define MACRO_POS_HB_ICON_WIDTH                                 0.04
	#define MACRO_POS_HB_ICON_SPACER                                (pixelW * 3)
	#define MACRO_POS_HB_TEXTSIZE                                   MACRO_UI_TEXTSIZE_2

	// Hit Effects
	#define MACRO_POS_HFX_WIDTH                                     (safeZoneW / 2)
	#define MACRO_POS_HFX_HEIGHT                                    (safeZoneH / 2)

	// Spawn Menu
	#define MACRO_POS_SM_WIDTH                                      (safeZoneW * 0.9)
	#define MACRO_POS_SM_HEIGHT                                     (safeZoneH * 0.9)
	#define MACRO_POS_SM_MENU_HEIGHT                                (safeZoneH * 0.85)
	#define MACRO_POS_SM_SIDE_NAME_TEXTSIZE                         (0.02 * safeZoneW)
	#define MACRO_POS_SM_SIDE_TICKETS_TEXTSIZE                      (0.02 * safeZoneW)
	#define MACRO_POS_SM_GROUP_LISTBOX_TEXTSIZE                     (0.02 * safeZoneW)
	#define MACRO_POS_SM_ROLE_PIP_TOP_TEXTSIZE                      (0.05 * safeZoneW)
	#define MACRO_POS_SM_ROLE_PIP_BOTTOM_TEXTSIZE                   (0.02 * safeZoneW)
	#define MACRO_POS_SM_DEPLOY_VEHICLEICON_HEIGHT                  0.04

	// Unconscious HUD
	#define MACRO_POS_UHUD_WIDTH                                    0.55
	#define MACRO_POS_UHUD_HEIGHT                                   0.3
	#define MACRO_POS_UHUD_MEDIC_TEXTSIZE                           MACRO_UI_TEXTSIZE_2

	// Hit Markers
	#define MACRO_UI_HITMARKERS_DURATION                            0.5

	// Kill Feed
	#define MACRO_UI_KILLFEED_ENTRYLIFETIME                         20
	#define MACRO_UI_KILLFEED_ENTRYFADEDURATION                     3
	#define MACRO_UI_KILLFEED_ANIMDURATION                          0.25

	// Score Feed
	#define MACRO_UI_SCOREFEED_ENTRYLIFETIME                        5
	#define MACRO_UI_SCOREFEED_SCORESUMLIFETIME                     10
	#define MACRO_UI_SCOREFEED_ENTRYFADEDURATION                    1
	#define MACRO_UI_SCOREFEED_ANIMDURATION                         0.25

	// GPS Info panels (minimap)
	#define MACRO_UI_GPS_SCALE_INF                                  0.04 // Map scale of the GPS-type info panels when on foot (smaller values = more zoomed in)
	#define MACRO_UI_GPS_SCALE_VEH                                  0.08 // Map scale of the GPS-type info panels when in a vehicle (smaller values = more zoomed in)

	// Sector Names (Locations)
	#define MACRO_UI_SECTORNAMES_SCALEMUL                           1.25 // Scales the size of the sector names (but not their letters) on the map. Higher numbers increase the size of the text
	#define MACRO_UI_SECTORNAMES_FADEMUL                            20 // Scales how quickly the sector names fade out when zooming into the map. Larger numbers make the sector names fade quicker
	#define MACRO_UI_SECTORFLAGS_SCALEMUL                           1.0 // Scales the size of the sector flag icons on the map. Higher numbers increase the size of the flag icons
	#define MACRO_UI_SECTORFLAGS_SCALEOFFSET                        0.03 // When zooming in on the map, the sector flag icons will eventually increase to twice their normal size. This offset lets you choose at which zoom level this transition should happen. Larger numbers lean towards "zoomed out", smaller numbers towards "zoomed in" (logarithmic scale). Accepted range is 0 to 1

	// Unit Icons
	#define MACRO_UI_ICONS3D_MAXDISTANCE_INF                        300 // The maximum distance, in meters, at which infantry 3D icons are visible
	#define MACRO_UI_ICONS3D_MAXDISTANCE_VEH                        1000 // The maximum distance, in meters, at which vehicle 3D icons are visible
	#define MACRO_UI_ICONS3D_MAXDISTANCE_MEDIC                      80 // The maximum distance, in meters, at which medic-specific infantry icons (units in need of healing, and nearby medics) are visible

	// Combat Area
	#define MACRO_CA_CORNEROFFSET                                   50000 // How much the combat area should overextend (beyond the map corners), in meters

	#define MACRO_UI_CALLSIGN_MAXIMUM_LENGTH                        20 // The maximum length of custom group callsigns, in characters

	#define MACRO_UI_MAPFOCUS_PADDING_SM                            0.25
	#define MACRO_UI_MAPFOCUS_PADDING_FULLSCREEN                    0.5

	#define MACRO_FONT_UI_THIN                                     "PuristaLight"
	#define MACRO_FONT_UI_MEDIUM                                   "PuristaMedium"





// ------------------------------------------------------------------------------------------------------------------------------------------------
//	COLOURS
// ------------------------------------------------------------------------------------------------------------------------------------------------

	#define MACRO_COLOUR_A0                                         0.0, 0.0, 0.0, 0.0
	#define MACRO_COLOUR_A25_WHITE                                  1.0, 1.0, 1.0, 0.25
	#define MACRO_COLOUR_A50_WHITE                                  1.0, 1.0, 1.0, 0.5
	#define MACRO_COLOUR_A75_BLACK                                  0.0, 0.0, 0.0, 0.75
	#define MACRO_COLOUR_A75_WHITE                                  1.0, 1.0, 1.0, 0.75
	#define MACRO_COLOUR_A100_BLACK                                 0.0, 0.0, 0.0, 1.0
	#define MACRO_COLOUR_A100_RED                                   1.0, 0.0, 0.0, 1.0
	#define MACRO_COLOUR_A100_GREEN                                 0.0, 1.0, 0.0, 1.0
	#define MACRO_COLOUR_A100_WHITE                                 1.0, 1.0, 1.0, 1.0
	#define MACRO_COLOUR_A100_GREY                                  0.4, 0.4, 0.4, 1.0
	#define MACRO_COLOUR_A100_FRIENDLY                              0.0, 0.5, 1.0, 1.0
	#define MACRO_COLOUR_A100_SQUAD                                 0.0, 1.0, 0.0, 1.0
	#define MACRO_COLOUR_A100_ENEMY                                 0.9, 0.0, 0.0, 1.0

	#define MACRO_COLOUR_INGAME_BACKGROUND                          0.2, 0.2, 0.2, 0.4 // Matches the default colour theme (Stratis Black)

	#define MACRO_COLOUR_BUTTON_ACTIVE                              0.0, 0.3, 0.1, 1.0
	#define MACRO_COLOUR_BUTTON_ACTIVE_PRESSED                      0.0, 0.6, 0.1, 1.0
	#define MACRO_COLOUR_BUTTON_INACTIVE                            0.5, 0.1, 0.1, 1.0

	#define MACRO_COLOUR_SECTOR_LOCKED                              1.0, 0.8, 0.0, 1.0





// ------------------------------------------------------------------------------------------------------------------------------------------------
//	SCRIPT CONTROL
// ------------------------------------------------------------------------------------------------------------------------------------------------

	// Actions
	#define MACRO_ACT_SPOTTING_MINVISIBILITY                        0.5 // The minimum threshold that visibility checks must exceed for a target to be considered spottable (return value of checkVisibility)
	#define MACRO_ACT_SPOTTING_DURATION                             6 // How long, in seconds, a hostile unit/vehicle is visible for when spotted
	#define MACRO_ACT_SPOTTING_COOLDOWNDURATION                     17 // How long the spotting action remains blocked for, in seconds, when in cooldown
	#define MACRO_ACT_SPOTTING_COSTPERUSE                           4 // How much it costs to use the spotting action. Divice the cooldown duration by this value to determine how often the action may be triggered (at once) before entering cooldown

	#define MACRO_ACT_HEALUNIT_MAXDISTANCE                          2 // The distance, in meters, below which medics must be to their patients in order to heal them
	#define MACRO_ACT_HEALUNIT_AMOUNT                               0.15 // The amount of health that is added to patients upon healing, expressed as fraction of their maximum health
	#define MACRO_ACT_HEALUNIT_COOLDOWN                             1 // The cooldown duration, in seconds, between two consecutive healing actions that medics must wait

	#define MACRO_KEYBIND_TOGGLESPAWNMENU                           DIK_F1
	#define MACRO_KEYBIND_HEAL                                      DIK_4
	#define MACRO_KEYBIND_REARM                                     DIK_5
	#define MACRO_KEYBIND_REPAIR                                    DIK_6
	#define MACRO_KEYBIND_GIVEUP                                    DIK_SPACE

	// Combat Area
	#define MACRO_CA_PLAYER_INTERVAL                                0.1 // The interval, in seconds, between two consecutive combat area checks for the player
	#define MACRO_CA_WARNING_ANIMDURATION                           0.5 //  How long, in seconds, the warning UI animation transitions should last

	// AI Control
	#define MACRO_AI_GROUP_CALLSIGNS                                ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot", "Golf", "Hotel", "India", "Juliet", "Kilo", "Lima", "Mike", "November", "Oscar", "Papa", "Quebec", "Romeo", "Sierra", "Tango", "Uniform", "Victor", "Whiskey", "X-ray", "Yankee", "Zulu"]
	#define MACRO_AI_CLAIMVEHICLE_MAXDIST                           50 // How close a unit must be to a vehicle, in meters, before it can attempt to claim it
	#define MACRO_AI_CLAIMVEHICLE_MAXSPEED_MOUNT                    5 // The maximum speed, in m/s, that vehicles are allowed to move to be considered claimable. Prevents units from trying to jump into fast-driving vehicles.
	#define MACRO_AI_CLAIMVEHICLE_MAXSPEED_DISMOUNT                 1 // The maximum speed, in m/s, that vehicles are allowed to move below which units may dismount. Prevents units from trying to jump out of fast-driving vehicles.
	#define MACRO_AI_CLAIMVEHICLE_MAXALTITUDE                       2 // The maximum altitude above ground, in meters, below which vehicles must stay to be considerd claimable
	#define MACRO_AI_CLAIMVEHICLE_INTERVAL                          3 // The interval, in seconds, between AI vehicle claim requests.
	#define MACRO_AI_CLAIMVEHICLE_COOLDOWN                          15 // The cooldown, in seconds, before an AI unit may attempt to claim another vehicle after a previous request was granted. Should be greater than the interval.
	#define MACRO_AI_CLAIMVEHICLE_MAXDIST_MOUNT                     8 // How close a unit must be to a vehicle, in meters, before it is moved into its claimed role
	#define MACRO_AI_MAXDIST_RESPAWN_CLAIMABLE                      100 // How close an AI-claimable vehicle must be to a sector, in meters, for the AI to consider spawning on that sector (does not guarantee a vehicle claim!)
	#define MACRO_AI_CHANCE_RESPAWN_CLAIMVEHICLE                    0.25 // The probability (up to 1) that an AI unit will attempt to spawn on a sector that has a claimable vehicle near it (rather than respawning near its leader/waypoint)
	#define MACRO_AI_DRIVER_MOUNT_DURATION                          15 // How long an AI driver will wait, in seconds, for passengers to mount up before entering cooldown phase
	#define MACRO_AI_DRIVER_MOUNT_COOLDOWN                          120 // The cooldown duration for AI drivers between mount-up pauses (to prevent getting stuck in a pausing loop)
	#define MACRO_AI_DRIVER_LOOKAHEAD_MAXITERATIONS                 10 // The amount of nodes, at most, that AI drivers will look ahead along their route to determine the target speed limit
	#define MACRO_AI_DRIVER_LOOKAHEAD_MAXDIST                       100 // How far, in meters, AI drivers may look ahead into their route to anticipate sharp turns
	#define MACRO_AI_DRIVER_MAXSPEED                                80 // The maximum speed, in km/h, that AI drivers are allowed to drive under ideal circumstances (straight path, long distances between nodes)
	#define MACRO_AI_DRIVER_AVOIDANCE_MAXDISTANCE                   100 // The maximum distance, in meters, to another vehicle for AI drivers to consider it in its obstacle avoidance check
	#define MACRO_AI_DRIVER_FORCEMUL_ROUTEALIGN                     0.6 // Multiplier for AI drivers' goal force to align with the intended route. This force increases the further away the vehicle strays from its intended route
	#define MACRO_AI_PATHFINDINTERVAL_VEH                           10000 // The maximum delay, in seconds, between recalculations of a vehicle's path
	#define MACRO_AI_PATHFINDINTERVAL_INF                           30 // The maximum delay, in seconds, between recalculations of a vehicle's path
	#define MACRO_AI_UNITCONTROL_INTERVAL                           0.5 // Interval, in seconds, between two update cycles of the AI unitControl system (each unit gets updated every this often)
	#define MACRO_AI_DRIVERCONTROL_INTERVAL                         0.25 // Interval, in seconds, between two update cycles of the AI driverControl system (each vehicle driver gets updated every this often)
	#define MACRO_AI_COMMANDER_INTERVAL                             0.25 // Interval, in seconds, between two update cycles of the AI commander system (per side; * 3 for a full cycle)
	#define MACRO_AI_DOMOVEINTERVAL                                 5 // The interval, in seconds, between two doMove commands being issued to AI units (as they sometimes need to be rescheduled to move)
	#define MACRO_AI_MEDICAL_MAXACTIONDISTANCE                      20 // The maximum distance, in meters, that AI units are willing to travel in order to perform medical actions on others, or to receive medical attention
	#define MACRO_AI_MEDICAL_CHANGESTANCEDISTANCE                   8 // The distance to the patient, in meters, below which the unit will adjust its stance to that of the patient
	#define MACRO_AI_MEDICAL_PATIENT_STOPDURATIONPERHEAL            2 // For how long an AI unit remains stopped, in seconds, after being healed (prevents them from running away while being healed)
	#define MACRO_AI_COMMANDER_STRATEGICVALUE_DECREASEPERGROUP      4 // By how much a sector's current strategic value is divided, for each group ordered to it (per iteration of the commander system)
	#define MACRO_AI_COMMANDER_SECTOR_MINLEVELOWNED                 0.8 // The minimum capturing level of owned sectors for them to be considered as candidates
	#define MACRO_AI_COMMANDER_WAYPOINT_MINDISTANCE                 5 // Minimum distance, in meters, that a potential new waypoint must be from a group's current waypoint to be submitted
	#define MACRO_AI_COMMANDER_NEWORDER_COOLDOWN                    20 // Average (+/-25%) cooldown, in seconds, between two orders to a group from the AI commander (even if the orders are identical)

	// Gamemode
	#define MACRO_GM_KILLASSISTDURATION                             10 // How long (in seconds), after damaging an enemy unit, it is possible to receive a kill assist for
	#define MACRO_GM_SYS_TICKETS_INTERVAL                           0.25 // Interval, in seconds, between two update cycles of the tickets system
	#define MACRO_GM_SYS_ENDCONDITIONS_INTERVAL                     0.25 // Interval, in seconds, between two update cycles of the end conditions system
	#define MACRO_GM_SYS_HANDLEPLAYERRESPAWN_INTERVAL               0.05 // Interval, in seconds, between two update cycles of the player respawn system (Note: must be less than the MP respawn time!)
	#define MACRO_GM_SYS_HANDLECURATOR_INTERVAL                     1 // Interval, in seconds, between two update cycles of the end curator handler system

	// Sectors
	#define MACRO_SECTOR_TRIGGERINTERVAL                            0.5 // The interval between two trigger executions, in seconds
	#define MACRO_SECTOR_SCOREINTERVAL                              0.1 // The level interval between two score events for capturing a sector, in percent (1 being 100%)
	#define MACRO_SECTOR_VEH_DELAYUNTILDAMAGE                       30 // How long, in seconds, a vehicle must be outside of the combat area (or be disabled) before it starts taking damage (to eventually respawn it)
	#define MACRO_SECTOR_VEH_MAXSQRDISTFROMSPAWN                    50 ^ 2 // How far, in meters squared, vehicles may be moved from their spawn position before they are marked as abandoned and considered for cleanup

	// Nodemesh Settings
	#define MACRO_NM_DEFAULTRADIUS_INF                              3 // Minimum completion radius, in meters, of pathfind nodes for infantry
	#define MACRO_NM_DEFAULTRADIUS_VEH                              2 // Minimum completion radius, in meters, of pathfind nodes for vehicles
	#define MACRO_NM_SEARCHRADIUS_NODES_INF                         50 // How big, in meters, the search radius for start/end nodes around the query's origin/destination should be (for infantry pathfinding)
	#define MACRO_NM_SEARCHRADIUS_NODES_VEH                         50 // Same as above, but for vehicle pathfinding
	#define MACRO_NM_COSTMULTIPLIER_OFFMESH_INF                     1.5 // By how much the node cost is multiplied when travelling to/from points outside of the nodemesh (such as the origin/destination), for infantry
	#define MACRO_NM_COSTMULTIPLIER_OFFMESH_VEH                     3 // By how much the node cost is multiplied when travelling to/from points outside of the nodemesh (such as the origin/destination), for vehicles
	#define MACRO_NM_MAXCOUNT_NODES                                 10 // How many start/end nodes may be considered in each findPath query (more may yield better results, but impacts performance)
	#define MACRO_NM_DANGERLEVEL_INF_DECREASERATE                   2 // By how much the danger level of all infantry node edges should decrease, per second
	#define MACRO_NM_DANGERLEVEL_VEH_DECREASERATE                   3 // By how much the danger level of all vehicle node edges should decrease, per second
	#define MACRO_NM_DANGERLEVEL_INF_GAIN                           100 // By how much an edge's danger level increases if an infantry unit dies on it
	#define MACRO_NM_DANGERLEVEL_VEH_GAIN                           600 // By how much an edge's danger level increases if a vehicle is destroyed on it (does not account for the crew!)
	#define MACRO_NM_DANGERLEVEL_INF_MAX                            1000 // The maximum cap for an infantry node edge's danger level
	#define MACRO_NM_DANGERLEVEL_VEH_MAX                            2000 // The maximum cap for a vehicle node edge's danger level
	#define MACRO_NM_BITFLAG_SIDE_EAST                              4 // 2^2
	#define MACRO_NM_BITFLAG_SIDE_RESISTANCE                        2 // 2^1
	#define MACRO_NM_BITFLAG_SIDE_WEST                              1 // 2^0

	// Spawn menu
	#define MACRO_SM_ROLEPREVIEW_BASEHEIGHTASL                      10 // The height above sea level, in meters, that the spawn menu objects (preview unit, etc.) will spawn at
	#define MACRO_SM_ROLEPREVIEW_BASEFOV                            0.1 // The default field of view of the role preview camera
	#define MACRO_SM_ROLEPREVIEW_BASEDIRECTION                      315 // The default direction, in degrees, that the role preview unit should be facing
	#define MACRO_SM_RESPAWN_OPENINTERVAL                           3 // When the player is respawning and closes the spawn menu, it is reopened after this many seconds (prevents the player from being unable to respawn after accidentally closing the menu)
	#define MACRO_SM_MENU_UPDATEINTERVAL                            0.15 // Interval, in seconds, between periodic updates of the currently opened menu's contents (groups, units, vehicles, sectors, etc.)

	// Unconscious HUD
	#define MACRO_UHUD_FADEIN_ANIMDURATION                          0.5 //  How long, in seconds, the unconscious HUD fade-in animation should last

	// Tickets
	#define MACRO_TICKETBLEED_SECTORRATIOTHRESHOLD                  0.6 // The threshold of a side's owned sectors ratio, below which the side receives ticket bleed. The side with the highest ratio determines the target value that each side's ratio is compared against. Uncaptured (neutral) sectors are not counted.
	#define MACRO_TICKETBLEED_INTERVAL_SLOW                         20 // The interval, in seconds, in which slow ticket bleed occurs. Ticket bleed causes a penalty of one ticket to sides which own less than the speciifed ratio of all captured sectors.
	#define MACRO_TICKETBLEED_INTERVAL_FAST                         1 // The interval, in seconds, in which fast ticket bleed occurs. Fast ticket bleed only occurs when a side owns no sectors, but still has units which are alive.
	#define MACRO_TICKETS_WARNINGTHRESHOLD                          50 // When 2 out of 3 sides have fewer than this many tickets, a warning is broadcast to build up suspense (the mission will likely be over soon)
	#define MACRO_TICKETS_DECISIVETHRESHOLD                         100 // If the round ends, and the winning side has at least this many tickets left, the end counts as a decisive victory/crushing defeat

	// Health
	#define MACRO_UNIT_HEALTH_FALLDAMAGEHEIGHT                      3 // The height in meters beyond which units receive fall damage when jumping off of surfaces (assuming no initial velocity)
	#define MACRO_UNIT_HEALTH_THRESHOLDLOW                          0.5 // The threshold of health below which a unit is considered to be at low health

	// Framework
	#define MACRO_MISSION_FRAMEWORK_VERSION                         "0.14.645" // The version of this framework
	#define MACRO_MISSION_FRAMEWORK_GAMEMODE                        "Conquest"

 	// Multiplayer settings (referenced by the Steam server browser)
	#define MACRO_MISSION_FRAMEWORK_MP_GAMETYPE_ENUM                SC // For a list of values, refer to: https://community.bistudio.com/wiki/Multiplayer_Game_Types
	#define MACRO_MISSION_FRAMEWORK_MP_MINPLAYERS                   1
	#define MACRO_MISSION_FRAMEWORK_MP_MAXPLAYERS                   64

	// Corpse/wreck removal
	#define MACRO_CLEANUPDELAY_CORPSE                               30 // How long, in seconds, a unit corpse persists after death before being removed
	#define MACRO_CLEANUPDELAY_WRECK                                60 // How long, in seconds, a Vehicle wreck persists after destruction before being removed





// ------------------------------------------------------------------------------------------------------------------------------------------------
//	CLASS NAMES
// ------------------------------------------------------------------------------------------------------------------------------------------------

	#define MACRO_CLASS_SPAWNPOINT_UNIT                             "Sign_Arrow_Direction_Blue_F"
	#define MACRO_CLASS_SPAWNPOINT_VEHICLE                          "Logic"
	#define MACRO_CLASS_ATTACKPOINT                                 "Sign_Arrow_Green_F"
	#define MACRO_CLASS_FLAG                                        "Flag_White_F"

	#define MACRO_CLASS_COMBATAREA_NODE                             "VR_3DSelector_01_incomplete_F"
	#define MACRO_CLASS_NODEMESH_NODE_INF                           "Sign_Sphere100cm_F" // Must be unique!
	#define MACRO_CLASS_NODEMESH_NODE_VEH                           "Sign_Sphere200cm_F" // Must be unique!
	#define MACRO_CLASS_NODEMESH_OCCLUDER_INF                       "Sign_Arrow_Large_Green_F" // Must be unique!
	#define MACRO_CLASS_NODEMESH_OCCLUDER_VEH                       "Sign_Arrow_Large_Cyan_F" // Must be unique!





// ------------------------------------------------------------------------------------------------------------------------------------------------
//	SCORE VALUES
// ------------------------------------------------------------------------------------------------------------------------------------------------

	// Score penalties are defined as negative values
	#define MACRO_SCORE_SECTOR_NEUTRALISED                          200
	#define MACRO_SCORE_SECTOR_CAPTURING                            20 // Triggered for every 10% of level change
	#define MACRO_SCORE_SECTOR_CAPTURED                             300

	#define MACRO_SCORE_HEAL                                        1 // Per health point healed
	#define MACRO_SCORE_REVIVE                                      50

	#define MACRO_SCORE_SUICIDE                                     -100
	#define MACRO_SCORE_SPOTASSIST                                  25
	#define MACRO_SCORE_KILL_ENEMY                                  100
	#define MACRO_SCORE_KILL_FRIENDLY                               -250
	#define MACRO_SCORE_HEADSHOT                                    25

	#define MACRO_SCORE_DESTROYVEHICLE_ENEMY                        200
	#define MACRO_SCORE_DESTROYVEHICLE_FRIENDLY                     -500

	#define MACRO_SCORE_SIDEDEFEATED                                1000 // Awarded anytime a side is fully defeated (both in 3-sided missions, and on mission end)





// ------------------------------------------------------------------------------------------------------------------------------------------------
//	SCORE ENUMS
// ------------------------------------------------------------------------------------------------------------------------------------------------

	#define MACRO_ENUM_SCORE_INVALID                               -1

	#define MACRO_ENUM_SCORE_SECTOR_NEUTRALISED                     0
	#define MACRO_ENUM_SCORE_SECTOR_CAPTURING                       1
	#define MACRO_ENUM_SCORE_SECTOR_CAPTURED                        2

	//TODO: Add messages for the following macros
	#define MACRO_ENUM_SCORE_HEAL                                   10
	#define MACRO_ENUM_SCORE_REVIVE                                 11
	//#define MACRO_ENUM_SCORE_REPAIR                                 12
	//#define MACRO_ENUM_SCORE_REARM                                  13

	#define MACRO_ENUM_SCORE_SUICIDE                                20
	#define MACRO_ENUM_SCORE_DESERTING                              21

	#define MACRO_ENUM_SCORE_SPOTASSIST                             30
	#define MACRO_ENUM_SCORE_KILLASSIST                             31

	#define MACRO_ENUM_SCORE_KILL_ENEMY                             40
	#define MACRO_ENUM_SCORE_KILL_FRIENDLY                          41
	#define MACRO_ENUM_SCORE_HEADSHOT                               42

	#define MACRO_ENUM_SCORE_DESTROYVEHICLE_ENEMY                   50
	#define MACRO_ENUM_SCORE_DESTROYVEHICLE_FRIENDLY                51

	#define MACRO_ENUM_SCORE_SIDEDEFEATED                           60





// ------------------------------------------------------------------------------------------------------------------------------------------------
//	ROLE ENUMS
// ------------------------------------------------------------------------------------------------------------------------------------------------

	#define MACRO_ENUM_ROLE_INVALID                                 -1

	#define MACRO_ENUM_ROLE_SPECOPS                                 0
	#define MACRO_ENUM_ROLE_SNIPER                                  1
	#define MACRO_ENUM_ROLE_ASSAULT                                 2
	#define MACRO_ENUM_ROLE_SUPPORT                                 3
	#define MACRO_ENUM_ROLE_ENGINEER                                4
	#define MACRO_ENUM_ROLE_MEDIC                                   5
	#define MACRO_ENUM_ROLE_ANTITANK                                6





// ------------------------------------------------------------------------------------------------------------------------------------------------
//	LOADOUT ABILITIES ENUMS
// ------------------------------------------------------------------------------------------------------------------------------------------------

	#define MACRO_ENUM_LOADOUT_ABILITY_INVALID                      -1

	// Role-based abilities
	#define MACRO_ENUM_LOADOUT_ABILITY_RESUPPLY                     0
	#define MACRO_ENUM_LOADOUT_ABILITY_REPAIR                       1
	#define MACRO_ENUM_LOADOUT_ABILITY_HEAL                         2

	// loadouts-based abilities
	#define MACRO_ENUM_LOADOUT_ABILITY_BINOCULAR                    10
	#define MACRO_ENUM_LOADOUT_ABILITY_NVGS                         11
	#define MACRO_ENUM_LOADOUT_ABILITY_MINEDETECTOR                 12
	#define MACRO_ENUM_LOADOUT_ABILITY_ANTITANK                     13
	#define MACRO_ENUM_LOADOUT_ABILITY_HANDGRENADE_FRAG             14
	#define MACRO_ENUM_LOADOUT_ABILITY_HANDGRENADE_SMOKE            15
	#define MACRO_ENUM_LOADOUT_ABILITY_GRENADELAUNCHER              16
	#define MACRO_ENUM_LOADOUT_ABILITY_EXPLOSIVES                   17
	#define MACRO_ENUM_LOADOUT_ABILITY_MINE_AP                      18
	#define MACRO_ENUM_LOADOUT_ABILITY_MINE_AT                      19





// ------------------------------------------------------------------------------------------------------------------------------------------------
//	AI IDENTITY ENUMS
// ------------------------------------------------------------------------------------------------------------------------------------------------

	#define MACRO_ENUM_AIIDENTITY_UNITINDEX                         0
	#define MACRO_ENUM_AIIDENTITY_SIDEINDEX                         1
	#define MACRO_ENUM_AIIDENTITY_GROUPINDEX                        2
	#define MACRO_ENUM_AIIDENTITY_ISLEADER                          3
	#define MACRO_ENUM_AIIDENTITY_ROLE                              4
	#define MACRO_ENUM_AIIDENTITY_NAME                              5
	#define MACRO_ENUM_AIIDENTITY_FACE                              6
	#define MACRO_ENUM_AIIDENTITY_SPEAKER                           7





// ------------------------------------------------------------------------------------------------------------------------------------------------
//	VEHICLE CREW ROLE ENUMS
// ------------------------------------------------------------------------------------------------------------------------------------------------

	#define MACRO_ENUM_VEHICLEROLE_INVALID                          -1

	#define MACRO_ENUM_VEHICLEROLE_DRIVER                           0
	#define MACRO_ENUM_VEHICLEROLE_GUNNER                           1
	#define MACRO_ENUM_VEHICLEROLE_COMMANDER                        2
	#define MACRO_ENUM_VEHICLEROLE_TURRET                           3
	#define MACRO_ENUM_VEHICLEROLE_CARGO                            4





// ------------------------------------------------------------------------------------------------------------------------------------------------
//	VEHICLE TYPE ENUMS
// ------------------------------------------------------------------------------------------------------------------------------------------------

	#define MACRO_ENUM_VEHICLETYPE_UNKNOWN                          -1

	#define MACRO_ENUM_VEHICLETYPE_CAR                              0
	#define MACRO_ENUM_VEHICLETYPE_MRAP                             1
	#define MACRO_ENUM_VEHICLETYPE_TRUCK                            2

	#define MACRO_ENUM_VEHICLETYPE_APC                              10
	#define MACRO_ENUM_VEHICLETYPE_AA                               11
	#define MACRO_ENUM_VEHICLETYPE_TANK                             12

	#define MACRO_ENUM_VEHICLETYPE_HELI_TRANSPORT                   100
	#define MACRO_ENUM_VEHICLETYPE_HELI_ATTACK                      101

	#define MACRO_ENUM_VEHICLETYPE_JET                              110

	#define MACRO_ENUM_VEHICLETYPE_BOAT_TRANSPORT                   200
	#define MACRO_ENUM_VEHICLETYPE_BOAT_ATTACK                      201





// ------------------------------------------------------------------------------------------------------------------------------------------------
//	RADIO MESSAGE ENUMS
// ------------------------------------------------------------------------------------------------------------------------------------------------

	// NOTE: This list is ordered! The ID determines the priority of the message (higher number = higher priority)
	#define MACRO_ENUM_RADIOMSG_INVALID                             -1

	#define MACRO_ENUM_RADIOMSG_ROUNDSTART                          0

	#define MACRO_ENUM_RADIOMSG_LEAVINGCOMBATAREA                   10

	#define MACRO_ENUM_RADIOMSG_SECTORCAPTURING_1                   20
	#define MACRO_ENUM_RADIOMSG_SECTORCAPTURING_2                   21
	#define MACRO_ENUM_RADIOMSG_SECTORCAPTURING_3                   22

	#define MACRO_ENUM_RADIOMSG_SECTORCAPTURED_1                    30
	#define MACRO_ENUM_RADIOMSG_SECTORCAPTURED_2                    31
	#define MACRO_ENUM_RADIOMSG_SECTORCAPTURED_3                    32

	#define MACRO_ENUM_RADIOMSG_SECTORLOSING_1                      40
	#define MACRO_ENUM_RADIOMSG_SECTORLOSING_2                      41
	#define MACRO_ENUM_RADIOMSG_SECTORLOSING_3                      42

	#define MACRO_ENUM_RADIOMSG_SECTORLOST_1                        50
	#define MACRO_ENUM_RADIOMSG_SECTORLOST_2                        51

	#define MACRO_ENUM_RADIOMSG_TICKETSLOW_WIN                      60
	#define MACRO_ENUM_RADIOMSG_TICKETSLOW_LOSE                     61

	#define MACRO_ENUM_RADIOMSG_SIDEDEFEATED_WIN                    70
	#define MACRO_ENUM_RADIOMSG_SIDEDEFEATED_LOSE                   71





// ------------------------------------------------------------------------------------------------------------------------------------------------
//	MISSION STATE ENUMS
// ------------------------------------------------------------------------------------------------------------------------------------------------

	#define MACRO_ENUM_MISSION_INIT                                 0
	#define MACRO_ENUM_MISSION_SAFESTART                            1
	#define MACRO_ENUM_MISSION_LIVE                                 2
	#define MACRO_ENUM_MISSION_ENDING                               3





// ------------------------------------------------------------------------------------------------------------------------------------------------
//	ENDING STATE ENUMS
// ------------------------------------------------------------------------------------------------------------------------------------------------

	#define MACRO_ENUM_ENDMISSION_INIT                              0
	#define MACRO_ENUM_ENDMISSION_PLAYMUSIC                         1
	#define MACRO_ENUM_ENDMISSION_FADEMUSIC                         2
	#define MACRO_ENUM_ENDMISSION_ENDING                            3





// ------------------------------------------------------------------------------------------------------------------------------------------------
//	RESPAWN STATE ENUMS
// ------------------------------------------------------------------------------------------------------------------------------------------------

	#define MACRO_ENUM_RESPAWN_INIT                                 0
	#define MACRO_ENUM_RESPAWN_SELECTINGSECTOR                      1
	#define MACRO_ENUM_RESPAWN_SECTORSELECTED                       2
	#define MACRO_ENUM_RESPAWN_SPAWNREQUESTED                       3
	#define MACRO_ENUM_RESPAWN_SPAWNED_FROZEN                       4
	#define MACRO_ENUM_RESPAWN_SPAWNED_UNFROZEN                     5
	#define MACRO_ENUM_RESPAWN_SPAWNED_UNPROTECTED                  6
	#define MACRO_ENUM_RESPAWN_UNCONSCIOUS                          7





// ------------------------------------------------------------------------------------------------------------------------------------------------
//	DAMAGE ENUMS
// ------------------------------------------------------------------------------------------------------------------------------------------------

	#define MACRO_ENUM_DAMAGE_UNKNOWN                               0
	#define MACRO_ENUM_DAMAGE_BULLET                                1
	#define MACRO_ENUM_DAMAGE_EXPLOSIVE                             2
	#define MACRO_ENUM_DAMAGE_PHYSICS                               3
	#define MACRO_ENUM_DAMAGE_COMBATAREA                            4





// ------------------------------------------------------------------------------------------------------------------------------------------------
//	KILLFEED ICONS
// ------------------------------------------------------------------------------------------------------------------------------------------------

	//#define MACRO_KILLICON_VEHICLE_COOKOFF                          "a3\ui_f\data\GUI\Cfg\Hints\Death_ca.paa"
	#define MACRO_ENUM_KF_ICON_NONE                                 0
	#define MACRO_ENUM_KF_ICON_HEADSHOT                             1
	#define MACRO_ENUM_KF_ICON_ROADKILL                             2
	#define MACRO_ENUM_KF_ICON_MINE                                 3
	#define MACRO_ENUM_KF_ICON_EXPLOSIVE                            4

	#define MACRO_KF_ICON_HEADSHOT                                  "a3\ui_f\data\IGUI\Cfg\simpleTasks\types\kill_ca.paa"
	#define MACRO_KF_ICON_ROADKILL                                  "a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_driver_ca.paa"
	#define MACRO_KF_ICON_MINE                                      "a3\ui_f\data\IGUI\Cfg\simpleTasks\types\mine_ca.paa"
	#define MACRO_KF_ICON_EXPLOSIVE                                 "a3\ui_f\data\IGUI\Cfg\simpleTasks\types\destroy_ca.paa"





// ------------------------------------------------------------------------------------------------------------------------------------------------
//	CLASS KINDS
// ------------------------------------------------------------------------------------------------------------------------------------------------

	#define MACRO_ENUM_CLASSKIND_NONE                               0
	#define MACRO_ENUM_CLASSKIND_VEHICLE                            1
	#define MACRO_ENUM_CLASSKIND_WEAPON                             2
	#define MACRO_ENUM_CLASSKIND_MAGAZINE                           3
	#define MACRO_ENUM_CLASSKIND_AMMO                               4





// ------------------------------------------------------------------------------------------------------------------------------------------------
//	AI REQUEST PIORITIES
// ------------------------------------------------------------------------------------------------------------------------------------------------

	#define MACRO_ENUM_AI_PRIO_BASESETTINGS                          0

	#define MACRO_ENUM_AI_PRIO_MEDICAL                               1
	#define MACRO_ENUM_AI_PRIO_DODGEVEHICLE                          2

	#define MACRO_ENUM_AI_PRIO_UNCONSCIOUS                           10
	#define MACRO_ENUM_AI_PRIO_SAFESTART                             11





// ------------------------------------------------------------------------------------------------------------------------------------------------
//	AI MOVE TYPES
// ------------------------------------------------------------------------------------------------------------------------------------------------

	#define MACRO_ENUM_AI_MOVETYPE_HALT                              0
	#define MACRO_ENUM_AI_MOVETYPE_REGROUP                           1
	#define MACRO_ENUM_AI_MOVETYPE_GOAL                              2
	#define MACRO_ENUM_AI_MOVETYPE_ACTION                            3





// ------------------------------------------------------------------------------------------------------------------------------------------------
//	DEBUG
// ------------------------------------------------------------------------------------------------------------------------------------------------

	//#define MACRO_DEBUG_AI_COMMANDER
	//#define MACRO_DEBUG_AI_COMMANDER_DISABLED
	//#define MACRO_DEBUG_AI_DRIVER
	//#define MACRO_DEBUG_AI_DRIVER_HALT
	//#define MACRO_DEBUG_AI_MOVEPOS
	//#define MACRO_DEBUG_AI_DODGEVEHICLES

	//#define MACRO_DEBUG_CA

	#define MACRO_DEBUG_GM_PRESLOT

	//#define MACRO_DEBUG_NM_OCCLUDERS
	//#define MACRO_DEBUG_NM_NODES_INF
	//#define MACRO_DEBUG_NM_NODES_VEH
	//#define MACRO_DEBUG_NM_NODE_IDS
	//#define MACRO_DEBUG_NM_PATH
