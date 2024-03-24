/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LE]
		Registers CBA keybindings to the custom gamemode actions.

		Only executed on the client.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "\a3\editor_f\Data\Scripts\dikCodes.h"

#include "..\..\res\common\macros.inc"
#include "..\..\res\macros\fnc_initVar.inc"





// Target spotting
[
	"Conquest",
	QGVAR(spotTarget),
	"Spot target",
	{call FUNC(kb_spotTarget)},
	{false},
	[41, [true, false, false]], // Shift + Tilda (hold)
	false,
	0,
	true
] call CBA_fnc_addKeybind;

// Copy all keybindings from the original pointing function over
if (!isNil "cba_keybinding_actions") then {
	private _keybindKey  = format ["%1$%2", "Conquest", QGVAR(spotTarget)];
	private _keybindData = cba_keybinding_actions getVariable [_keybindKey, []];

	if (_keybindData isNotEqualTo []) then {
		private _keybinds = (["ACE3 Common", "ace_finger_finger"] call CBA_fnc_getKeybind) param [8, []];

		if (_keybinds isNotEqualTo []) then {
			_keybindData set [2, _keybinds];
			cba_keybinding_actions setVariable [_keybindKey, _keybindData];
		};
	};
};

// Discard ACE's original pointing function
if (GVAR(hasMod_ace_finger)) then {
	[
		"ACE3 Common",
		"ace_finger_finger",
		"",
		{false},
		{false}
	] call CBA_fnc_addKeybind;
};

// Spawn menu
[
	"Conquest",
	QGVAR(toggleSpawnMenu),
	"Open/close spawn menu",
	{call FUNC(kb_toggleSpawnMenu)},
	{false},
	[MACRO_KEYBIND_TOGGLESPAWNMENU, [true, false, false]],
	false,
	0,
	true
] call CBA_fnc_addKeybind;

// Healing
[
	"Conquest",
	QGVAR(healUnit),
	"Heal other unit",
	{call FUNC(kb_healUnit)},
	{false},
	[MACRO_KEYBIND_HEAL, [false, false, false]],
	false,
	0,
	true
] call CBA_fnc_addKeybind;




// Add compatibility for ACE's custom events
if (GVAR(hasMod_ace_throwing)) then {
	MACRO_FNC_INITVAR(GVAR(EH_ace_firedPlayer), -1);

	["ace_firedPlayer", GVAR(EH_ace_firedPlayer)] call CBA_fnc_removeEventHandler;
	GVAR(EH_ace_firedPlayer) = ["ace_firedPlayer", FUNC(unit_onFired)] call CBA_fnc_addEventHandler;
};
