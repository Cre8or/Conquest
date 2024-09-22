/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LE]
		Initialises the CBA event handlers to the specified display.

		Used to allow CBA to detect key/mouse events when a specific display is open (even on the mission display),
		to prevent sticky actions.
	Arguments:
		0:	<DISPLAY>	The display to be initialised
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */


#include "..\..\res\common\macros.inc"

params [
	["_display", displayNull, [displayNull]]
];





_display displayAddEventHandler ["KeyDown",         {_this call cba_events_fnc_keyHandlerDown}];
_display displayAddEventHandler ["KeyUp",           {_this call cba_events_fnc_keyHandlerUp}];
_display displayAddEventHandler ["MouseButtonDown", {_this call cba_events_fnc_mouseHandlerDown}];
_display displayAddEventHandler ["MouseButtonUp",   {_this call cba_events_fnc_mouseHandlerUp}];
_display displayAddEventHandler ["MouseZChanged",   {_this call cba_events_fnc_mouseWheelHandler}];
_display displayAddEventHandler ["MouseMoving",     {_this call cba_events_fnc_userKeyHandler}];
_display displayAddEventHandler ["MouseHolding",    {_this call cba_events_fnc_userKeyHandler}];
