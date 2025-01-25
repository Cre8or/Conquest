/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LE]
		Fetches the assigned keybinding for a given action and returns the first bound key's localised string.
	Arguments:
		0:	<STRING>	Name of the registering mod
		1:	<STRING>	Unique ID of the key action
	Returns:
		    <STRING>    The first bound key's localised string
-------------------------------------------------------------------------------------------------------------------- */

#include "\a3\editor_f\Data\Scripts\dikCodes.h"

#include "..\..\res\common\macros.inc"

params [
	["_modName", "", [""]],
	["_actionID", "", [""]]
];





// Retrieve the first keybinding
private _keyBind = [_modName, _actionID] call CBA_fnc_getKeybind;
private ["_keyBindStr"];

if (!isNil "_keyBind") then {
	_keyBind = _keyBind param [5, []];
};

// Localisation
if (_keyBind isEqualTo []) then {
	_keyBindStr = localize LSTRING(kb_unassignedKey);
} else {
	_keyBindStr = _keyBind call CBA_fnc_localizeKey;
};

_keyBindStr;
