// Shared component (postInit)
diag_log "[CONQUEST] Shared post-initialisation starting...";





// Set up some variables
GVAR(nm_isSetup) = false;





// Prepare data
call FUNC(lo_compileLoadouts);

call FUNC(nm_setupNodeMesh);

// Start the systems
call FUNC(ai_sys_commander);
call FUNC(ai_sys_driverControl);
call FUNC(ai_sys_groupKnowledge);
call FUNC(ai_sys_handleRespawn);
call FUNC(ai_sys_unitControl);

call FUNC(gm_sys_monitorUnitDamage);

call FUNC(nm_sys_dangerLevel);





diag_log "[CONQUEST] Shared post-initialisation done.";
