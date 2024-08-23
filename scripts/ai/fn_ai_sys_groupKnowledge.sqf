/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles the knowledge of AI groups. Mainly intended to forcefully forget targets that groups are aware
		of for extended periods of time (and are likely to keep the AI stationary, which is bad).

		Only executed once by all machines upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"





// Define some macros
#define MACRO_SYS_GROUPKNOWLEDGE_INTERVAL 5
#define MACRO_AI_MINKNOWLEDGE             0.1

// Set up some variables
MACRO_FNC_INITVAR(GVAR(ai_sys_groupKnowledge_EH), -1);

GVAR(ai_sys_groupKnowledge_nextUpdate) = 0;
GVAR(ai_sys_groupKnowledge_groups)     = [];
GVAR(ai_sys_groupKnowledge_count)      = 0;
GVAR(ai_sys_groupKnowledge_index)      = -1;





removeMissionEventHandler ["EachFrame", GVAR(ai_sys_groupKnowledge_EH)];
GVAR(ai_sys_groupKnowledge_EH) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused or {GVAR(missionState) != MACRO_ENUM_MISSION_LIVE}) exitWith {};

	private _time = time;

	// Update candidate groups
	private ["_group", "_groupUnits", "_canSpotTarget", "_target", "_targetPos", "_spotterUnits", "_spotter"];
	for "_groupIndex" from GVAR(ai_sys_groupKnowledge_index) to 0 step -1 do {

		scopeName QGVAR(ai_sys_groupKnowledge_loop);

		// Exit early if no more groups may be handled this frame (balances the load over multiple frames)
		if (_groupIndex < ((GVAR(ai_sys_groupKnowledge_nextUpdate) - _time) * GVAR(ai_sys_groupKnowledge_count) / MACRO_SYS_GROUPKNOWLEDGE_INTERVAL)) then {
			breakOut QGVAR(ai_sys_groupKnowledge_loop);
		};

		_group = GVAR(ai_sys_groupKnowledge_groups) param [_groupIndex, grpNull];

		if (
			!isNull _group
			and {local _group}
		) then {
			_groupUnits    = units _group select {!isPlayer _x and {[_x] call FUNC(unit_isAlive)}};
			_canSpotTarget = (_groupUnits isNotEqualTo []);

			// Query the group's targets
			{
				_target = _x;

				scopeName QGVAR(ai_sys_groupKnowledge_target);

				if (_group knowsAbout _target >= MACRO_AI_MINKNOWLEDGE) then {

					// Spot the target for other members of this side
					if (
						!_canSpotTarget
						or {!([_target] call FUNC(unit_isAlive))}
					) then {
						breakTo QGVAR(ai_sys_groupKnowledge_target);
					};

					// Only spot one target per group iteration
					_canSpotTarget = false;
					_targetPos     = unitAimPositionVisual _target;

					// Safeguard against invalid values
					if (_targetPos isEqualTo [0,0,0]) then {
						_targetPos = eyePos _target;
					};

					// Pick the unit with the best visibility and view alignment towards the target
					_spotterUnits = _groupUnits apply {[
						([vehicle _x, "VIEW", _target] checkVisibility [eyePos _x, _targetPos])
						* (1 + ((eyeDirection _x) vectorDotProduct (eyePos _x vectorFromTo _targetPos))),
						_x
					]};
					_spotterUnits sort false;
					_spotter = _spotterUnits # 0 # 1;

					// Spot the target
					[_spotter, _target] remoteExecCall [QFUNC(gm_spotTargetLocal), 0, false];
					[_spotter] call FUNC(anim_gesturePoint);
				};

				// This is where the magic happens.
				// AI units get stuck when engaging a target for too long. To fix this,
				// we make them forget them periodically.
				// The only case where this is problematic is when the target is a player, as they
				// are likely to exploit this.
				if (!isPlayer _target) then {
					_group forgetTarget _target;
				};

			} forEach (_group targets [true, 0, GVAR(sides) - [side _group], 0]);
		};

		GVAR(ai_sys_groupKnowledge_index) = [-1, _groupIndex - 1] select (_groupIndex > 0);
	};



	// Restart the cycle for the next frame.
	// Doing this *after* the update loop guarantees no frame gets skipped due to resetting the nextUpdate time,
	// as we now have to wait at least one frame for the next cycle to be evaluated.
	if (_time > GVAR(ai_sys_groupKnowledge_nextUpdate) and {GVAR(ai_sys_groupKnowledge_index) < 0}) then {
		GVAR(ai_sys_groupKnowledge_nextUpdate) = _time + MACRO_SYS_GROUPKNOWLEDGE_INTERVAL;

		GVAR(ai_sys_groupKnowledge_groups) = allGroups select {local _x}; // Preliminary filter
		GVAR(ai_sys_groupKnowledge_count)  = count GVAR(ai_sys_groupKnowledge_groups);
		GVAR(ai_sys_groupKnowledge_index)  = GVAR(ai_sys_groupKnowledge_count) - 1;
	};
}];
