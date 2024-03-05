/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles the control of AI vehicle drivers, using the mission-defined vehicle nodemesh.
		Units must have a valid pathData array (set by subSys_moveToPos).

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
MACRO_FNC_INITVAR(GVAR(ai_sys_driverControl_EH), -1);
MACRO_FNC_INITVAR(GVAR(ai_sys_driverControl_EH_draw3D_debug), -1);

GVAR(ai_sys_driverControl_nextUpdate) = 0;
GVAR(ai_sys_driverControl_index)      = -1;

#ifdef MACRO_DEBUG_AI_DRIVER
	GVAR(debug_ai_driverControl_data) = [];
#endif





removeMissionEventHandler ["EachFrame", GVAR(ai_sys_driverControl_EH)];
GVAR(ai_sys_driverControl_EH) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	private _time = time;

	if (GVAR(missionState) != MACRO_ENUM_MISSION_LIVE) exitWith {};

	// Update candidate drivers
	private ["_unit", "_veh", "_vehPos", "_vehRadius", "_vehVel", "_shouldHalt", "_hasTracks", "_routeIndexChanged", "_routePos", "_pathData", "_pathIndex", "_pathIndexLast"];
	for "_unitIndex" from GVAR(ai_sys_driverControl_index) to 0 step -1 do {

		scopeName QGVAR(ai_sys_driverControl_loop);

		// Exit early if no more units may be handled this frame (balances the load over multiple frames)
		if (_unitIndex < ((GVAR(ai_sys_driverControl_nextUpdate) - _time) * GVAR(param_ai_maxCount) / MACRO_AI_DRIVERCONTROL_INTERVAL)) then {
			breakOut QGVAR(ai_sys_driverControl_loop);
		};

		_unit = missionNamespace getVariable [format [QGVAR(AIUnit_%1), _unitIndex], objNull];
		_veh  = vehicle _unit;

		#ifdef MACRO_DEBUG_AI_DRIVER
			GVAR(debug_ai_driverControl_data) set [_unitIndex, nil];
		#endif

		if (
			local _unit
			and {_unit != _veh}
			and {_unit == driver _veh}
			and {[_unit] call FUNC(unit_isAlive)}
		) then {
			_vehPos            = _veh modelToWorldVisualWorld getCenterOfMass _veh; // Some vehicles have strange origin points; this compensates for that
			_vehRadius         = 0.6 * (2 boundingBoxReal _veh) # 2; // Approximation
			_vehVel            = velocity _veh;
			_shouldHalt        = false;
			_hasTracks         = _veh getVariable QGVAR(hasTracks);
			_routeIndexChanged = false;
			_routePos          = [];

			// Vehicle kind
			if (isNil "_hasTracks") then {
				_hasTracks = (
					_veh isKindOf "Tank"
					or {toLower ([configFile >> "CfgVehicles" >> typeOf _veh, "simulation", ""] call BIS_fnc_returnConfigEntry) == "tankx"}
				);
				_veh setVariable [QGVAR(hasTracks), _hasTracks, false];
			};

			// Route data
			_pathData      = _unit getVariable [QGVAR(ai_unitControl_moveToPos_pathData), []];
			_pathIndex     = _unit getVariable [QGVAR(ai_unitControl_moveToPos_pathIndex), 0];
			_pathIndexLast = _unit getVariable [QGVAR(ai_unitControl_moveToPos_pathIndexLast), -1];
			_pathData params ["_pathRoute", "_pathRadii", "_pathNodes"];

			scopeName QGVAR(ai_sys_driverControl_loop_local);

			// Handle interaction with friendly units attemping to mount up
			#include "driverControl\subSys_processMountUpQueue.sqf";

			// Advance along the vehicle's route and determine the current node index
			#include "driverControl\subSys_handleRouteCompletion.sqf";

			// Drive the vehicle according to the sum of calculated forces
			#include "driverControl\subSys_handleDriving.sqf";
		};

		GVAR(ai_sys_driverControl_index) = [-1, _unitIndex - 1] select (_unitIndex > 0);
	};



	// Restart the cycle for the next frame.
	// Doing this *after* the update loop guarantees no frame gets skipped due to resetting the nextUpdate time,
	// as we now have to wait at least one frame for the next cycle to be evaluated.
	if (_time > GVAR(ai_sys_driverControl_nextUpdate) and {GVAR(ai_sys_driverControl_index) < 0}) then {
		GVAR(ai_sys_driverControl_nextUpdate) = _time + MACRO_AI_DRIVERCONTROL_INTERVAL;
		GVAR(ai_sys_driverControl_index)      = GVAR(param_ai_maxCount) - 1;
	};
}];





// Debug rendering
removeMissionEventHandler ["Draw3D", GVAR(ai_sys_driverControl_EH_draw3D_debug)];

#ifdef MACRO_DEBUG_AI_DRIVER
	GVAR(ai_sys_driverControl_EH_draw3D_debug) = addMissionEventHandler ["Draw3D", {

		if (isGamePaused) exitWith {};

		private ["_vehPosWorld", "_forcePos", "_vehPos"];

		{
			if (!isNil "_x") then {
				_x params ["_veh", "_sumOfForces", "_routePos", "_targetSpeed"];
				_vehPosWorld = getPosWorldVisual _veh;
				_forcePos    = ASLtoAGL (_vehPosWorld vectorAdd _sumOfForces);
				_vehPos      = ASLtoAGL _vehPosWorld;

				cameraEffectEnableHUD true;
				drawIcon3D [
					"a3\ui_f\data\IGUI\Cfg\IslandMap\iconSelect_ca.paa",
					[0,1,0,1],
					_vehPos,
					0.5,
					0.5,
					0
				];

				drawIcon3D [
					"a3\ui_f\data\IGUI\Cfg\IslandMap\iconSelect_ca.paa",
					[0,1,0,1],
					_routePos,
					1,
					1,
					0,
					str (round (_targetSpeed * 10) / 10)
				];

				drawIcon3D [
					"a3\ui_f\data\IGUI\Cfg\IslandMap\assault_ca.paa",
					[0,1,0,1],
					_forcePos,
					1,
					1,
					0
				];

				drawLine3D [
					_vehPos,
					_forcePos,
					[0,1,0,1]
				];

				drawLine3D [
					_vehPos,
					_routePos,
					[0,1,0,1]
				];
/*
				if (!isNil "_routePosAhead") then {
					drawLine3D [
						_routePos,
						_routePosAhead,
						[0,1,0,1]
					];

					drawIcon3D [
						"a3\ui_f\data\IGUI\Cfg\IslandMap\iconSelect_ca.paa",
						[0,1,0,1],
						_routePosAhead,
						0.5,
						0.5,
						0
					];
				};
*/
			};
		} foreach GVAR(debug_ai_driverControl_data);
	}];
#endif
