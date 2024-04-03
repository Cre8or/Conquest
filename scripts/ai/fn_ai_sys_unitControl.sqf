/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles the control of AI units. This includes various gamemode-relevant subsystems, such as waypoints
		following, vehicle claiming, and handling role-specific requests.

		Only executed once by all machines upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"

#include "..\..\res\macros\fnc_initVar.inc"





// Set up some variables
MACRO_FNC_INITVAR(GVAR(ai_sys_unitControl_EH), -1);
MACRO_FNC_INITVAR(GVAR(ai_sys_unitControl_EH_draw3D_movePos), -1);
MACRO_FNC_INITVAR(GVAR(ai_sys_unitControl_EH_draw3D_dodgeVehicles), -1);
MACRO_FNC_INITVAR(GVAR(ai_sys_unitControl_goalPosCache), []);

GVAR(ai_sys_unitControl_nextUpdate) = 0;
GVAR(ai_sys_unitControl_index)      = -1;
GVAR(ai_sys_unitControl_cache)      = createHashMap;

#ifdef MACRO_DEBUG_AI_MOVEPOS
	GVAR(debug_ai_unitControl_planNextMovePos_data) = [];
	GVAR(debug_ai_unitControl_moveToPos_route)      = [];
#endif

#ifdef MACRO_DEBUG_AI_DODGEVEHICLES
	GVAR(debug_ai_unitControl_dodgeVehicles_data) = [];
#endif





removeMissionEventHandler ["EachFrame", GVAR(ai_sys_unitControl_EH)];
GVAR(ai_sys_unitControl_EH) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	private _time             = time;
	private _missionSafeStart = (GVAR(missionState) != MACRO_ENUM_MISSION_LIVE);

	// Update candidate units
	private ["_unit", "_role", "_side", "_group", "_leader", "_isLeader", "_isLeaderPlayer", "_unitPos", "_unitVeh", "_isInVehicle", "_changedVehicle", "_isDriver", "_actionPos", "_moveType"];
	for "_unitIndex" from GVAR(ai_sys_unitControl_index) to 0 step -1 do {

		scopeName QGVAR(ai_sys_unitControl_loop);

		// Exit early if no more units may be handled this frame (balances the load over multiple frames)
		if (_unitIndex < ((GVAR(ai_sys_unitControl_nextUpdate) - _time) * GVAR(param_ai_maxCount) / MACRO_AI_UNITCONTROL_INTERVAL)) then {
			breakOut QGVAR(ai_sys_unitControl_loop);
		};

		_unit = missionNamespace getVariable [format [QGVAR(AIUnit_%1), _unitIndex], objNull];

		if (
			local _unit
			and {[_unit] call FUNC(unit_isAlive)}
		) then {
			_role           = _unit getVariable [QGVAR(role), sideEmpty];
			_side           = _unit getVariable [QGVAR(side), sideEmpty];
			_group          = group _unit;
			_leader         = leader _group;
			_isLeader       = (_unit == _leader);
			_isLeaderPlayer = isPlayer _leader;
			_unitPos        = getPosWorld _unit;
			_unitVeh        = vehicle _unit;
			_isInVehicle    = (_unit != _unitVeh);
			_changedVehicle = (_isInVehicle != _unit getVariable [QGVAR(ai_sys_unitControl_isInVehicle), _isInVehicle]);
			_isDriver       = (_isInVehicle and {_unit == driver _unitVeh});

			// Basic AI settings
			_unit setCombatBehaviour "AWARE";
			_unit setSpeedMode "FULL";
			_unit allowFleeing 0;
			_unit doWatch objNull;

			// Safestart
			#include "unitControl\subSys_enforceSafeStart.sqf"

			if (!_missionSafeStart) then {

				// Define shared variables
				_actionPos = [];
				_moveType  = _unit getVariable [QGVAR(ai_sys_unitControl_moveType), MACRO_ENUM_AI_MOVETYPE_HALT];

				scopeName QGVAR(ai_sys_unitControl_loop_live);

				// Dodge incoming vehicles
				#include "unitControl\subSys_dodgeVehicles.sqf";

				// Ensure the unit is within the combat area
				#include "unitControl\subSys_combatArea.sqf";

				// Handle transitions to/from unique vehicle groups
				#include "unitControl\subSys_handleVehicleGroup.sqf";

				// ---- Actions ----
				// Check if any nearby vehicles can be claimed
				#include "unitControl\subSys_claimVehicle.sqf";

				// Handle medical actions (healing other units / seeking medical attention)
				#include "unitControl\subSys_handleMedical.sqf";

				// ---- Goals ----
				// Determine where the unit should be moving (waypoint, individual orders, etc)
				#include "unitControl\subSys_planNextMovePos.sqf";

				// Move the unit towards the planned position (or do nothing if no position was returned)
				#include "unitControl\subSys_moveToPos.sqf";
			};

			// Update shared variables
			_unit setVariable [QGVAR(ai_sys_unitControl_isInVehicle), _isInVehicle, false];
		};

		GVAR(ai_sys_unitControl_index) = [-1, _unitIndex - 1] select (_unitIndex > 0);
	};



	// Restart the cycle for the next frame.
	// Doing this *after* the update loop guarantees no frame gets skipped due to resetting the nextUpdate time,
	// as we now have to wait at least one frame for the next cycle to be evaluated.
	if (_time > GVAR(ai_sys_unitControl_nextUpdate) and {GVAR(ai_sys_unitControl_index) < 0}) then {
		GVAR(ai_sys_unitControl_nextUpdate) = _time + MACRO_AI_UNITCONTROL_INTERVAL;
		GVAR(ai_sys_unitControl_index)      = GVAR(param_ai_maxCount) - 1;

		// Additionally, we may aggregate unit arrays for role-specific subsystems. These arrays don't need to
		// be 100% up-to-date when they're referenced, and may in fact be expensive to compute for every unit.
		// So instead, we compute them once per cycle, right here.
		private _allUnits = allUnits select {
			_x getVariable [QGVAR(canCaptureSectors), false]
			and {[_x, true] call FUNC(unit_isAlive)} // Include unconscious units
		};

		private ["_sideX", "_unitsX", "_unitsAlive", "_unitsInjured", "_unitsUnconscious"];
		{
			if (_x == sideEmpty) then {
				continue;
			};

			_sideX  = _x;
			_unitsX = _allUnits select {_x getVariable [QGVAR(side), sideEmpty] == _sideX};
			_unitsAlive       = []; // All alive units on this side
			_unitsInjured     = []; // Alive Units on this side who are injured
			_unitsUnconscious = []; // Unconscious units on this side

			{
				if (vehicle _x != _x) then {
					continue; // Ignore units inside vehicles
				};

				if (_x getVariable [QGVAR(isUnconscious), false]) then {
					_unitsUnconscious pushBack _x;
				} else {
					_unitsAlive pushBack _x;

					if (_x getVariable [QGVAR(health), 1] < 1) then {
						_unitsInjured pushBack _x;
					};
				};
			} forEach _unitsX;

			GVAR(ai_sys_unitControl_cache) set [format ["unitsAlive_%1", _sideX], _unitsAlive];
			GVAR(ai_sys_unitControl_cache) set [format ["unitsInjured_%1", _sideX], _unitsInjured];
			GVAR(ai_sys_unitControl_cache) set [format ["unitsUnconscious_%1", _sideX], _unitsUnconscious];

		} forEach GVAR(sides);
	};
}];





