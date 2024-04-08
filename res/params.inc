// ----------------------------------------------------------------------------------------------------------------------------------
//	AI SETTINGS
// ----------------------------------------------------------------------------------------------------------------------------------
class Header_AI {
	title = "---------------------------------------------------------------- AI SETTINGS --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------";
	values[] = { "" };
	default = 0;
};

class Param_AI_MaxCount {
	title = "Maximum AI count:";
	values[] = { 0, 1, 2, 3, 4, 8, 16, 24, 32, 48, 64, 96, 128, 192, 256 };
	default = MACRO_AI_MAXCOUNT;
};

class Param_AI_IncludePlayers {
	title = "Consider players in the AI count:";
	values[] = { 0, 1 };
	texts[] = { "No", "Yes" };
	isBoolean = 1;
	default = MACRO_AI_INCLUDEPLAYERS;
};

class Param_AI_AllowVehicles {
	title = "AI can use vehicles:";
	values[] = { 0, 1 };
	texts[] = { "No", "Yes" };
	isBoolean = 1;
	default = MACRO_AI_ALLOWVEHICLES;
};

class Param_AI_MaxUnitsPerGroup {
	title = "Maximum size of AI groups:";
	values[] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
	default = MACRO_AI_MAXUNITSPERGROUP;
};

class Param_AI_SpawnWeight_East {
	title = __EVAL("AI spawn bias for side """ + MACRO_SIDE_NAME_EAST + """:");
	values[] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 };
	default = MACRO_AI_SPAWNWEIGHT_EAST;
};

class Param_AI_SpawnWeight_Resistance {
	title = __EVAL("AI spawn bias for side """ + MACRO_SIDE_NAME_RESISTANCE + """:");
	values[] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 };
	default = MACRO_AI_SPAWNWEIGHT_RESISTANCE;
};

class Param_AI_SpawnWeight_West {
	title = __EVAL("AI spawn bias for side """ + MACRO_SIDE_NAME_WEST + """:");
	values[] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 };
	default = MACRO_AI_SPAWNWEIGHT_WEST;
};





// ----------------------------------------------------------------------------------------------------------------------------------
//	GAMEPLAY SETTINGS
// ----------------------------------------------------------------------------------------------------------------------------------
class Header_GM {
	title = "---------------------------------------------------------------- GAMEPLAY SETTINGS --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------";
	values[] = { "" };
	default = 0;
};

class Param_GM_StartingTickets {
	title = "Starting tickets:";
	values[] = { 50, 100, 150, 200, 250, 300, 350, 400, 450, 500, 600, 700, 800, 900, 1000, 1200, 1500, 2000 };
	default = MACRO_GM_STARTINGTICKETS;
};

class Param_GM_SafeStartDuration {
	title = "Safe-start duration (in seconds):";
	values[] = { 5, 10, 20, 30, 60, 120, 180, 300, 99999 };
	default = MACRO_GM_SAFESTARTDURATION;
};

class Param_GM_Unit_RespawnDelay {
	title = "Respawn delay (in seconds):";
	values[] = { 5, 10, 15, 20, 30, 45, 60, 90, 120 };
	default = MACRO_GM_UNIT_RESPAWNDELAY;
};

class Param_GM_Unit_ReviveDuration {
	title = "Revive duration (in seconds):";
	values[] = { 5, 10, 15, 20, 30, 45, 60, 90, 120, 180, 240, 300, 600 };
	default = MACRO_GM_UNIT_REVIVEDURATION;
};

class Param_GM_Unit_SpawnProtectionDuration {
	title = "Spawn protection duration (in seconds):";
	values[] = { 0, 1, 2, 3, 4, 5 };
	default = MACRO_GM_UNIT_SPAWNPROTECTIONDURATION;
};

class Param_GM_Sector_CaptureDuration {
	title = "Sector capture duration (in seconds):";
	values[] = { 5, 10, 15, 20, 25, 30, 45, 60, 90, 120 };
	default = MACRO_GM_SECTOR_CAPTUREDURATION;
};

class Param_CA_DelayUntilDeath {
	title = "Combat area delay until death (in seconds):";
	values[] = { 3, 5, 10, 15, 20 };
	default = MACRO_CA_DELAYUNTILDEATH;
};
