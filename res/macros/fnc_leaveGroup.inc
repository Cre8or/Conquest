#include "cond_isValidGroup.inc"





#define MACRO_FNC_LEAVEGROUP(THISGROUP) \
 \
 	private _newGroup = createGroup GVAR(side); \
	_newGroup deleteGroupWhenEmpty true; \
 \
	[player] joinSilent _newGroup; \
 \
	if ( \
		!MACRO_COND_ISVALIDGROUP(THISGROUP) \
		and THISGROUP getVariable [QGVAR(group_AIIdentities), []] isEqualTo [] \
	) then { \
		THISGROUP setVariable [QGVAR(isValid), false, true]; \
		THISGROUP remoteExecCall ["deleteGroup", 0, false]; \
	}
