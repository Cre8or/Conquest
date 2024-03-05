/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LA][LE]
		Processes a damage event on the given unit. This includes the kind of damage that was dealt,
		represented as an enumeration (see macros.inc for possible values).
		If specified, the damage source represents the object that dealt the damage, not the instigator.

		Executed on the unit's owning machine, via server remoteExecCall.
	Arguments:
		0:	<OBJECT>	The unit that received damage
		1:	<NUMBER>	The kind of damage received
		2:	<OBJECT>	The object that inflicted the damage (optional, default: objNull)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"

params [
	["_unit", objNull, [objNull]],
	["_enum", MACRO_ENUM_DAMAGE_UNKNOWN, [MACRO_ENUM_DAMAGE_UNKNOWN]],
	["_source", objNull, [objNull]]
];

if (!local _unit) exitWith {};





// Set up some variables
private _sound = "";
private _ply = player;





// If the damaged unit corresponds to the player, fetch a sound to play
if (_unit == _ply) then {
	GVAR(ui_med_lastDamageTime)      = time;
	GVAR(ui_med_lastDamageEnum)      = _enum;
	GVAR(ui_med_lastDamageSource)    = _source;
	GVAR(ui_med_lastDamageSourcePos) = getPosWorld _source;

	private _sound = "";
	private _volume = 5;
	private _camShake = [];

	switch (_enum) do {
		case MACRO_ENUM_DAMAGE_BULLET;
		case MACRO_ENUM_DAMAGE_EXPLOSIVE: {
			_sound = format [QGVAR(BulletHit_%1), selectRandom [1, 1, 2, 3]];
			_volume = 5;
			_camShake = [[10, 0.3, 6], [1, 0.5, 10]];
		};

		case MACRO_ENUM_DAMAGE_PHYSICS: {
			_sound = format ["a3\sounds_f\characters\footsteps\_base\boot_hard_run_%1.wss", selectRandom [1, 2, 3, 4]];
			_volume = 4;
			_camShake = [[15, 0.75, 5.3]];
		};
	};

	if (_sound != "") then {
		playSoundUI [_sound, _volume, 0.95 + random 0.15, true];
	};

	{
		addCamShake _x;
	} forEach _camShake;
};
