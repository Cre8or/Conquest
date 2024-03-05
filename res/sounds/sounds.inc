class GVAR(HitMarker) : GVAR(Default) {
	sound[] = {"res\sounds\hitMarker.ogg", db+5, 1};
};

class GVAR(EnemyKilled) : GVAR(Default) {
	sound[] = {"@a3\3DEN\Data\Sound\CfgSound\notificationDefault.wss", db+5, 1};
};

class GVAR(FriendlyKilled) : GVAR(Default) {
	sound[] = {"@a3\3DEN\Data\Sound\CfgSound\notificationWarning.wss", db+5, 1};
};

class GVAR(TicketsLow_Siren) : GVAR(Default) {
	sound[] = {"@a3\data_f_curator\sound\cfgsounds\air_raid", db+5, 1};
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
