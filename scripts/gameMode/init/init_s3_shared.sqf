// Shared component (stage 3)
diag_log "[CONQUEST] Shared initialisation (stage 3) starting...";





MACRO_FNC_INITVAR(GVAR(proj_onInit_EH), -1);





// Prepare data
call FUNC(nm_setupNodeMesh);

// Start the shared systems
call FUNC(ai_sys_commander);
call FUNC(ai_sys_driverControl);
call FUNC(ai_sys_groupKnowledge);
call FUNC(ai_sys_unitControl);

call FUNC(gm_sys_monitorEntityDamage);

call FUNC(nm_sys_dangerLevel);


// Detect projectile firing (irrespective of locality/distance to camera)
removeMissionEventHandler ["ProjectileCreated", GVAR(proj_onInit_EH)];
GVAR(proj_onInit_EH) = addMissionEventHandler ["ProjectileCreated", {
	_this call FUNC(proj_onInit);
}];





diag_log "[CONQUEST] Shared initialisation (stage 3) done.";
