/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA][LE]
		Callback function for when a unit becomes unconscious, or is revived.
		Called remotely by unit_setUnconscious.
	Arguments:
		0:	<OBJECT>	The concerned unit
		1:	<BOOLEAN>	Whether the unit is unconscious or not (optional, default: true)
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

if (!alive _unit) exitWith {};





// Handle the unit's state
_unit setVariable [QGVAR(isUnconscious), _newState, false];

// Remember the bleedout time
private _time = time;
if (_reviveDuration < 0) then {
	_reviveDuration = MACRO_GM_UNIT_REVIVEDURATION;
};

_unit setVariable [QGVAR(bleedoutTime), [-1, _time + _reviveDuration] select _newState, false];



if (_newState) then {
	_unit setVariable [QGVAR(health), 0, false];

	[_unit, MACRO_ENUM_SOUND_VO_DEATH] call FUNC(unit_playSound);

	if (!isPlayer _unit) then {
		// Interface with unitControl to allow the unit to give up and bleed out
		_unit setVariable [QGVAR(ai_unitControl_unconsciousState_respawnTime), _time + GVAR(param_gm_unit_respawnDelay), false];

		// Interface with subSys_handleMedical to prevent revive spam
		_unit setVariable [QGVAR(ai_unitControl_handleMedical_reviveTime), _time + MACRO_AI_MEDICAL_INITIALREVIVEDELAY, false];

		// Prevent AI units from talking
		_unit setSpeaker "NoVoice";

		// Special case: the server is in charge of respawning units, and uses additional variables.
		if (isServer) then {
			private _unitIndex = _unit getVariable [QGVAR(unitIndex), -1];

			if (_unitIndex >= 0 and {_unitIndex < GVAR(param_ai_maxCount)}) then {
				GVAR(ai_sys_handleRespawn_respawnTimes) set [_unitIndex, _time + GVAR(param_gm_unit_respawnDelay)];
			};
		};
	};

} else {
	// Reset the unit's health to the lowest amount that can be given by a medic
	_unit setVariable [QGVAR(health), MACRO_ACT_HEALUNIT_AMOUNT, false];

	[_unit, MACRO_ENUM_SOUND_VO_REVIVE] call FUNC(unit_playSound);

	// Allow AI units to talk again
	if (!isPlayer _unit) then {
		_unit setSpeaker (_unit getVariable [QGVAR(ai_speaker), ""]);
	};

	// Interface with ai_sys_unitControl to make the unit stay put while being healed
	_unit setVariable [QGVAR(ai_unitControl_handleMedical_stopTime), _time + MACRO_AI_ROLEACTION_RECIPIENT_STOPDURATION, false];
};
