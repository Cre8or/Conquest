/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA][LE]
		Sets up the identity of a unit with the provided name, face and speaker. Also applies the respective goggles
		onto the unit as defined in its role's loadout array (AI engine-level identity overrides goggles).
	Arguments:
		0:	<OBJECT>	The concerned unit
		1:	<STRING>	The unit's new name
		2:	<STRING>	The new face class
		3:	<STRING>	The new speaker class
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_unit", objNull, [objNull]],
	["_name", "", [""]],
	["_face", "", [""]],
	["_speaker", "", [""]]
];





if (_name != "") then {
	_unit setName _name;
};
if (_face != "") then {
	_unit setFace _face;
};
if (_speaker != "") then {
	_unit setSpeaker _speaker;
};

_unit setVariable [QGVAR(ai_name), _name, false];
_unit setVariable [QGVAR(ai_face), _face, false];
_unit setVariable [QGVAR(ai_speaker), _speaker, false];

// Reapply the laodout's goggles, if any are defined
private _side    = _unit getVariable [QGVAR(side), sideEmpty];
private _role    = _unit getVariable [QGVAR(role), MACRO_ENUM_ROLE_INVALID];
private _loadout = missionNamespace getVariable [format [QGVAR(loadout_%1_%2), _side, _role], []];
private _goggles = _loadout param [7, ""];

if (goggles _unit != _goggles) then {
	if (_goggles != "") then {
		_unit addGoggles _goggles;
	} else {
		removeGoggles _unit;
	};
};
