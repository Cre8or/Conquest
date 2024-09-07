/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA][LE]
		Plays various 3D sounds on units.
		Refer to macros.inc for a list of possible sound enumerations.
	Arguments:
		0:	<OBJECT>	The unit in question
		1:	<NUMBER>	The sound enum (optional, default: MACRO_ENUM_SOUND_INVALID)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_unit", objNull, [objNull]],
	["_enum", MACRO_ENUM_SOUND_INVALID, [MACRO_ENUM_SOUND_INVALID]]
];


if (!hasInterface or {!alive _unit}) exitWith {};





private _soundData    = [];
private _soundsToStop = [];

// Fetch the requested sound data
switch (_enum) do {

	case MACRO_ENUM_SOUND_RESUPPLY: {
		_soundData = [format [QGVAR(Unit_Resupply_%1), 1 + floor random 2], 20, 1, 0];
	};

	case MACRO_ENUM_SOUND_HEAL: {
		_soundData = selectRandom [
			[QGVAR(Unit_Heal_1), 2.5],
			[QGVAR(Unit_Heal_2), 4.15],
			[QGVAR(Unit_Heal_3), 4.8],
			[QGVAR(Unit_Heal_4), 3.1],
			[QGVAR(Unit_Heal_5), 3.6],
			[QGVAR(Unit_Heal_6), 0],
			[QGVAR(Unit_Heal_7), 0],
			[QGVAR(Unit_Heal_8), 0],
			[QGVAR(Unit_Heal_9), 0]
		];
		_soundData = [_soundData # 0, 20, 1, 0, _soundData # 1];
	};

	case MACRO_ENUM_SOUND_VO_DEATH: {
		if (0.5 < random 1) then {
			_soundData = [format [QGVAR(Unit_VO_Death_Loud_%1), 1 + floor random 16], 200, 1, 0];
		} else {
			_soundData = [format [QGVAR(Unit_VO_Death_Quiet_%1), 1 + floor random 16], 100, 1, 0];
		};

		_soundsToStop = [MACRO_ENUM_SOUND_VO_REVIVE];
	};

	case MACRO_ENUM_SOUND_VO_REVIVE: {
		_soundData = [format [QGVAR(Unit_VO_Revive_%1), 1 + floor random 10], 50, 1, 0];
	};

};

if (_soundData isEqualTo []) exitWith {};





// Stop any existing sounds for the same enum
private _soundObjName = format [QGVAR(unit_soundObj_%1), _enum];
deleteVehicle (_unit getVariable [_soundObjName, objNull]);

// Stop any additional sounds, if requested
{
	deleteVehicle (_unit getVariable [format [QGVAR(unit_soundObj_%1), _x], objNull]);
} forEach _soundsToStop;

// Play the new sound
private _soundObj = _unit say3D _soundData;

_unit setVariable [_soundObjName, _soundObj, false];