// Debug rendering
removeMissionEventHandler ["Draw3D", GVAR(ai_sys_unitControl_EH_draw3D_movePos)];
removeMissionEventHandler ["Draw3D", GVAR(ai_sys_unitControl_EH_draw3D_dodgeVehicles)];

#ifdef MACRO_DEBUG_AI_MOVEPOS
	GVAR(ai_sys_unitControl_EH_draw3D_movePos) = addMissionEventHandler ["Draw3D", {

		if (isGamePaused) exitWith {};

		{
			if (!isNil "_x") then {
				_x params ["_unit", "_posEnd", "_colour", "_moveType"];

				//drawLine3D [unitAimPositionVisual _unit, _posEnd, _colour];
				cameraEffectEnableHUD true;
				drawIcon3D [
					switch (_moveType) do {
						case MACRO_ENUM_AI_MOVETYPE_REGROUP: {"a3\ui_f\data\Map\GroupIcons\selector_selectable_ca.paa"},
						case MACRO_ENUM_AI_MOVETYPE_GOAL:    {"a3\ui_f\data\Map\GroupIcons\selector_selected_ca.paa"},
						case MACRO_ENUM_AI_MOVETYPE_ACTION:  {"a3\ui_f\data\Map\GroupIcons\badge_gs.paa"},
						default                              {"a3\ui_f\data\Map\GroupIcons\waypoint.paa"}
					},
					_colour,
					_posEnd,
					0.75,
					0.75,
					0
				];
			};
		} foreach GVAR(debug_ai_unitControl_planNextMovePos_data);

		{
			if (!isNil "_x") then {
				{
					drawLine3D _x;
				} forEach _x;
			};
		} foreach GVAR(debug_ai_unitControl_moveToPos_route);
	}];
#endif

#ifdef MACRO_DEBUG_AI_DODGEVEHICLES
	GVAR(ai_sys_unitControl_EH_draw3D_dodgeVehicles) = addMissionEventHandler ["Draw3D", {

		if (isGamePaused) exitWith {};

		{
			if (!isNil "_x") then {
				drawLine3D (_x # 0);
				drawLine3D (_x # 1);
			};
		} foreach GVAR(debug_ai_unitControl_dodgeVehicles_data);
	}];
#endif





/*
Extra considerations:
	- pairwise unit requests (supplier+requester) must have time-outs, to prevent units getting stuck in loops
	- thresholds for repair and resupply must be carefully choosen to prevent these roles from being constantly busy
	- any countdowns/timers must be implemented by manually decrementing values, so that their state is transferred properly
	  on locality changes (time is not synced across machines)
*/
