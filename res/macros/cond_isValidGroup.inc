#define MACRO_COND_ISVALIDGROUP(THISGROUP)													 \
																		 \
	((THISGROUP getVariable [QGVAR(isValid), false] and {side THISGROUP == GVAR(side)}) or {{isPlayer _x} count units THISGROUP > 1})
