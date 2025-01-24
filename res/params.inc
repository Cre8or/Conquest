// Common defines (needs to match fac_getFilePath)
// Both values and texts arrays must always be in the same order!
#define MACRO_FACTIONS_VALUES { \
	MACRO_ENUM_FACTION_NATO_DES, \
	MACRO_ENUM_FACTION_NATO_WDL, \
	MACRO_ENUM_FACTION_AAF, \
	MACRO_ENUM_FACTION_CSAT, \
 \
	MACRO_ENUM_FACTION_USMC, \
	MACRO_ENUM_FACTION_AFRF \
}

#define MACRO_FACTIONS_TEXTS { \
	"[A3] - NATO (North Atlantic Treaty Organisation) - Desert", \
	"[A3] - NATO (North Atlantic Treaty Organisation) - Woodland", \
	"[A3] - AAF (Altis Armed Forces)", \
	"[A3] - CSAT (Canton Protocol Strategic Alliance Treaty)", \
 \
	"[CUP] - USMC (United States Marines Corps)", \
	"[CUP] - AFRF (Armed Forces of the Russian Federation)" \
}





// ----------------------------------------------------------------------------------------------------------------------------------
//	GAMEPLAY SETTINGS
// ----------------------------------------------------------------------------------------------------------------------------------
class Header_GM {
	title = "---------------------------------------------------------------- GAMEPLAY SETTINGS --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------";
	values[] = { "" };
	default = 0;
};

// Unlike everywhere else, here in the mission parameters the order of the sides is changed to be more readable.
// This does not have an impact on other code areas though, as the player-facing texts mention BLU/OP/INDFOR, while the
// parameter names (and thus the resulting GVARs) use east/resistance/west.
class Param_GM_FactionEnum_West {
	title = "1.1 - BLUFOR faction:";
	values[] = MACRO_FACTIONS_VALUES;
	texts[] = MACRO_FACTIONS_TEXTS;
	default = MACRO_GM_FACTIONENUM_BLUFOR;
};

class Param_GM_FactionEnum_East {
	title = "1.2 - OPFOR faction:";
	values[] = MACRO_FACTIONS_VALUES;
	texts[] = MACRO_FACTIONS_TEXTS;
	default = MACRO_GM_FACTIONENUM_OPFOR;
};

#ifdef MACRO_MISSION_USES_INDFOR
	class Param_GM_FactionEnum_Resistance {
		title = "1.3 - INDFOR faction:";
		values[] = MACRO_FACTIONS_VALUES;
		texts[] = MACRO_FACTIONS_TEXTS;
		default = MACRO_GM_FACTIONENUM_INDFOR;
	};
#else
	class Param_GM_FactionEnum_Resistance {
		title = "1.3 - INDFOR faction (disabled):";
		values[] = {MACRO_ENUM_FACTION_INVALID};
		texts[] = {"-"};
		default = 0;
	};
#endif

class Param_GM_StartingTickets {
	title = "1.4 - Starting tickets:";
	values[] = { 50, 100, 150, 200, 250, 300, 350, 400, 450, 500, 600, 700, 800, 900, 1000, 1200, 1500, 2000 };
	default = MACRO_GM_STARTINGTICKETS;
};

class Param_GM_SafeStartDuration {
	title = "1.5 - Safe-start duration (in seconds):";
	values[] = { 5, 10, 15, 20, 30, 60, 120, 180, 240, 300 };
	default = MACRO_GM_SAFESTARTDURATION;
};

class Param_GM_Unit_RespawnDelay {
	title = "1.6 - Respawn delay (in seconds):";
	values[] = { 5, 10, 15, 20, 30, 45, 60, 90, 120 };
	default = MACRO_GM_UNIT_RESPAWNDELAY;
};

class Param_GM_Unit_ReviveDuration {
	title = "1.7 - Revive duration (in seconds):";
	values[] = { 5, 10, 15, 20, 30, 45, 60, 90, 120, 180, 240, 300, 600 };
	default = MACRO_GM_UNIT_REVIVEDURATION;
};

class Param_GM_Unit_SpawnProtectionDuration {
	title = "1.8 - Spawn protection duration (in seconds):";
	values[] = { 0, 1, 2, 3, 4, 5 };
	default = MACRO_GM_UNIT_SPAWNPROTECTIONDURATION;
};

class Param_GM_Sector_CaptureDuration {
	title = "1.9 - Sector capture duration (in seconds):";
	values[] = { 5, 10, 15, 20, 25, 30, 45, 60, 90, 120 };
	default = MACRO_GM_SECTOR_CAPTUREDURATION;
};

class Param_GM_EnableVehicles {
	title = "1.10 - Enable vehicles (if applicable):";
	values[] = { 0, 1 };
	texts[] = { "No", "Yes" };
	isBoolean = 1;
	default = MACRO_GM_ENABLEVEHICLES;
};

class Param_CA_GraceDuration {
	title = "1.11 - Combat area grace duration (in seconds):";
	values[] = { 3, 5, 10, 15, 20, 25, 30 };
	default = MACRO_CA_GRACEDURATION;
};





// ----------------------------------------------------------------------------------------------------------------------------------
//	AI SETTINGS
// ----------------------------------------------------------------------------------------------------------------------------------
class Header_AI {
	title = "---------------------------------------------------------------- AI SETTINGS --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------";
	values[] = { "" };
	default = 0;
};

class Param_AI_MaxCount {
	title = "2.1 - Maximum AI count:";
	values[] = { 0, 1, 2, 3, 4, 8, 16, 24, 32, 48, 64, 96, 128, 192, 256 };
	default = MACRO_AI_MAXCOUNT;
};

class Param_AI_IncludePlayers {
	title = "2.2 - Reduce AI amount by the player count (more players leads to fewer AI):";
	values[] = { 0, 1 };
	texts[] = { "No", "Yes" };
	isBoolean = 1;
	default = MACRO_AI_INCLUDEPLAYERS;
};

class Param_AI_AllowVehicles {
	title = "2.3 - Are AI allowed to use vehicles:";
	values[] = { 0, 1 };
	texts[] = { "No", "Yes" };
	isBoolean = 1;
	default = MACRO_AI_ALLOWVEHICLES;
};

class Param_AI_MaxUnitsPerGroup {
	title = "2.4 - Maximum size of AI groups:";
	values[] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
	default = MACRO_AI_MAXUNITSPERGROUP;
};

class Param_AI_SpawnWeight_West {
	title = "2.5 - AI spawn bias for BLUFOR:";
	values[] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 };
	default = MACRO_AI_SPAWNWEIGHT_BLUFOR;
};

class Param_AI_SpawnWeight_East {
	title = "2.6 - AI spawn bias for OPFOR:";
	values[] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 };
	default = MACRO_AI_SPAWNWEIGHT_OPFOR;
};

#ifdef MACRO_MISSION_USES_INDFOR
	class Param_AI_SpawnWeight_Resistance {
		title = "2.7 - AI spawn bias for INDFOR:";
		values[] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 };
		default = MACRO_AI_SPAWNWEIGHT_INDFOR;
	};
#else
	class Param_AI_SpawnWeight_Resistance {
		title = "2.7 - AI spawn bias for INDFOR (disabled):";
		values[] = {0};
		texts[] = {"-"};
		default = 0;
	};
#endif




// Cleanup
#undef MACRO_FACTIONS_VALUES
#undef MACRO_FACTIONS_TEXTS
