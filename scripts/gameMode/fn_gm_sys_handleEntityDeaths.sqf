/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[S]
		Handles various serverside functionalities to entity deaths, such as score events, statistics and serverside
		AI respawn times.

		Only executed once by the server upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

if (!isServer) exitWith {};





// Set up some variables
MACRO_FNC_INITVAR(GVAR(gm_sys_handleEntityDeaths_EH),-1);





removeMissionEventHandler ["EntityKilled", GVAR(gm_sys_handleEntityDeaths_EH)];
GVAR(gm_sys_handleEntityDeaths_EH) = addMissionEventHandler ["EntityKilled", {

	params ["_obj", "_killer", "_instigator"];



	// Handle units
	if (_obj isKindOf "Man") exitWith {

		// Handle AI respawn times
		if (!isPlayer _obj) then {
			private _unitIndex = _obj getVariable [QGVAR(unitIndex), -1];

			if (_unitIndex >= 0 and {_unitIndex < GVAR(param_ai_maxCount)}) then {
				private _unconsciousTime = _obj getVariable [QGVAR(unconsciousTime), -1];

				if (_unconsciousTime < 0) then {
					_unconsciousTime = time;
				};

				GVAR(ai_sys_handleRespawn_respawnTimes) set [_unitIndex, _unconsciousTime + GVAR(param_gm_unit_respawnDelay)];
			};
		};

		// Consider unit deaths for the statistics
		private _UID    = [_obj] call FUNC(unit_getUID);
		private _data   = GVAR(sv_stats) getOrDefault [_UID, []];
		private _deaths = _data param [MACRO_INDEX_SERVERSTAT_DEATHS, 0];
		_data set [MACRO_INDEX_SERVERSTAT_DEATHS, _deaths + 1];

		GVAR(sv_stats) set [_UID, _data];
	};



	// Handle vehicles
	if !(_obj isKindOf "Air" or {_obj isKindOf "LandVehicle"}) exitWith {};

	if (isNull _instigator or {!(_instigator isKindOf "Man")}) then {
		_instigator = _killer;
	};

	private _sideObj        = _obj getVariable [QGVAR(side), sideEmpty];
	private _sideInstigator = _instigator getVariable [QGVAR(side), sideEmpty];

	// Kill the crew
	{
		[
			_x,
			-1,
			MACRO_ENUM_DAMAGE_EXPLOSIVE,
			_killer,
			_instigator,
			false,
			"",
			false
		] call FUNC(gm_processUnitDamage);
	} forEach (crew _obj select {alive _x});

	// If the vehicle belongs to a side, hand out a score
	if (_sideObj != sideEmpty) then {
		[
			_instigator,
			[MACRO_ENUM_SCORE_DESTROYVEHICLE_ENEMY, MACRO_ENUM_SCORE_DESTROYVEHICLE_FRIENDLY] select (_sideObj == _sideInstigator),
			_obj
		] call FUNC(gm_addScore);
	};
}];
