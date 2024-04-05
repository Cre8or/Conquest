/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[S][GA][GE]
		Callback function for when a medic has healed another unit.

		Only executed on the server.
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

if (isNull _medic or {isNull _patient}) exitWith {};





// (DEBUG) Heal the unit
private _healthOld = _patient getVariable [QGVAR(health), 0];
private _healthNew = _healthOld + MACRO_ACT_HEALUNIT_AMOUNT min 1;

_patient setVariable [QGVAR(health), _healthNew, true];

// Reward the medic
if (_medic != _patient) then {
	[_medic, MACRO_ENUM_SCORE_HEAL, _healthNew - _healthOld] call FUNC(gm_addScore);
};
