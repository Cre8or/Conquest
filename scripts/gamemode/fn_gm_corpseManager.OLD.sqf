#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"





// Set up some variables
private ["_time", "_timeRespawn", "_timeHideBody", "_timeDelete", "_deathTime", "_unitIndex", "_veh"];





while {true} do {

	_time = time;
	_timeRespawn = _time - GVAR(Param_GM_Unit_RespawnDelay);
	_timeHideBody = _time - MACRO_CORPSEMANAGER_UNIT_CLEANUPDELAY;
	_timeDelete = (_timeRespawn min _timeHideBody) - 5; // 5 seconds between the hiding and the removing of bodies

	// Dead units
	{
		// Always delete dead agents
		if (isAgent teamMember _x) then {
			deleteVehicle _x;

		} else {
			_deathTime = _x getVariable [QGVAR(deathTime), -1];

			if (_deathTime < 0) then {
				_x setVariable [QGVAR(deathTime), _time, false];
			} else {

				if (_timeRespawn > _deathTime) then {
					_unitIndex = _x getvariable [QGVAR(unitIndex), -1];

					if (_unitIndex >= 0) then {
						GVAR(AIUnits) set [_unitIndex, objNull]; // Clearing the global AI units array's entry at the given index position will allow the unit to be respawned while the corpse still exists

						_x setVariable [QGVAR(unitIndex), -1, false];
					};

					// Check if we should hide the body
					if (_timeHideBody > _deathTime) then {
						if (_timeDelete > _deathTime) then {
							deleteVehicle _x;
						} else {
							hideBody _x;
						};
					};
				};
			};
		};
	} forEach allDeadMen;

	// Destroyed vehicles
	for "_i" from count GVAR(allVehicles) - 1 to 0 step -1 do {
		_veh = GVAR(allVehicles) param [_i, objNull];

		if (!alive _veh) then {
			_deathTime = _veh getVariable [QGVAR(deathTime), -1];

			if (_deathTime < 0) then {
				_veh setVariable [QGVAR(deathTime), _time, false];
			} else {

				if (_time > _deathTime + (_veh getVariable [QGVAR(respawnDelay), MACRO_CORPSEMANAGER_VEHICLE_CLEANUPDELAY])) then {
					deleteVehicleCrew _veh;
					deleteVehicle _veh;

					GVAR(allVehicles) deleteAt _i;
				};
			};
		};
	};

	sleep 1;
};
