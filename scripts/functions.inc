class MACRO_PROJECT_PREFIX {

	class acre {
		file = "scripts\acre";

		class acre_customSignalFunc {};
		class acre_sys_assignChannels {};
		class acre_sys_handleRadios {};
	};

	class actions {
		file = "scripts\actions";
		// Abbreviation:	act

		class act_registerKeybindings {};
		class act_toggleSpawnMenu {};
		class act_toggleScoreBoard {};
		class act_spotTarget {};
		class act_tryHealUnit {};
		class act_tryResupplyUnit {};
	};

	class ai {
		file = "scripts\ai";
		// Abbreviation:	ai

		class ai_forfeitVehicleClaim {};
		class ai_generateIdentities {};
		class ai_getFaces {};
		class ai_getSpeakers {};
		class ai_increaseDangerLevel {};
		class ai_requestVehicleClaim {};
		class ai_processVehicleClaim {};
		class ai_sys_commander {};
		class ai_sys_driverControl {};
		class ai_sys_groupKnowledge {};
		class ai_sys_handleRespawn {};
		class ai_sys_unitControl {};
		class ai_toggleFeature {};
	};

	class animations {
		file = "scripts\animations";
		// Abbreviation:	anim

		class anim_dodge {};
		class anim_gesturePoint {};
		class anim_unconscious {};
	};

	class cba {
		file = "scripts\cba";

		class cba_addKeybindExtended {};
		class cba_getKeybindStr {};
		class cba_initDisplay {};
	};

	class combatArea {
		file = "scripts\combatArea";
		// Abbreviation:	ca

		class ca_getValidPos {};
		class ca_isInCombatArea {};
		class ca_setupCombatAreas {};
		class ca_sys_playerCombatArea {};
	};

	class factions {
		file = "scripts\factions";
		// Abbreviation:	fac

		class fac_getFilePath {};
		class fac_getData {};
	};

	class gameMode {
		file = "scripts\gameMode";
		// Abbreviation:	gm

		class gm_addScore {};
		class gm_compileParams {};
		class gm_compileFactions {};
		class gm_endMission {};
		class gm_getFlagTexture {};
		class gm_getSideName {};
		class gm_getSideTickets {};
		class gm_getTicketBleed {};
		class gm_handleSafeStart {};
		class gm_isSidePlayable {};
		class gm_onSafeStartChanged {};
		class gm_playRadioMsg {};
		class gm_playSoundset {};
		class gm_postInit {
			postInit = 1;
		};
		class gm_processUnitDamage {};
		class gm_processVehicleDamage {};
		class gm_requestPlayerSpawn {};
		class gm_spawnPlayer {};
		class gm_spotTargetLocal {};
		class gm_sys_endConditions {};
		class gm_sys_enforceFPVInCamera {};
		class gm_sys_handleCurator {};
		class gm_sys_handleEntityDeaths {};
		class gm_sys_handlePlayerRespawn {};
		class gm_sys_handleServerStats {};
		class gm_sys_handleWeaponRecoil {};
		class gm_sys_monitorEntityDamage {};
		class gm_sys_removeCorpses {};
		class gm_sys_tickets {};
		class gm_sys_tutorialHints {};
		class gm_sys_updatePlayerVars {};
	};

	class loadouts {
		file = "scripts\loadouts";
		// Abbreviation:	lo

		class lo_addOverallAmmo {};
		class lo_getAllHitPointsArmour {};
		class lo_getOverallAmmo {};
		class lo_setRoleLoadout {};
		class lo_updateOverallAmmo {};
	};

	class math {
		file = "scripts\math";
		// Abbreviation:	math

		class math_boundingBox2D {};
		class math_dot2D {};
		class math_lineIntersect2D {};
		class math_parseBitFlag {};
		class math_randomPosOnCircle {};
		class math_raySphereIntersection {};
	};

	class nodeMesh {
		file = "scripts\nodeMesh";
		// Abbreviation:	nm

		class nm_checkOcclusion {};
		class nm_findPath {};
		class nm_getBestSegmentCost {};
		class nm_getRawCost {};
		class nm_setupNode {};
		class nm_setupNodeMesh {};
		class nm_sys_dangerLevel {};
	};

	class projectiles {
		file = "scripts\projectiles";
		// Abbreviation:	proj

		class proj_getDamageData {};
		class proj_onInit {};
	};

	class sectors {
		file = "scripts\sectors";

		class sector_addVehicleSpawn {};
		class sector_handleServer {};
		class sector_sys_handleClient {};
	};

	class ui {
		file = "scripts\ui";
		// Abbreviation:	ui

		class ui_blackScreen {};
		class ui_disableUserInput {};
		class ui_drawCombatArea_map {};
		class ui_drawCombatArea_gps {};
		class ui_drawIcons2D {};
		class ui_drawSectorFlags {};
		class ui_drawSectorLocations {};
		class ui_drawSpawnSector {};
		class ui_focusMap {};
		class ui_focusMapOnArea {};
		class ui_getAbilityDescription {};
		class ui_getAbilityIcon {};
		class ui_getFillBarIcon {};
		class ui_getVehicleIcon {};
		class ui_getVehiclePicture {};
		class ui_handleGPSScale {};
		class ui_hookUnitInfoCtrls {};
		class ui_processKillFeedEvent {};
		class ui_processScoreEvent {};
		class ui_processUnitStats {};
		class ui_scoreBoard {};
		class ui_setupPPEffects {};
		class ui_spawnMenu {};
		class ui_sys_drawHealthBar {};
		class ui_sys_drawHitMarkers {};
		class ui_sys_drawIcons3D {};
		class ui_sys_drawKillFeed {};
		class ui_sys_drawMedicalEffects {};
		class ui_sys_drawScoreFeed {};
		class ui_sys_drawSectorHUD {};
		class ui_sys_drawTutorialHints {};
		class ui_sys_hookMapCtrls {};
	};

	class units {
		file = "scripts\units";
		// Abbreviation:	unit

		class unit_disableInventory {};
		class unit_getUID {};
		class unit_getVehicleRole {};
		class unit_isAlive {};
		class unit_isReloading {};
		class unit_onConsciousnessChanged {};
		class unit_onFired {};
		class unit_onHandleDamage {};
		class unit_onHealUnit {};
		class unit_onInit {};
		class unit_onHitPart {};
		class unit_onKilled {};
		class unit_onReloaded {};
		class unit_onResupplyUnit {};
		class unit_playSound {};
		class unit_processDamageEvent {};
		class unit_selectBestWeapon {};
		class unit_setIdentityLocal {};
		class unit_setResupplyCooldown {};
		class unit_setUnconscious {};
	};

	class vehicles {
		file = "scripts\vehicles";
		// Abbreviation:	veh

		class veh_calculateHealth {};
		class veh_getAvoidanceForce {};
		class veh_getNextDefinition {};
		class veh_getRoles {};
		class veh_getUnitByRole {};
		class veh_isClaimable {};
		class veh_isOperable {};
		class veh_onHandleDamage {};
		class veh_onInit {};
		class veh_setCustomisation {};
	};
};
