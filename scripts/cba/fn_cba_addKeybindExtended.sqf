/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LE]
		Adds a CBA keybind with multiple default keys. Extended version of CBA's own addKeybind function.
		NOTE: This function will always overwrite existing keybindings.
	Arguments:
		0:	<STRING>	Name of the registering mod
		1:	<STRING>	Unique ID of the key action
		2:	<STRING>	Pretty name of the action, or...
			<ARRAY>		...an array of pretty name and tooltip
	    3:	<CODE>		Code for down event (empty string for no code) (optional, default: "")
			<STRING>
	    4:	<CODE>		Code for up event (empty string for no code) (optional, default: "")
			<STRING>
		5:	<ARRAY>		Nested keybinds array in format [key, [shift, ctrl, alt]] (optional, default: [])
		6:	<BOOLEAN>	Whether the action should be repeated if the keybind is held (optional, default: false)
		7:	<NUMBER>	The repeat delay, in seconds (optional, default: 0)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "\a3\editor_f\Data\Scripts\dikCodes.h"

#include "..\..\res\common\macros.inc"

params [
	["_modName", "", [""]],
	["_actionID", "", [""]],
	["_title", "", ["", []]],
	["_downCode", {}, [{}, ""]],
	["_upCode", {}, [{}, ""]],
	["_keyBinds", [], [[]]],
	["_isRepeatable", false, [false]],
	["_repeatDelay", 0, [0]]
];

// Validate the parameters
if (_keyBinds isEqualTo []) then {
	_keyBinds = [[0, [false, false, false]]];
};

if (_upCode isEqualTo "") then {
	_upCode = {};
};
if (_downCode isEqualTo "") then {
	_downCode = {};
};




// Remove any duplicate keybinds
_keyBinds = _keyBinds arrayIntersect _keyBinds;

// Register the first keybind
[_modName, _actionID, _title, _downCode, _upCode, _keyBinds # 0, _isRepeatable, _repeatDelay, true] call CBA_fnc_addKeybind;

// Register any additional keybinds
// Any additional code snippets are derived from:
// 	https://github.com/CBATeam/CBA_A3/blob/master/addons/keybinding/fnc_addKeybind.sqf
private _action = toLower format ["%1$%2", _modName, _actionID];

// Filter out null bindings
_keybinds = _keybinds select {_x # 0 > DIK_ESCAPE};

for "_i" from 1 to (count _keyBinds) - 1 do {
	_keyBind = _keyBinds # _i;



	// Add this action to all keybinds
    if (_downCode isNotEqualTo {}) then {
        [_keyBind # 0, _keybind # 1, _downCode, "keyDown", format ["%1_down_%2", _action, _i], _isRepeatable, _repeatDelay] call CBA_fnc_addKeyHandler;
    };

    if (_upCode isNotEqualTo {}) then {
        [_keyBind # 0, _keybind # 1, _upCode, "keyUp", format ["%1_up_%2", _action, _i]] call CBA_fnc_addKeyHandler;
    };

	// Emit an event that a key has been registered
	_eventData = [_modName, _actionID, _title, _downCode, _upCode, _keyBind, _isRepeatable, _repeatDelay, _overwrite];
	["cba_keybinding_registerKeybind", _eventData] call CBA_fnc_localEvent;
};
