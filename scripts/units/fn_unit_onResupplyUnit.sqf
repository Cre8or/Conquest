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
private _time             = time;
private _oldAmmo          = [_recipient] call FUNC(lo_getOverallAmmo);
private _resupplyCooldown = _recipient getVariable [QGVAR(resupplyCooldown), 0];

if (_oldAmmo >= 1 and {_time < _resupplyCooldown}) exitWith {};





// Resupply the recipient
private _ammoAdded = [_recipient, MACRO_ACT_RESUPPLYUNIT_AMOUNT] call FUNC(lo_addOverallAmmo);
private _newAmmo   = _oldAmmo + _ammoAdded;

// Reward the support unit for resupplying
if (_support != _recipient) then {
	[_support, MACRO_ENUM_SCORE_RESUPPLY, _ammoAdded] remoteExecCall [QFUNC(gm_addScore), 2, false];
};

// Interface with ai_sys_unitControl to make the unit stay put while being resupplied
_recipient setVariable [QGVAR(ai_unitControl_handleResupply_stopTime), _time + MACRO_ACT_RESUPPLYUNIT_COOLDOWN + MACRO_AI_ROLEACTION_RECIPIENT_STOPDURATION, false];

// Enforce a resupply cooldown (to prevent abuse)
if (_newAmmo >= 1) then {
	[_recipient] remoteExecCall [QFUNC(unit_setResupplyCooldown), 0, false];
};
