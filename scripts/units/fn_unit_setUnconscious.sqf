/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LA][GE]
		Sets the unconscious state on the given unit to desired value. Unconscious units bleed out after a
		certain duration, unless they are revived in time by a friendly medic.
	Arguments:
		0:	<OBJECT>	The concerned unit
		1:	<BOOLEAN>	True to set the unit unconscious, false to wake them up (optional, default: true)
		2:	<NUMBER>	The revive state duration (optional, default: -1)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_unit", objNull, [objNull]],
	["_newState", true, [true]],
	["_reviveDuration", -1, [-1]]
];

if (!local _unit or {_newState == _unit getVariable [QGVAR(isUnconscious), false]}) exitWith {};





// Broadcast to all machines
[_unit, _newState, _reviveDuration] remoteExecCall [QFUNC(unit_onConsciousnessChanged), 0, false];





// Local processing
_unit setUnconscious _newState;
_unit setCaptive _newState;

if (_newState) then {
	moveOut _unit;

	[_unit] call FUNC(anim_unconscious);

} else { // Revived
	[_unit, true] call FUNC(unit_selectBestWeapon);
};



// Edge case: player-specific behaviour
if (_newState and {_unit == player}) then {

	//Handle unscoping, whether it's when going unconscious or when waking up
	if (cameraView == "GUNNER") then {
		_unit switchCamera "INTERNAL";
	};

	// If the player was carrying an object via ACE, drop it
	private _carriedObj = _unit getVariable ["ace_dragging_carriedObject", objNull];
	if (!isNull _carriedObj) then {
		[_unit, _carriedObj] call ace_dragging_fnc_dropObject_carry;
	};

	// Same thing, but with dragged objects (apparently these are separate things)
	private _draggedObj = _unit getVariable ["ace_dragging_draggedObject", objNull];
	if (!isNull _draggedObj) then {
		[_unit, _draggedObj] call ace_dragging_fnc_dropObject;
	};
};
