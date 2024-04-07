/* --------------------------------------------------------------------------------------------------------------------
	Author:	 Cre8or
	Description:
		[LA][GE]
		Makes the unit select the best available weapon (either primary or handgun). This considers the weapon
		state and available ammunition for each equipped weapon.
	Arguments:
		0:	<OBJECT>	The unit in question
		1:	<BOOLEAN>	Whether the unit should be forced into a suitable idle animation (optional,
					default: true)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

params [
	["_unit", objNull, [objNull]],
	["_forceAnim", true, [true]]
];

if (!alive _unit or {!local _unit}) exitWith {};





private _primary = primaryWeapon _unit;
private _handgun = handgunWeapon _unit;
private _weaponIndex = 0;

// Handle weapon selection
if (_primary != "" and {_unit ammo _primary > 0}) then {
	_unit selectWeapon _primary;
	_weaponIndex = 2;
} else {
	if (_handgun != "" and {_unit ammo _handgun > 0}) then {
		_unit selectWeapon _handgun;
		_weaponIndex = 1;
	} else {
		_unit action ["SwitchWeapon", _unit, _unit, 0];
	};
};

// Handle animations
if (_forceAnim and {vehicle _unit == _unit}) then {

	private _curAnim = animationState _unit;
	private _stance = stance _unit;

	// Fix prone healing animations being registered as "CROUCH"
	if (_curAnim == "AinvPpneMstpSlayWnonDnon_medic" or {_curAnim == "AinvPpneMstpSlayWnonDnon_medicOther"}) then {
		_stance = "PRONE";
	};

	private _anim = (switch (_stance) do {
		case "UNDEFINED";
		case "PRONE": {
			[
				"amovppnemstpsnonwnondnon",
				"amovppnemstpsraswpstdnon",
				"amovppnemstpsraswrfldnon"
			] # _weaponIndex;
		};
		case "CROUCH": {
			[
				"amovpknlmstpsnonwnondnon",
				"amovpknlmstpslowwpstdnon",
				"amovpknlmstpsraswrfldnon"
			] # _weaponIndex;

		};
		default {
			[
				"amovpercmstpsnonwnondnon",
				"amovpercmstpslowwpstdnon",
				"amovpercmstpsraswrfldnon"
			] # _weaponIndex;
		};
	});

	_unit playMoveNow _anim;
	[_unit, _anim] remoteExecCall ["switchMove", 0, false];
};
