class GVAR(HitMarker) : GVAR(Default) {
	sound[] = {"res\sounds\hitMarker.ogg", db+5, 1};
};

class GVAR(EnemyKilled) : GVAR(Default) {
	sound[] = {"@a3\3DEN\Data\Sound\CfgSound\notificationDefault.wss", db+5, 1};
};

class GVAR(FriendlyKilled) : GVAR(Default) {
	sound[] = {"@a3\3DEN\Data\Sound\CfgSound\notificationWarning.wss", db+5, 1};
};

class GVAR(SideDefeated) : GVAR(Default) {
	sound[] = {"@a3\missions_f_beta\data\sounds\firing_drills\drill_finish.wss", db+5, 1};
};

class GVAR(TicketsLow_Siren) : GVAR(Default) {
	sound[] = {"@a3\data_f_curator\sound\cfgsounds\air_raid", db+5, 1};
};

class GVAR(Headshot) : GVAR(Default) {
	sound[] = {"res\sounds\headshot.ogg", db+10, 1};
};





class GVAR(BulletHit_1) : GVAR(Default) {
	sound[] = {"res\sounds\hit_1.ogg", db+5, 1};
};

class GVAR(BulletHit_2) : GVAR(Default) {
	sound[] = {"res\sounds\hit_2.ogg", db+5, 1};
};

class GVAR(BulletHit_3) : GVAR(Default) {
	sound[] = {"res\sounds\hit_3.ogg", db+5, 1};
};





class GVAR(Unit_Resupply_1) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\weapons\Closure\sfx9.wss", db+8, 1};
};

class GVAR(Unit_Resupply_2) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\weapons\Closure\Mk200_closure_1.wss", db+5, 1};
};





class GVAR(Unit_Heal_1) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Other\firstaid_01.wss", db+0, 1.2}; // offset 2.5
};

class GVAR(Unit_Heal_2) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Other\firstaid_02.wss", db+2, 1}; // offset 4.15
};

class GVAR(Unit_Heal_3) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Other\firstaid_03.wss", db+12, 1}; // offset 4.8
};

class GVAR(Unit_Heal_4) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Other\firstaid_04.wss", db+4, 1}; // offset 3.1
};

class GVAR(Unit_Heal_5) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Other\firstaid_06.wss", db+2, 1.2}; // offset 3.6
};

class GVAR(Unit_Heal_6) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\ingame\AinvPknlMstpSlayWpstDnon_medicIn.wss", db+2, 1};
};

class GVAR(Unit_Heal_7) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\ingame\AinvPknlMstpSlayWpstDnon_medicOut.wss", db+2, 1};
};

class GVAR(Unit_Heal_8) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\ingame\AinvPpneMstpSlayWpstDnon_medicIn.wss", db+2, 1};
};

class GVAR(Unit_Heal_9) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\ingame\AinvPpneMstpSlayWpstDnon_medicout.wss", db+2, 1};
};





class GVAR(Unit_VO_Revive_1) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Person0\P0_choke_01.wss", db+0, 1};
};

class GVAR(Unit_VO_Revive_2) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Person0\P0_choke_02.wss", db+0, 1};
};

class GVAR(Unit_VO_Revive_3) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Person0\P0_choke_03.wss", db+0, 1};
};

class GVAR(Unit_VO_Revive_4) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Person0\P0_choke_04.wss", db+0, 1};
};

class GVAR(Unit_VO_Revive_5) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Person1\P1_choke_01.wss", db+0, 1};
};

class GVAR(Unit_VO_Revive_6) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Person1\P1_choke_02.wss", db+0, 1};
};

class GVAR(Unit_VO_Revive_7) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Person1\P1_choke_03.wss", db+0, 1};
};

class GVAR(Unit_VO_Revive_8) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Person1\P1_choke_04.wss", db+0, 1};
};

class GVAR(Unit_VO_Revive_9) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Person3\P3_choke_03.wss", db+0, 1};
};

class GVAR(Unit_VO_Revive_10) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Person3\P3_choke_04.wss", db+0, 1};
};





class GVAR(Unit_VO_Death_1) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Person0\P0_hit_01.wss", db+12, 1};
};

class GVAR(Unit_VO_Death_2) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Person0\P0_hit_02.wss", db+12, 1};
};

class GVAR(Unit_VO_Death_3) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Person0\P0_hit_04.wss", db+12, 1};
};

class GVAR(Unit_VO_Death_4) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Person0\P0_hit_08.wss", db+12, 1};
};

class GVAR(Unit_VO_Death_5) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Person0\P0_hit_11.wss", db+12, 1};
};

class GVAR(Unit_VO_Death_6) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Person0\P0_hit_12.wss", db+12, 1};
};

class GVAR(Unit_VO_Death_7) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Person1\P1_hit_02.wss", db+12, 1};
};

class GVAR(Unit_VO_Death_8) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Person1\P1_hit_07.wss", db+12, 1};
};

class GVAR(Unit_VO_Death_9) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Person1\P1_hit_09.wss", db+12, 1};
};

class GVAR(Unit_VO_Death_10) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Person1\P1_hit_10.wss", db+12, 1};
};

class GVAR(Unit_VO_Death_11) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Person2\P2_hit_01.wss", db+12, 1};
};

class GVAR(Unit_VO_Death_12) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Person2\P2_hit_05.wss", db+12, 1};
};

class GVAR(Unit_VO_Death_13) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Person2\P2_hit_07.wss", db+12, 1};
};

class GVAR(Unit_VO_Death_14) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Person3\P3_hit_01.wss", db+12, 1};
};

class GVAR(Unit_VO_Death_15) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Person3\P3_hit_03.wss", db+12, 1};
};

class GVAR(Unit_VO_Death_16) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Person3\P3_hit_11.wss", db+12, 1};
};

class GVAR(Unit_VO_Death_17) : GVAR(Default) {
	sound[] = {"@a3\sounds_f\characters\human-sfx\Person3\P3_hit_12.wss", db+12, 1};
};
