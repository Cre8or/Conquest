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
private _keyBinds = [
	[41, [true, false, false]] // Shift + Tilde
];

// Transfer all keybindings from the original ACE3 pointing function
if (GVAR(hasMod_ace_finger)) then {
	private _keyBindsACE = (["ACE3 Common", "ace_finger_finger"] call CBA_fnc_getKeybind) param [8, []];
	_keyBinds = _keyBinds + _keyBindsACE;

	[
		MACRO_MISSION_FRAMEWORK_GAMEMODE,
		QGVAR(kb_spotTarget),
		"Spot target",
		{call FUNC(act_spotTarget)},
		"",
		_keyBinds,
		false,
		0
	] call FUNC(cba_addKeybindExtended);

	// Discard ACE's original pointing function
	[
		"ACE3 Common",
		"ace_finger_finger",
		"(Disabled in Conquest)",
		{false}, // Must be false to overwrite
		{false}
	] call CBA_fnc_addKeybind;

} else {
	[
		MACRO_MISSION_FRAMEWORK_GAMEMODE,
		QGVAR(kb_spotTarget),
		"Spot target",
		{call FUNC(act_spotTarget)},
		"",
		_keyBinds # 0,
		false,
		0,
		false
	] call CBA_fnc_addKeybind;
};



// Spawn menu
[
	MACRO_MISSION_FRAMEWORK_GAMEMODE,
	QGVAR(kb_toggleSpawnMenu),
	"Open/close spawn menu",
	{call FUNC(act_toggleSpawnMenu)},
	"",
	[MACRO_KEYBIND_TOGGLESPAWNMENU, [true, false, false]],
	false,
	0,
	false
] call CBA_fnc_addKeybind;



// Role action: resupplying
[
	MACRO_MISSION_FRAMEWORK_GAMEMODE,
	QGVAR(kb_resupplyUnit),
	"Resupply unit/self",
	{([player] call FUNC(act_tryResupplyUnit)) param [0, false]},
	"",
	[MACRO_KEYBIND_RESUPPLY, [false, false, false]],
	true,
	0,
	false
] call CBA_fnc_addKeybind;


/*
// Role action: Repairing
[
	MACRO_MISSION_FRAMEWORK_GAMEMODE,
	QGVAR(kb_repairVehicle),
	"Repair vehicle",
	{([player] call FUNC(act_tryHealUnit)) param [0, false]},
	"",
	[MACRO_KEYBIND_REPAIR, [false, false, false]],
	true,
	0,
	false
] call CBA_fnc_addKeybind;
*/


// Role action: Healing
[
	MACRO_MISSION_FRAMEWORK_GAMEMODE,
	QGVAR(kb_healUnit),
	"Heal unit/self",
	{([player] call FUNC(act_tryHealUnit)) param [0, false]},
	"",
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
