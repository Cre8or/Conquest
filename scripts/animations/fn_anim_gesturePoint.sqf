/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LA][GE]
		Plays a pointing gesture on the given unit. If ACE3 is loaded, the mod's gestures will be used instead
		of the vanilla ones.
	Arguments:
		0:	<OBJECT>	The unit performing the pointing gesture
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_unit", objNull, [objNull]]
];

if (!local _unit or {vehicle _unit != _unit} or {!([_unit] call FUNC(unit_isAlive))}) exitWith {};





private _stance   = stance _unit;
private _moveType = toLower animationState _unit select [9, 3];

if (
	_stance != "PRONE"
	and {weaponState _unit # 6 == 0}
	and {cameraView != "GUNNER"}
	and {_moveType in ["wlk", "tac", "run", "eva", "spr"]} // Unit is moving (if they're stopped, they're likely trying to shoot)
) then {

	if (GVAR(hasMod_ace_finger)) then {
		private _weaponLowered = animationState _unit select [12, 4] == "slow";

		if (_stance == "STAND" and {currentWeapon _unit == "" or {_weaponLowered}}) then {
			_unit playAction "ace_gestures_pointstandlowered";
		} else {
			_unit playAction "ace_gestures_point";
		};

	} else {
		_unit playAction "GestureGo";
	};
};
