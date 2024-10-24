#define MACRO_COND_ISVALIDGROUP(THISGROUP) \
 \
	(THISGROUP getVariable [QGVAR(isValid), false] or {{isPlayer _x} count units THISGROUP > 1})
