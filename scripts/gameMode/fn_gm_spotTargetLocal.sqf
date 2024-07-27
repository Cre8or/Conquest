/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA][LE]
		Flags the given object as being spotted for the side of the reporting unit's side.
	Arguments:
		0:	<OBJECT>	The reporting unit that spotted the object
		1:	<OBJECT>	The object that was spotted
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"

params [
	["_spotter", objNull, [objNull]],
	["_target", objNull, [objNull]]
];

private _side = _spotter getVariable [QGVAR(side), sideEmpty];

if (!([_target] call FUNC(unit_isAlive)) or {_side == sideEmpty} or {GVAR(side) != _side and {!isServer}}) exitWith {};





// Spot the target
_target setVariable [format [QGVAR(spottedTime_%1), _side], time + MACRO_ACT_SPOTTING_DURATION, false];

if (hasInterface) then {
	{
		_x reveal [_target, 0.1];
	} forEach (allGroups select {local _x});
};

// Save the spotter onto the object (required for spot assists)
if (isServer) then {
	_target setVariable [format [QGVAR(spotter_%1), _side], _spotter, false];
};
