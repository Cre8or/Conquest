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
	MACRO_MISSION_FRAMEWORK_GAMEMODE,
	QGVAR(kb_spotTarget),
	"Spot target",
	{call FUNC(act_spotTarget)},
	{false},
	[41, [true, false, false]], // Shift + Tilda (hold)
	false,
	0,
	false
] call CBA_fnc_addKeybind;

// Copy all keybindings from the original pointing function over
if (!isNil "cba_keybinding_actions") then {
	private _keybindKey  = format ["%1$%2", MACRO_MISSION_FRAMEWORK_GAMEMODE, QGVAR(spotTarget)];
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
	MACRO_MISSION_FRAMEWORK_GAMEMODE,
	QGVAR(kb_toggleSpawnMenu),
	"Open/close spawn menu",
	{call FUNC(act_toggleSpawnMenu)},
	{false},
	[MACRO_KEYBIND_TOGGLESPAWNMENU, [true, false, false]],
	false,
	0,
	false
] call CBA_fnc_addKeybind;

// Healing
[
	MACRO_MISSION_FRAMEWORK_GAMEMODE,
	QGVAR(kb_healUnit),
	"Heal unit/self",
	{([player] call FUNC(act_tryHealUnit)) param [0, false]},
	{false},
	[MACRO_KEYBIND_HEAL, [false, false, false]],
	true,
	0,
	false
] call CBA_fnc_addKeybind;

// Give up (unconscious HUD)
GVAR(kb_act_pressed_giveUp) = false;
[
	MACRO_MISSION_FRAMEWORK_GAMEMODE,
	QGVAR(kb_giveUp),
	"Give up (unconscious)",
	{GVAR(kb_act_pressed_giveUp) = true},
	{GVAR(kb_act_pressed_giveUp) = false},
	[MACRO_KEYBIND_GIVEUP, [false, false, false]],
	false,
	0,
	false
] call CBA_fnc_addKeybind;





// Add compatibility for ACE's custom events
if (GVAR(hasMod_ace_throwing)) then {
	MACRO_FNC_INITVAR(GVAR(EH_ace_firedPlayer), -1);

	["ace_firedPlayer", GVAR(EH_ace_firedPlayer)] call CBA_fnc_removeEventHandler;
	GVAR(EH_ace_firedPlayer) = ["ace_firedPlayer", FUNC(unit_onFired)] call CBA_fnc_addEventHandler;
};
