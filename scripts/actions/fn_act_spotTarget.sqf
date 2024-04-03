/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GE]
		Attempts to spot a target in the direction the player is looking.
		If a target is successfully spotted, this function calls gm_spotTargetLocal globally. This will ensure
		that every machine uses its local time for the spotting duration.

		Only executed on the client.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

private _player = player;

if (!hasInterface or {!alive _player}) exitWith {true};





// Set up some variables
MACRO_FNC_INITVAR(GVAR(spotTarget_cost),-MACRO_ACT_SPOTTING_COOLDOWNDURATION);
MACRO_FNC_INITVAR(GVAR(spotTarget_cooldown),false);

private _time = time;

// Enforce cooldown
if (GVAR(spotTarget_cooldown) and {_time < GVAR(spotTarget_cost) + MACRO_ACT_SPOTTING_COOLDOWNDURATION}) exitWith {true};





private _newCost = (GVAR(spotTarget_cost) max (_time - MACRO_ACT_SPOTTING_COOLDOWNDURATION)) + MACRO_ACT_SPOTTING_COSTPERUSE;

// Enter cooldown
if (_newCost > _time) exitWith {
	GVAR(spotTarget_cost) = _time;
	GVAR(spotTarget_cooldown) = true;

	playSoundUI ["addItemFailed", 0.75, 1];
	true;
};

// Increase the cost
GVAR(spotTarget_cooldown) = false;
GVAR(spotTarget_cost) = _newCost;





// Set up some variables
private _posStart = ATLtoASL positionCameraToWorld [0,0,0];
private _dir = _posStart vectorFromTo ATLtoASL positionCameraToWorld [0,0,1];
private _posEnd = _posStart vectorAdd (_dir vectorMultiply viewDistance);

private _target = objNull;
private _targetFallback = objNull;
private _bestAngle = (0.1 * (0.75 min getObjectFOV cameraOn)) ^ 2;	// Minimum angle within which targets can be spotted
private _spottedTimeVarName = format [QGVAR(spottedTime_%1), GVAR(side)];
private _vehPly = vehicle _player;
private _cursorTarget = cursorTarget;

// Occasionally, cursorTarget returns objects that are fully occluded, so we have to ensure that they are actually visible
private "_visibility";
if (!isNull _cursorTarget) then {
	_visibility = [_vehPly, "VIEW", _cursorTarget] checkVisibility [_posStart, ATLtoASL unitAimPositionVisual _cursorTarget];

	if (_visibility < MACRO_ACT_SPOTTING_MINVISIBILITY) then {
		_cursorTarget = objNull;
	};
};

// If the cursorTarget command failed (target knowledge requirement not fulfilled), or its value was discarded, perform a raycast instead
if (isNull _cursorTarget) then {
	_cursorTarget = lineIntersectsSurfaces [_posStart, _posEnd, _vehPly, objNull, true, 1, "VIEW"] param [0, []] param [2, objNull];
};





// Look for a spottable enemy within the search cone
private ["_vehX", "_posX", "_angle", "_crew", "_candidate"];
{
	_vehX = vehicle _x;
	_posX = ATLtoASL unitAimPositionVisual _x;
	_visibility = [_vehPly, "VIEW", _vehX] checkVisibility [_posStart, _posX];
	_angle = (_posStart vectorFromTo _posX) distanceSqr _dir;

	if (_visibility >= MACRO_ACT_SPOTTING_MINVISIBILITY and {_angle < _bestAngle}) then {
		_bestAngle = _angle;
		_target = _x;
	} else {
		if (_cursorTarget == _vehX) then {

			// It's a unit (on foot)
			if (_x == _vehX) then {
				_targetFallback = _x;

			// It's a vehicle; fetch the first valid crew unit
			} else {
				_crew = crew _vehX;
				_targetFallback = _crew param [_crew findIf {
					alive _x
					and {GVAR(side) != _x getVariable [QGVAR(side), GVAR(side)]}
					and {_time > _x getVariable [_spottedTimeVarName, 0]}
				}, objNull];
			};
		};
	};
} forEach (allUnits select {
	[_x] call FUNC(unit_isAlive)
	and {GVAR(side) != _x getVariable [QGVAR(side), GVAR(side)]}
	and {_time > _x getVariable [_spottedTimeVarName, 0]}
});

// If no enemies are within the search cone, check the fallback target (usually the cursorTarget)
if (
	!([_target] call FUNC(unit_isAlive))
	and {[_targetFallback] call FUNC(unit_isAlive)}
	and {GVAR(side) != _targetFallback getVariable [QGVAR(side), GVAR(side)]}
	and {_time > _targetFallback getVariable [_spottedTimeVarName, 0]}
) then {
	_target = _targetFallback;
};





// If we found a valid target, spot it
if (!isNull _target) then {
	[_player, _target] remoteExecCall [QFUNC(gm_spotTargetLocal), 0, false];

	playSoundUI ["TacticalPing4", 1, 1];

	[_player] call FUNC(anim_gesturePoint);

} else {
	playSoundUI ["WeaponRestedOn", 2.5, 1];
};





true;
