/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LE]
		When enabled, this function hides the screen under a fully black overlay. Also used to remove said
		overlay.
		If a duration if specified, the overlay will take that long to fade in/out. Otherwise, the transition
		is instant.
	Arguments:
		0:	<BOOLEAN>	Whether or not the screen should be blackened
		1:	<NUMBER>	The duration, in seconds, over which the screen will be faded in/out (optional,
					default: 0)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_enabled", true, [true]],
	["_duration", 0, [0]]
];

if (!hasInterface) exitWith {};





// Fade the screen
if (_enabled) then {
	if (_duration > 0) then {
		QGVAR(ui_blackScreen) cutRsc [QGVAR(RscBlackScreenIn), "PLAIN", _duration, true];
	} else {
		QGVAR(ui_blackScreen) cutRsc ["Default", "BLACK", 0, true];
	};

} else {

	if (_duration > 0) then {
		QGVAR(ui_blackScreen) cutRsc [QGVAR(RscBlackScreenOut), "PLAIN", _duration, true];
	} else {
		QGVAR(ui_blackScreen) cutRsc ["Default", "PLAIN", 0, true];
	};
};
