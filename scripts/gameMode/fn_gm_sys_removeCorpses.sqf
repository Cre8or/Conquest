/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles the removal of unit corpses.

		Only executed once by the server upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

if (!isServer) exitWith {};





/// Set up some variables
MACRO_FNC_INITVAR(GVAR(gm_sys_removeCorpses_EH), -1);

GVAR(gm_sys_removeCorpses_nextUpdate) = -1;





removeMissionEventHandler ["EachFrame", GVAR(gm_sys_removeCorpses_EH)];
GVAR(gm_sys_removeCorpses_EH) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	private _time = time;
	if (_time > GVAR(gm_sys_removeCorpses_nextUpdate)) then {

		// Remove corpses
		private ["_unit", "_veh"];
		{
			_unit        = _x;
			_removalTime = _unit getVariable [QGVAR(gm_sys_removeCorpses_removalTime), -1];

			// Set the cleanup time (new corpse)
			if (_removalTime < 0) then {
				_unit setVariable [QGVAR(gm_sys_removeCorpses_removalTime), _time + MACRO_CLEANUPDELAY_CORPSE, false];

			// Enforce the cleanup time (known corpse)
			} else {
				if (_time > _removalTime) then {
					_veh = vehicle _unit;

					if (_unit != _veh) then {
						_veh deleteVehicleCrew _unit;
					};

					deleteVehicle _x;
				};
			};
		} forEach allDeadMen;

		// Remove vehicle wrecks
		private _vehiclesChanged = false;

		for "_i" from (count GVAR(allVehicles)) - 1 to 0 step -1 do {
			_veh         = GVAR(allVehicles) param [_i, objNull];
			_removalTime = _veh getVariable [QGVAR(gm_sys_removeCorpses_removalTime), -1];

			if (alive _veh) then {
				continue;
			};

			// Set the cleanup time (new wreck)
			if (_removalTime < 0) then {
				_veh setVariable [QGVAR(gm_sys_removeCorpses_removalTime), _time + MACRO_CLEANUPDELAY_WRECK, false];

			// Enforce the cleanup time (known wreck)
			} else {
				if (_time > _removalTime) then {
					deleteVehicleCrew _veh;
					deleteVehicle _veh;

					GVAR(allVehicles) deleteAt _i;
					_vehiclesChanged = true;
				};
			};
		};

		// Broadcast the new vehicles array if it changed
		if (_vehiclesChanged) then {
			publicVariable QGVAR(allVehicles);
		};

		GVAR(gm_sys_removeCorpses_nextUpdate) = _time + MACRO_GM_SYS_REMOVECORPSES_INTERVAL;
	};
}];
