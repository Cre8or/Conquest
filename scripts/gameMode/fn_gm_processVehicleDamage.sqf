/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LA][GE]
		Processes the damage event on the given vehicle. If the vehicle drops below 0 health, this function will
		handle additional steps, such as firing a killfeed event and adding score to the instigator.
		Use negative damage values to forcefully kill a vehicle regardless of its health.
	Arguments:
		0:	<OBJECT>	The vehicle which should receive damage
		1:	<NUMBER>	The amount of damage to be dealt
		2:	<NUMBER>	The kind of damage that was dealt (see macros.inc)
		3:	<OBJECT>	The damage source (optional, default: objNull)
		4:	<OBJECT>	The damage instigator (optional, default: objNull)
		5:	<STRING>	The used ammo classname, if specified (optional, default: "")
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_veh", objNull, [objNull]],
	["_damage", 0, [0]],
	["_damageEnum", MACRO_ENUM_DAMAGE_UNKNOWN, [MACRO_ENUM_DAMAGE_UNKNOWN]],
	["_source", objNull, [objNull]],
	["_instigator", objNull, [objNull]],
	["_ammoType", "", [""]]
];

if (!local _veh or {_damage == 0}) exitWith {}; // Allow the function to run on dead vehicles





private _time           = time;
private _health         = _veh getVariable [QGVAR(health), 1];
private _sideVeh        = _veh getVariable [QGVAR(side), sideEmpty];
private _sideInstigator = _instigator getVariable [QGVAR(side), sideEmpty];

// Filter out dead vehicles whose health is already 0
if (!alive _veh and {_health <= 0}) exitWith {};

// Edge case: negative damage always kills the vehicle
if (_damage < 0) then {
	_damage = _health;
	_health = 0;
} else {
	_health = (_health - _damage) max 0;
};

_veh setVariable [QGVAR(health), _health, true];





