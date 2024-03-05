/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LA][GE]
		Plays a dodging movement animation on the given unit towards the specified position.
		Dodging is a single-shot action, not continuous. The "MOVE" AI feature will be toggled for the duration
		of the animation, and re-enabled afterwards.
	Arguments:
		0:	<OBJECT>	The dodging unit
		1:	<ARRAY>		The position the unit should dodge towards
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_unit", objNull, [objNull]],
	["_pos", [], [[]]]
];

if (!local _unit or {vehicle _unit != _unit} or {_pos isEqualTo []} or {!([_unit] call FUNC(unit_isAlive))}) exitWith {};

// Enforce correct stances
private _stance = toUpper stance _unit;
if !(_stance in ["STAND", "CROUCH", "PRONE"]) exitWith {};




// Set up some variables
private _dir    = _unit getRelDir _pos;
private _weapon = currentWeapon _unit;
private _anim   = "";
private ["_compPose", "_compMove", "_compStance", "_compWeapon"];
private _compDir = "";





// Weapon
if (_weapon != "") then {
	_compWeapon = switch (_weapon) do {
		case primaryWeapon _unit:   {"rfl"};
		case handgunWeapon _unit:   {"pst"};
		case secondaryWeapon _unit: {"lnr"};
		default                     {"non"};
	};
} else {
	_compWeapon = "non";
};

// Stance, speed, direction
if (_stance == "PRONE") then {
	_compDir = ["l", "r"] select (_dir < 180);

	if (_compWeapon == "non") then {
		_anim = format ["AmovPpneMstpSnonWnonDnon_AmovPpneMevaSnonWnonD%1", _compDir];
	} else {
		_anim = format ["AmovPpneMstpSrasW%1Dnon_AmovPpneMevaSlowW%1D%2", _compWeapon, _compDir];
	};

} else {
	_compPose = ["knl", "erc"] select (_stance == "STAND");

	switch (round (_dir / 45)) do {
		case 1: {_compMove = "eva", _compDir = "fr"};
		case 2: {_compMove = "run", _compDir = "r"};
		case 3: {_compMove = "run", _compDir = "br"};
		case 4: {_compMove = "run", _compDir = "b"};
		case 5: {_compMove = "run", _compDir = "bl"};
		case 6: {_compMove = "run", _compDir = "l"};
		case 7: {_compMove = "eva", _compDir = "fl"};
		default {_compMove = "eva", _compDir = "f"};
	};

	_compStance = switch (_compWeapon) do {
		case "non": {
			"non"
		};
		case "pst": {
			if (_compPose == "knl" and {_compMove == "eva"}) then {
				"ras"; // There is no lowered sprint animation when crouched with a pistol
			} else {
				["low", "ras"] select (animationstate _unit select [13, 3] == "ras")
			};
		};
		case "lnr": {
			["ras", "low"] select (_compMove == "eva")
		};
		default {
			["low", "ras"] select (animationstate _unit select [13, 3] == "ras")
		};
	};

	_anim = format ["AmovP%1M%2S%3W%4D%5", _compPose, _compMove, _compStance, _compWeapon, _compDir];
};





_unit playMoveNow _anim;

// Special case: AI need their "ANIM" feature disabled for the duration of the animation
if (!isPlayer _unit) then {

	// Disabling "ANIM" has the side-effect of disabling collision checks with objects.
	// AI units may then clip into rocks, walls, buildings, other vehicles, etc.
	// To try and prevent this, we perform an intersection check (costly, but necessary).
	private _dirRounded = switch (toLower _compDir) do {
		case "fr": {45};
		case "r":  {90};
		case "br": {135};
		case "b":  {180};
		case "bl": {225};
		case "l":  {270};
		case "fl": {315};
		default    {0};
	};
	private _unitPos = getPosWorld _unit vectorAdd [0, 0, 1];
	private _moveDir = _unit vectorModelToWorld [sin _dirRounded, cos _dirRounded, 0];
	private _canMove = true;

	{
		_x params ["", "", "_intersectObj"];

		if (!isNull _intersectObj and {!(_intersectObj isKindOf "Man")}) then {
			_canMove = false;
		};
	} forEach lineIntersectsSurfaces [
		_unitPos,
		_unitPos vectorAdd (_moveDir vectorMultiply 3),
		_unit,
		objNull,
		true,
		3,
		"GEOM"
	];

	// If nothing's in the way, we expect that it's safe to disable the "ANIM" feature
	if (_canMove) then {
		[true, MACRO_ENUM_AI_PRIO_DODGEVEHICLE, _unit, "ANIM", false] call FUNC(ai_toggleFeature);

		// Turn the "ANIM" feature back on
		_unit removeEventHandler ["AnimDone", _unit getVariable [QGVAR(anim_dodge_EH), -1]];
		_unit setVariable [QGVAR(anim_dodge_EH), _unit addEventHandler ["AnimDone", {
			params ["_unit"];

			[false, MACRO_ENUM_AI_PRIO_DODGEVEHICLE, _unit, "ANIM"] call FUNC(ai_toggleFeature);

			_unit removeEventHandler ["AnimDone", _unit getVariable [QGVAR(anim_dodge_EH), -1]];
		}], false];

	// Otherwise, turn the feature back on (in case the unit is already/still dodging)
	} else {
		[false, MACRO_ENUM_AI_PRIO_DODGEVEHICLE, _unit, "ANIM"] call FUNC(ai_toggleFeature);

		_unit removeEventHandler ["AnimDone", _unit getVariable [QGVAR(anim_dodge_EH), -1]];
	};
};
