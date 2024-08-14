/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LA][GE]
		Makes a support unit attempt to resupply a friendly unit.

		If a recipient unit is passed, the support unit will attempt to resupply that unit. Otherwise, the function attempts
		to determine a candidate recipient from the support unit's viewing direction.
	Arguments:
		0:	<OBJECT>	The support unit
		1:	<OBJECT>	The intended recipient unit (optional, default: objNull)
	Returns:
		0:	<BOOLEAN>	Whether or not the resupply attempt was successful
		1:	<OBJECT>	The unit that was resupplied
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_support", objNull, [objNull]],
	["_recipient", objNull, [objNull]]
];

// Preconditions
if (
	!local _support
	or {vehicle _support != _support}
	or {_support getVariable [QGVAR(role), MACRO_ENUM_ROLE_INVALID] != MACRO_ENUM_ROLE_SUPPORT}
	or {[_support] call FUNC(unit_isReloading)}
	or {!([_support] call FUNC(unit_isAlive))}
	or {!isTouchingGround _support}
) exitWith {
	[false, objNull]
};





// Set up some constants
private _c_maxActionDistSqr = MACRO_ACT_RESUPPLYUNIT_MAXDISTANCE ^ 2;

// Set up some variables
private _time     = time;
private _cooldown = _support getVariable [QGVAR(act_tryResupplyUnit_cooldown), -1];





// Enforce the cooldown
if (_time < _cooldown) exitWith {[false, objNull]};

_support setVariable [QGVAR(act_tryResupplyUnit_cooldown), _time + MACRO_ACT_RESUPPLYUNIT_COOLDOWN, false];





// First filter: ensure candidate units are on the same side and need resupplying
private _supportSide  = _support getVariable [QGVAR(side), sideEmpty];
private _candidates = [[_recipient], allUnits] select (isNull _recipient);
_candidates = _candidates select {
	_x distanceSqr _support <= _c_maxActionDistSqr
	and {_x == vehicle _x}
	and {_x getVariable [QGVAR(isSpawned), false]}
	and {(_x getVariable [QGVAR(side), sideEmpty]) == _supportSide}
	and {[_x] call FUNC(lo_getOverallAmmo) < 1}
};

if (_candidates isEqualTo []) exitWith {[false, objNull]};

// If no recipient was specified, check the candidates
if (isNull _recipient) then {

	// Sort the candidates by score (alignment with the support unit's eye direction)
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
	_recipient = (_candidatesSorted param [0, []]) param [1, objNull];

	// If no candidate is found, check if the support unit needs resupplying
	if (
		isNull _recipient
		and {_support == vehicle _support}
		and {[_support] call FUNC(lo_getOverallAmmo) < 1}
	) then {
		_recipient = _support;
	};

	// Validate the recipient
	if (isNull _recipient) exitWith {[false, objNull]};
};





systemChat format ["(%1) %2 resupplying %3", _time, name _support, name _recipient];
if (
	_support != _recipient
	and {stance _support != "PRONE"}
) then {
	_support playActionNow "GestureEmpty";
	_support playActionNow "GestureGo";
} else {
	_support action ["TakeWeapon", objNull, "Throw"];
};

// Special behaviour for AI: face the patient
if (!isPlayer _support) then {
	_support doWatch _recipient;
};

// Inform the server about the successful resupply action
[_support, _recipient] remoteExecCall [QFUNC(unit_onResupplyUnit), _recipient, false];

// Return the unit that was resupplied
[true, _recipient];
