/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Processes the damage event on the given unit. If the unit drops below 0 health, this function will
		handle additional steps, such as knocking the unit unconscious and adding score to the instigator.
		Use negative damage values to forcefully kill a unit regardless of their health.
		The unit's revive duration depends on the amount of damage dealt, and can be skipped completely (see
		arguments below).

		Only executed on the server via remote call.
	Arguments:
		0:	<OBJECT>	The unit which should receive damage
		1:	<NUMBER>	The amount of damage to be dealt
		2:	<NUMBER>	The kind of damage that was dealt (see macros.inc)
		3:	<OBJECT>	The damage source (optional, default: objNull)
		4:	<OBJECT>	The damage instigator (optional, default: objNull)
		5:	<BOOLEAN>	Whether the unit can be revived (optional, default: true)
		6:	<STRING>	The used ammo classname, if specified (optional, default: "")
		7:	<STRING>	Whether the damage was a headshot (optional, default: false)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_unit", objNull, [objNull]],
	["_damage", 0, [0]],
	["_damageEnum", MACRO_ENUM_DAMAGE_UNKNOWN, [MACRO_ENUM_DAMAGE_UNKNOWN]],
	["_source", objNull, [objNull]],
	["_instigator", objNull, [objNull]],
	["_isRevivable", true, [true]],
	["_ammoType", "", [""]],
	["_isHeadShot", false, [false]]
];

if (!isServer or {_damage == 0} or {!([_unit] call FUNC(unit_isAlive))}) exitWith {};





// Set up some variables
private _time = time;
private _health         = _unit getVariable [QGVAR(health), 1];
private _sideUnit       = _unit getVariable [QGVAR(side), sideEmpty];
private _sideInstigator = _instigator getVariable [QGVAR(side), sideEmpty];

// Edge case: negative damage always kills the unit
if (_damage < 0) then {
	_damage = _health;
	_health = 0;
} else {
	_health = _health - _damage;
};





