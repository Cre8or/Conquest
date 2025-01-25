// All tweens are clamped to the range [0, 1].
// Reference:
// https://sole.github.io/tween.js/examples/03_graphs.html





// Starts at 0 and increases to 1 (accelerating) as CURTIME progresses
#define MACRO_TWEEN_CUBIC_IN(STARTTIME, CURTIME, ANIMDURATION) \
	((((CURTIME - STARTTIME) / ANIMDURATION max 0) min 1) ^ 3)

// Starts at 0 and increases to 1 (decelerating) as CURTIME progresses
#define MACRO_TWEEN_CUBIC_OUT(STARTTIME, CURTIME, ANIMDURATION) \
	(((((CURTIME - STARTTIME - ANIMDURATION) / ANIMDURATION) ^ 3 + 1) max 0) min 1)
