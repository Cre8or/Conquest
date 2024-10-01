/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LA][GE]
		Moves a unit into an unconscious animation. To be used on a unit when it enters the unconscious state.
	Arguments:
		0:	<OBJECT>	The concerned unit
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

params [
	["_unit", objNull, [objNull]]
];

if (!local _unit or {vehicle _unit != _unit}) exitWith {};





// Set up some variables
MACRO_FNC_INITVAR(GVAR(anim_unconscious_anims), []);

if (GVAR(anim_unconscious_anims) isEqualTo []) then {
	if (GVAR(hasMod_ace_medical)) then {
		GVAR(anim_unconscious_anims) = [
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
		GVAR(anim_unconscious_anims) = [
			"Acts_StaticDeath_02",
			"Acts_StaticDeath_03",
			"Acts_StaticDeath_04",
			"Acts_StaticDeath_10"
		];
	};
};

private _anim = animationState _unit;





_unit removeEventHandler ["AnimStateChanged", _unit getVariable [QGVAR(anim_unconscious_EH), -1]];

// Play the animation immediately if the unit is ragdolled
if (
	!isAwake _unit
	and {_anim select [0, 11] != "unconscious"}
	and {_anim select [0, 24] != "ace_medical_engine_uncon"}
) then {
	_anim = selectRandom GVAR(anim_unconscious_anims);
	[_unit, _anim] remoteExecCall ["switchMove", 0, false];

// Otherwise, wait until the unit has ragdolled and then unragdolled, or we might skip the ragdoll
//  phase entirely and "snap" into the unconscious animation, which looks bad.
} else {
	_unit setVariable [QGVAR(anim_unconscious_EH), _unit addEventHandler ["AnimStateChanged", {
		params ["_unit", "_anim"];

		if (
			_anim select [0, 11] == "unconscious"
			or {_anim select [0, 24] == "ace_medical_engine_uncon"}
		) then {

			// Check if the unit is still unconscious, as a medic might already have revived them
			// while they've been ragdolled. We don't want to lock them in an animation that they
			// can't break out of!
			if (_unit getVariable [QGVAR(isUnconscious), false]) then {
				_anim = selectRandom GVAR(anim_unconscious_anims);
				[_unit, _anim] remoteExecCall ["switchMove", 0, false];
			};

			_unit removeEventHandler ["AnimStateChanged", _unit getVariable [QGVAR(anim_unconscious_EH), -1]];
		};

	}], false];
};