// Unit is still conscious
if (_health > 0) then {

	// Handle kill assists
	if (!isNull _instigator and {_sideUnit != _sideInstigator}) then {

		private _endTime       = _time + MACRO_GM_KILLASSISTDURATION;
		private _assists       = _unit getVariable [QGVAR(addHitDetection_assists), []];
		private _assistTimes   = _unit getVariable [QGVAR(addHitDetection_assistTimes), []];
		private _assistDamages = _unit getVariable [QGVAR(addHitDetection_assistDamages), []];
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

		_unit setVariable [QGVAR(addHitDetection_assists), _assists, false];
		_unit setVariable [QGVAR(addHitDetection_assistTimes), _assistTimes, false];
		_unit setVariable [QGVAR(addHitDetection_assistDamages), _assistDamages, false];
	};

// Unit is unconscious / dead
} else {

	// Handle the kill score
	if (!isNull _instigator) then {

		if (_unit != _instigator) then {
			[
				_instigator,
				[MACRO_ENUM_SCORE_KILL_ENEMY, MACRO_ENUM_SCORE_KILL_FRIENDLY] select (_sideUnit == _sideInstigator),
				_unit
			] call FUNC(gm_addScore);

			// Headshot bonus
			if (_isHeadShot and {_sideUnit != _sideInstigator}) then {
				[_instigator, MACRO_ENUM_SCORE_HEADSHOT] call FUNC(gm_addScore);
			};

		} else {
			[_unit, MACRO_ENUM_SCORE_SUICIDE] call FUNC(gm_addScore);
		};
	};

	// Handle spot assists
	private "_spotter";
	{
		if (_x != sideEmpty) then {
			if (_time <= _unit getVariable [format [QGVAR(spottedTime_%1), _x], -MACRO_ACT_SPOTTING_DURATION]) then {

				_spotter = _unit getVariable [format [QGVAR(spotter_%1), _x], objNull];

				if (_spotter != _instigator) then {
					[_spotter, MACRO_ENUM_SCORE_SPOTASSIST] call FUNC(gm_addScore);
				};
			};
		};
	} forEach GVAR(sides);

	// Handle kill assists
	private _assistTimes   = _unit getVariable [QGVAR(addHitDetection_assistTimes), []];
	private _assistDamages = _unit getVariable [QGVAR(addHitDetection_assistDamages), []];
	private ["_assistTime", "_assistDamage"];

	{
		_assistTime   = _assistTimes # _forEachIndex;
		_assistDamage = _assistDamages # _forEachIndex;

		if (_x != _instigator and {_time <= _assistTime}) then {
			[_x, MACRO_ENUM_SCORE_KILLASSIST, _assistDamage] call FUNC(gm_addScore);
		};

	} forEach (_unit getVariable [QGVAR(addHitDetection_assists), []]);

	// Dispatch a kill feed event
	private _killData = [];
	switch (_damageEnum) do {
		case MACRO_ENUM_DAMAGE_UNKNOWN: {};

		case MACRO_ENUM_DAMAGE_BULLET;
		case MACRO_ENUM_DAMAGE_EXPLOSIVE: {
			if (_ammoType != "") then {
				private _ammoData = _instigator getVariable [format [QGVAR(ammoData_%1), _ammoType], []];
				private _iconEnum = MACRO_ENUM_KF_ICON_NONE;

				// Fallback for when no ammo data exists (yet): let the clients determine it
				if (_ammoData isEqualTo []) then {
					_ammoData = [MACRO_ENUM_CLASSKIND_AMMO, _ammoType];
				};

				if (_isHeadShot) then {
					_iconEnum = MACRO_ENUM_KF_ICON_HEADSHOT;
				} else {
					if (
						_ammoType isKindOf "PipeBombCore"
						or {_ammoType isKindOf "G_40mm_HE"}
					) then {
						_iconEnum = MACRO_ENUM_KF_ICON_EXPLOSIVE;
					} else {
						if (_ammoType isKindOf "TimeBombCore") then {
							_iconEnum = MACRO_ENUM_KF_ICON_MINE;
						};
					};
				};

				_killData = [_iconEnum] + _ammoData;
			} else {
				_killData = [MACRO_ENUM_KF_ICON_NONE, MACRO_ENUM_CLASSKIND_VEHICLE, ""];
			};
		};
		case MACRO_ENUM_DAMAGE_PHYSICS: {
			if (!isNull _instigator and {_instigator != _unit}) then {
				_killData = [MACRO_ENUM_KF_ICON_ROADKILL, MACRO_ENUM_CLASSKIND_VEHICLE, typeOf _source];
			} else {
				_instigator = _unit;
				_killData = [MACRO_ENUM_KF_ICON_NONE, MACRO_ENUM_CLASSKIND_VEHICLE, ""]; // Suicide from fall damage
			};
		};
	};
	[_instigator, _unit, _killData] remoteExecCall [QFUNC(ui_processKillFeedEvent), 0, false];

	// Reset the units hit detection state (ensures compatibility with reviving)
	_unit setVariable [QGVAR(addHitDetection_assists), nil, false];
	_unit setVariable [QGVAR(addHitDetection_assistTimes), nil, false];
	_unit setVariable [QGVAR(addHitDetection_assistDamages), nil, false];

	_unit setDamage 1;

	private _reviveDuration = 0;
	if (_isRevivable) then {
		_reviveDuration = MACRO_GM_UNIT_REVIVEDURATION * (500 + _health * 100) / 500;	// High damage on death reduces the revive duration
	};

	// If the unit is inside a destroyed vehicle, they cannot be pulled out by medics, so we forcefully move them out instead
	private _veh = vehicle _unit;
	if (_veh != _unit and {!alive _veh}) then {
		[_unit] remoteExecCall ["moveOut", owner _unit, false];
	};

/*
	// Handle revivability
	if (_reviveDuration <= 0) then {
		_unit setDamage 1;
	} else {

		_unit setVariable [QGVAR(reviveTime), _time + _reviveDuration, true];

		[_unit] remoteExecCall [QFUNC(unit_incapacitate), owner _unit, false];
	};
*/
};

// Clamp the health to 0
_unit setVariable [QGVAR(health), _health max 0, true];

[_unit, _damage, _damageEnum, _source] remoteExecCall [QFUNC(unit_processDamageEvent), _unit, false];
