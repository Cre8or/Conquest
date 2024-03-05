#define MACRO_FNC_SUBMITNEWCALLSIGN(GROUP,CALLSIGN)										 \
																 \
	if (_buffer isEqualTo "") then {											 \
		_spawnMenu setVariable [QGVAR(menuRole_isNamingGroup), false];						 \
																 \
	} else {														 \
		private _bufferLower = toLower CALLSIGN;									 \
																 \
		if ((allGroups select {side _x == GVAR(side)}) findIf {toLower groupID _x isEqualTo _bufferLower} < 0) then {	 \
			GROUP setGroupIDGlobal [CALLSIGN];									 \
			_spawnMenu setVariable [QGVAR(menuRole_isNamingGroup), false];					 \
		} else {													 \
			_spawnMenu setVariable [QGVAR(menuRole_hasNameCollision), true];					 \
		};														 \
	};															 \
