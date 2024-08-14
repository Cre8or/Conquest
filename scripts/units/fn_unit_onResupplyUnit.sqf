/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LA][GE]
		Callback function for when a support unit has resupplied a local unit.
		Handles the actual resupplying of the recipient.
	Arguments:
		0:	<OBJECT>	The support unit
		1:	<OBJECT>	The recipient unit that was resupplied
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_support", objNull, [objNull]],
	["_recipient", objNull, [objNull]]
];

if (isNull _support or {!local _recipient}) exitWith {};





// Set up some variables
private _time = time;
private _ammo = [_recipient] call FUNC(lo_getOverallAmmo);

if (_ammo >= 1) exitWith {};





// Resupply the recipient
private _diff = MACRO_ACT_RESUPPLYUNIT_AMOUNT min (1 - _ammo);

[_recipient, _diff] call FUNC(lo_addOverallAmmo);

// Reward the support unit for resupplying
if (_support != _recipient) then {
	[_support, MACRO_ENUM_SCORE_RESUPPLY, _diff] remoteExecCall [QFUNC(gm_addScore), 2, false];
};

// Interface with ai_sys_unitControl to make the unit stay put while being resupplied
_recipient setVariable [QGVAR(ai_unitControl_handleResupply_stopTime), _time + MACRO_AI_ROLEACTION_RECIPIENT_STOPDURATION, false];
