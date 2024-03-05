#define MACRO_FNC_BROADCASTONCHANGE(VARNAME,VARNAME_LAST)	 \
								 \
	if (VARNAME isNotEqualTo VARNAME_LAST) then {		 \
		VARNAME_LAST = VARNAME;				 \
		publicVariable QUOTE(VARNAME);			 \
	}