// Vehicle is still alive
if (_health > 0) then {

	// Handle destroy assists
	if (!isNull _instigator and {_sideVeh != _sideInstigator}) then {

		private _endTime       = _time + MACRO_GM_KILLASSISTDURATION;
		private _assists       = _veh getVariable [QGVAR(gm_processVehicleDamage_assists), []];
		private _assistTimes   = _veh getVariable [QGVAR(gm_processVehicleDamage_assistTimes), []];
		private _assistDamages = _veh getVariable [QGVAR(gm_processVehicleDamage_assistDamages), []];
		private _index         = _assists find _instigator;

		// Instigator is already known; increase their total damage
		if (_index >= 0) then {
			_assistTimes   set [_index, _endTime];
			_assistDamages set [_index, _assistDamages # _index + _damage];

		// New instigator; append new data
		} else {
			_assists       pushBack _instigator;
			_assistTimes   pushBack _endTime;
			_assistDamages pushBack _damage;
		};

		_veh setVariable [QGVAR(gm_processVehicleDamage_assists), _assists, false];
		_veh setVariable [QGVAR(gm_processVehicleDamage_assistTimes), _assistTimes, false];
		_veh setVariable [QGVAR(gm_processVehicleDamage_assistDamages), _assistDamages, false];
	};

// Vehicle is destroyed
} else {

	// Handle the kill score
	if (!isNull _instigator and {_instigator isKindOf "Man"}) then {
		[
			_instigator,
			[MACRO_ENUM_SCORE_VEHICLE_DESTROY_ENEMY, MACRO_ENUM_SCORE_VEHICLE_DESTROY_FRIENDLY] select (_sideVeh == _sideInstigator)
		] remoteExecCall [QFUNC(gm_addScore), 2, false];
	};

	// Handle kill assists
	private _assistTimes   = _veh getVariable [QGVAR(gm_processVehicleDamage_assistTimes), []];
	private _assistDamages = _veh getVariable [QGVAR(gm_processVehicleDamage_assistDamages), []];
	private ["_assistTime", "_assistDamage"];

	{
		_assistTime   = _assistTimes # _forEachIndex;
		_assistDamage = (_assistDamages # _forEachIndex) min 1;

		if (_x != _instigator and {_time <= _assistTime}) then {
			[_x, MACRO_ENUM_SCORE_VEHICLE_DESTROYASSIST, _assistDamage] remoteExecCall [QFUNC(gm_addScore), 2, false];
		};

	} forEach (_veh getVariable [QGVAR(gm_processVehicleDamage_assists), []]);

	// Prepare shared data for kill feed events
	private _killData = [MACRO_ENUM_KF_ICON_NONE, MACRO_ENUM_CLASSKIND_NONE, ""]; // Default

	switch (_damageEnum) do {
		case MACRO_ENUM_DAMAGE_UNKNOWN: {};

		case MACRO_ENUM_DAMAGE_BULLET;
		case MACRO_ENUM_DAMAGE_EXPLOSIVE: {

			// Vehicle detonations (e.g. by script) report the vehicle as the source. For these cases,
			// use the vehicle as killfeed icon.
			if (_veh == _source) then {
				_killData = [MACRO_ENUM_KF_ICON_EXPLOSIVE, MACRO_ENUM_CLASSKIND_VEHICLE, typeOf _source];

			} else {
				if (_ammoType != "") then {
					private _ammoData = _instigator getVariable [format [QGVAR(ammoData_%1), _ammoType], []];
					private _iconEnum = MACRO_ENUM_KF_ICON_NONE;

					// Fallback for when no ammo data exists (yet): let the clients determine it
					if (_ammoData isEqualTo []) then {
						_ammoData = [MACRO_ENUM_CLASSKIND_AMMO, _ammoType];
					};

					if (_ammoType isKindOf "TimeBombCore") then {
						_iconEnum = MACRO_ENUM_KF_ICON_MINE;
					} else {
						// Even if a bullet killed the vehicle, we assume the vehicle is detonating from the cook-off
						_iconEnum = MACRO_ENUM_KF_ICON_EXPLOSIVE;
					};

					_killData = [_iconEnum] + _ammoData;
				} else {
					if (_source isKindOf "Man") then {
						_killData = [MACRO_ENUM_KF_ICON_EXPLOSIVE, MACRO_ENUM_CLASSKIND_VEHICLE, ""];
					} else {
						_killData = [MACRO_ENUM_KF_ICON_EXPLOSIVE, MACRO_ENUM_CLASSKIND_VEHICLE, typeOf _source];
					};
				};
			};
		};

		case MACRO_ENUM_DAMAGE_PHYSICS: {
			_killData   = [MACRO_ENUM_KF_ICON_NONE, MACRO_ENUM_CLASSKIND_VEHICLE, typeOf _veh]; // Suicide by vehicle?
			_instigator = objNull;
		};

		// Unused
		case MACRO_ENUM_DAMAGE_COMBATAREA: {
			_instigator = objNull;
		};

		case MACRO_ENUM_DAMAGE_CURATOR: {
			_instigator = objNull;
			_killData   = [MACRO_ENUM_KF_ICON_CURATOR, MACRO_ENUM_CLASSKIND_VEHICLE, typeOf _veh];
		};
	};

	// Handle the vehicle crew
	private ["_crewX"];
	private _hasAnyCrew         = false;
	private _crewKilledEnemy    = [];
	private _crewKilledFriendly = [];
	{
		_crewX = _x;

		if !([_crewX] call FUNC(unit_isAlive)) then {
			continue;
		};

		// Since we can't kill remote units, we, um... we have to tell the crew to... do it themselves...
		// ...yeah.
		//
		// :|
		[_crewX, 1] remoteExecCall ["setDamage", _crewX, false];
		_hasAnyCrew = true;

		if (_sideInstigator != _crewX getVariable [QGVAR(side), sideEmpty]) then {
			_crewKilledEnemy pushBack _crewX;
		} else {
			_crewKilledFriendly pushBack _crewX;
		};
	} forEach crew _veh;

	if (_hasAnyCrew) then {
		// Handle kill scores for the crew
		if (_crewKilledEnemy isNotEqualTo []) then {
			[_instigator, MACRO_ENUM_SCORE_KILL_ENEMY, _crewKilledEnemy] remoteExecCall [QFUNC(gm_addScore), 2, false];
		};
		if (_crewKilledFriendly isNotEqualTo []) then {
			[_instigator, MACRO_ENUM_SCORE_KILL_FRIENDLY, _crewKilledFriendly] remoteExecCall [QFUNC(gm_addScore), 2, false];
		};

		// Broadcast the prepared killfeed event
		[_instigator, _crewKilledEnemy + _crewKilledFriendly, _killData] remoteExecCall [QFUNC(ui_processKillFeedEvent), 0, false];
	};

	// Finally, destroy the vehicle
	_veh setDamage 1;
};
