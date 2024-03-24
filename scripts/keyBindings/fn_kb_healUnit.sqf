/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GE]
		Attempts to heal a friendly unit in the direction the player is looking.

		Only executed on the client.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

private _player = player;

if (!hasInterface or {!alive _player} or {GVAR(role) != MACRO_ENUM_ROLE_MEDIC}) exitWith {true};





// Set up some variables
MACRO_FNC_INITVAR(GVAR(kb_healUnit_cooldown), 0);

private _time = time;

// Enforce the cooldown
if (_time < GVAR(kb_healUnit_cooldown)) exitWith {true};

// Define some macros
#define MACRO_HEALUNIT_MAXDISTANCESQR 4





// Look for candidate units to heal
private _candidates = allUnits select {
	_x distanceSqr _player <= MACRO_HEALUNIT_MAXDISTANCESQR
	and {(_x getVariable [QGVAR(side), sideEmpty]) == GVAR(side)}
	and {_x == vehicle _x} // Ignore units inside vehicles
	and {(_x getVariable [QGVAR(health), 1]) < 1}
	and {[_x, true] call FUNC(unit_isAlive)} // Include unconscious units in the test
};

if (_candidates isEqualTo []) exitWith {true};

// Sort the candidates by score (alignment with the player's eye direction)
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
private _target = (_candidatesSorted param [0, []]) param [1, objNull];

// Validate the target
if (isNull _target) exitWith {true};





systemChat format ["(%1) Healing: %2", _time, name _target];

_player playGesture "GestureEmpty";
_player playGesture "GestureGoStandPistol"; // "GestureGoStand"





true;
