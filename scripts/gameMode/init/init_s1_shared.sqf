// Shared component (stage 1)
diag_log "[CONQUEST] Shared initialisation (stage 1) starting...";





// Detect loaded mods
private _configMods = configFile >> "CfgPatches";

GVAR(hasMod_ace_finger)   = isClass (_configMods >> "ace_finger");
GVAR(hasMod_ace_medical)  = isClass (_configMods >> "ace_medical_engine");
GVAR(hasMod_ace_throwing) = isClass (_configMods >> "ace_advanced_throwing");





// Compile the mission parameters
call FUNC(gm_compileParams);

call FUNC(gm_compileSidesData);

call FUNC(ca_setupCombatAreas);





diag_log "[CONQUEST] Shared initialisation (stage 1) done.";
