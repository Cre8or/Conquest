/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LA][GE]
		Moves a unit into an unconscious animation. To be used on a unit when it enters the unconscious state and is
		still ragdolled.
	Arguments:
		0:	<OBJECT>	The concerned unit
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_unit", objNull, [objNull]]
];

if (!local _unit or {vehicle _unit != _unit}) exitWith {};





// Set up some variables
GVAR(anim_unconscious_newAnim) = (
	if (GVAR(hasMod_ace_medical)) then {
		selectRandom [
			"ace_medical_engine_uncon_anim_1",
			"ace_medical_engine_uncon_anim_1_1",
			"ace_medical_engine_uncon_anim_2",
			"ace_medical_engine_uncon_anim_2_1",
			"ace_medical_engine_uncon_anim_3",
			"ace_medical_engine_uncon_anim_3_1",
			"ace_medical_engine_uncon_anim_4",
			"ace_medical_engine_uncon_anim_4_1",
			"ace_medical_engine_uncon_anim_5",
			"ace_medical_engine_uncon_anim_5_1",
			"ace_medical_engine_uncon_anim_6",
			"ace_medical_engine_uncon_anim_6_1",
			"ace_medical_engine_uncon_anim_7",
			"ace_medical_engine_uncon_anim_7_1",
			"ace_medical_engine_uncon_anim_8",
			"ace_medical_engine_uncon_anim_8_1",
			"ace_medical_engine_uncon_anim_9"
		];
	} else {
		selectRandom [
			"Acts_StaticDeath_02",
			"Acts_StaticDeath_03",
			"Acts_StaticDeath_04",
			"Acts_StaticDeath_10"
		];
	}
);





// Play the animation immediately if the unit is alive and not ragdolled
if ([_unit] call FUNC(unit_isAlive) and {isAwake _unit}) then {
	[_unit, GVAR(anim_unconscious_newAnim)] remoteExecCall ["switchMove", 0, false];

// Otherwise, wait until after the unit has moved out of the ragdoll phase
} else {
	_unit removeEventHandler ["AnimStateChanged", _unit getVariable [QGVAR(anim_unconscious_EH), -1]];
	_unit setVariable [QGVAR(anim_unconscious_EH), _unit addEventHandler ["AnimStateChanged", {
		params ["_unit", "_anim"];

		if (
			_anim select [0, 34] == "ace_medical_engine_uncon_anim_face"
			or {_anim select [0, 11] == "unconscious"}
		) then {

			// Check if the unit is still unconscious, as a medic might already have revived them
			// while they've been ragdolled. We don't want to lock them in an animation that they
			// can't break out of!
			if (_unit getVariable [QGVAR(isUnconscious), false]) then {
				[_unit, GVAR(anim_unconscious_newAnim)] remoteExecCall ["switchMove", 0, false];
			};

			_unit removeEventHandler ["AnimStateChanged", _unit getVariable [QGVAR(anim_unconscious_EH), -1]];
		};

	}], false];
};
