/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LA][GE]
		Makes a medic unit attempt to heal a friendly unit.

		If a target unit is passed, the medic will attempt to heal that unit. Otherwise, the function attempts
		to determine a candidate unit from the medic's viewing direction.
	Arguments:
		0:	<OBJECT>	The medic unit
		1:	<OBJECT>	The intended patient unit (optional, default: objNull)
	Returns:
		0:	<BOOLEAN>	Whether or not the healing attempt was successful
		1:	<OBJECT>	The patient that was healed
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_medic", objNull, [objNull]],
	["_target", objNull, [objNull]]
];

// Only local, alive medics may heal units, and only while on ground
if (!local _medic or {!isTouchingGround _medic} or {_medic getVariable [QGVAR(role), MACRO_ENUM_ROLE_INVALID] != MACRO_ENUM_ROLE_MEDIC} or {!([_medic] call FUNC(unit_isAlive))}) exitWith {
	[false, objNull]
};





// Set up some variables
private _time     = time;
private _cooldown = _medic getVariable [QGVAR(act_tryHealUnit_cooldown), -1];





// Enforce the cooldown
if (_time < _cooldown) exitWith {[false, objNull]};

_medic setVariable [QGVAR(act_tryHealUnit_cooldown), _time + MACRO_ACT_HEALUNIT_COOLDOWN, false];





// First filter: ensure candidate units are on the same side and need healing
private _medicSide  = _medic getVariable [QGVAR(side), sideEmpty];
private _candidates = [[_target], allUnits] select (isNull _target);
_candidates = _candidates select {
	_x distanceSqr _medic <= MACRO_ACT_HEALUNIT_MAXDISTANCESQR
	and {(_x getVariable [QGVAR(side), sideEmpty]) == _medicSide}
	and {[_x] call FUNC(unit_needsHealing)}
};

if (_candidates isEqualTo []) exitWith {[false, objNull]};

// If no target was specified, check the candidates
if (isNull _target) then {

	// Sort the candidates by score (alignment with the medic's eye direction)
	private _posStart = AGLtoASL positionCameraToWorld [0,0,0];
	private _dir      = _posStart vectorFromTo AGLtoASL positionCameraToWorld [0,0,1];
	private _posEnd   = _posStart vectorAdd (_dir vectorMultiply viewDistance);

	private _candidatesSorted = [];
	private ["_posX", "_angle"];
	{
		_posX  = AGLtoASL unitAimPositionVisual _x;
		_angle = (_posStart vectorFromTo _posX) distanceSqr _dir;

		if (_angle < 1) then { // Roughly a 45° cone
			_candidatesSorted pushBack [_angle, _x];
		};
	} forEach _candidates;

	_candidatesSorted sort true;
	_target = (_candidatesSorted param [0, []]) param [1, objNull];

	// If no candidate is found, check if the medic needs healing
	if (isNull _target) then {
		if ([_medic] call FUNC(unit_needsHealing)) then {
			_target = _medic;
		};
	};

	// Validate the target
	if (isNull _target) exitWith {[false, objNull]};
};





//systemChat format ["(%1) %2 healing %3", _time, name _medic, name _target];
if (_medic != _target) then {
	_medic playGesture "GestureEmpty";
	_medic playGesture "GestureGoStandPistol"; // "GestureGoStand"
} else {
	_medic action ["TakeWeapon", objNull, "Throw"];
};

// Inform the server about the successful healing action
[_medic, _target] remoteExecCall [QFUNC(unit_onHealUnit), 2, false];

// Return the unit that was healed
[true, _target];
