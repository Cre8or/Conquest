/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LA][GE]
		Callback function for when a medic has healed (or revived) a local unit.

		Revival of unconscious units requires the local machine's confirmation, as the bleedout timer is handled
		locally too (and time is a difficult thing to synchronise in multiplayer).
	Arguments:
		0:	<OBJECT>	The medic unit
		1:	<OBJECT>	The patient that was healed
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_medic", objNull, [objNull]],
	["_patient", objNull, [objNull]]
];

if (isNull _medic or {!local _patient}) exitWith {};





// Set up some variables
private _time      = time;
private _healthOld = _patient getVariable [QGVAR(health), 0];

if (_healthOld >= 1) exitWith {};





// Try reviving the patient
if (_patient getVariable [QGVAR(isUnconscious), false]) then {
	[_patient, false] call FUNC(unit_setUnconscious);

	// Reward the medic for reviving
	[_medic, MACRO_ENUM_SCORE_REVIVE, _patient] remoteExecCall [QFUNC(gm_addScore), 2, false];

} else {
	// Heal the patient
	private _healthNew = _healthOld + MACRO_ACT_HEALUNIT_AMOUNT min 1;

	_patient setVariable [QGVAR(health), _healthNew, true];

	// Reward the medic for healing
	if (_medic != _patient) then {
		[_medic, MACRO_ENUM_SCORE_HEAL, _healthNew - _healthOld] remoteExecCall [QFUNC(gm_addScore), 2, false];
	};
};

// Interface with ai_sys_unitControl to make the unit stay put while being healed
_patient setVariable [QGVAR(ai_unitControl_handleMedical_stopTime), _time + MACRO_AI_MEDICAL_PATIENT_STOPDURATIONPERHEAL, false];
