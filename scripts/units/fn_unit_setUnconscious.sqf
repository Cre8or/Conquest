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





// Remember the bleedout time
private _time = time;
if (_reviveDuration < 0) then {
	_reviveDuration = MACRO_GM_UNIT_REVIVEDURATION;
};

_unit setVariable [QGVAR(bleedoutTime), [-1, _time + _reviveDuration] select _newState, false];

// Handle the unit's state
_unit setUnconscious _newState;
_unit setCaptive _newState;
_unit setVariable [QGVAR(isUnconscious), _newState, true];


// Unconscious
if (_newState) then {
	_unit setVariable [QGVAR(health), 0, true];

	// Yank the unit out of their vehicle, if inside one
	moveOut _unit;

	[_unit] call FUNC(anim_unconscious);
	[_unit, MACRO_ENUM_SOUND_VO_DEATH] remoteExecCall [QFUNC(unit_playSound), 0, false];

	// Update the respawn time on AI units
	if (!isPlayer _unit) then {
		[_unit] remoteExecCall [QFUNC(ai_resetRespawnTime), 0, false];
	};

// Revived
} else {
	[_unit, MACRO_ENUM_SOUND_VO_REVIVE] remoteExecCall [QFUNC(unit_playSound), 0, false];

	// Reset the unit's health to the lowest amount that can be given by a medic
	_unit setVariable [QGVAR(health), MACRO_ACT_HEALUNIT_AMOUNT, true];

	// Interface with ai_sys_unitControl to make the unit stay put while being healed
	_unit setVariable [QGVAR(ai_unitControl_handleMedical_stopTime), _time + MACRO_AI_ROLEACTION_RECIPIENT_STOPDURATION, false];

	[_unit, true] call FUNC(unit_selectBestWeapon);
};





if (_unit == player) then {

	//Handle unscoping, whether it's when going unconscious or when waking up
	if (cameraView == "GUNNER") then {
		_unit switchCamera "INTERNAL";
	};

	// Force a respawn state transition check (interface with gm_sys_handlePlayerRespawn)
	if (_newState) then {

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
	}
};
