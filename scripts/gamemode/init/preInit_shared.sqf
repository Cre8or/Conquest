// Shared component (preInit)
diag_log "[CONQUEST] Shared pre-initialisation starting...";





// Detect loaded mods
private _configMods = configFile >> "CfgPatches";

GVAR(hasMod_ace_finger)   = isClass (_configMods >> "ace_finger");
GVAR(hasMod_ace_throwing) = isClass (_configMods >> "ace_advanced_throwing");





// Compile the mission parameters
call FUNC(gm_compileParams);

call FUNC(ca_setupCombatAreas);





diag_log "[CONQUEST] Shared pre-initialisation done.";
