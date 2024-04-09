// Starts at 1 and quickly drops to 0
#define MACRO_TWEEN_RAMPDOWN(CURTIME, ENDTIME, ANIMDURATION) \
	(((ENDTIME - CURTIME) / ANIMDURATION) max 0) ^ 3
