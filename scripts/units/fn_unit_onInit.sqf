/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA][LE]
		Initialises the specified unit by adding gamemode-relevant event handlers.

		Executed on every machine whenever a unit (player or AI) is (re)spawned.
	Arguments:
		0:	<OBJECT>	The unit to initialise
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_unit", objNull, [objNull]]
];

if (isNull _unit) exitWith {};





// Shared (player and AI)
_unit removeAllEventHandlers "HandleDamage"; // Removes any modded event handlers (e.g. ACE3)
_unit setVariable [QGVAR(EH_unit_onHandleDamage), _unit addEventHandler ["HandleDamage", FUNC(unit_onHandleDamage)], false];

if (hasInterface) then {
	_unit removeEventHandler ["HitPart", _unit getVariable [QGVAR(EH_unit_onHitPart), -1]];
	_unit setVariable [QGVAR(EH_unit_onHitPart), _unit addEventHandler ["HitPart", FUNC(unit_onHitPart)], false];
};

_unit removeEventHandler ["Killed", _unit getVariable [QGVAR(EH_unit_onKilled), -1]];
_unit setVariable [QGVAR(EH_unit_onKilled), _unit addEventHandler ["Killed", FUNC(unit_onKilled)], false];

_unit removeEventHandler ["FiredMan", _unit getVariable [QGVAR(EH_unit_onFired), -1]];
_unit setVariable [QGVAR(EH_unit_onFired), _unit addEventHandler ["FiredMan", FUNC(unit_onFired)], false];

_unit removeEventHandler ["Reloaded", _unit getVariable [QGVAR(EH_unit_onReloaded), -1]];
_unit setVariable [QGVAR(EH_unit_onReloaded), _unit addEventHandler ["Reloaded", FUNC(unit_onReloaded)], false];

private _local = local _unit;
_unit setVariable [QGVAR(canCaptureSectors), true, _local];
_unit setVariable [QGVAR(health), 1, _local];
_unit setVariable [QGVAR(isSpawned), true, _local]; // Interfaces with drawUnitIcons2D and drawIcons3D

_unit setVariable [QGVAR(lo_addOverallAmmo_accumulator), 0, false]; // Interfaces with lo_addOverallAmmo


// Disable stamina
if (_local) then {
	_unit enableFatigue false;
};




/*
// ================ safeStart_unit ================
// Attach an EH to the unit that detects when it is firing
if !(_unit getVariable [QGVAR(safeStart_hasEH), false]) then {
	_unit setVariable [QGVAR(safeStart_hasEH), true, false];

	_unit addEventHandler ["FiredMan", {
		params ["_unit", "", "", "", "", "", "_projectile"];

		// If safeStart is on, remove the projectile
		if (GVAR(safeStart)) then {
			deleteVehicle _projectile;
		};
	}];
};

_unit allowDamage (!_enabled);
*/





// Player specific
if (isPlayer _unit) then {

	// In multiplayer, the player unit is preserved between respawns. As such, the cleanup time
	// also persists, leading to erroneous behaviour when the player dies again.
	// To fix this, pretend it's a fresh unit.
	_unit setVariable [QGVAR(gm_sys_removeCorpses_removalTime), -1, false];

	// Add compatibility for ACE's custom events
	if (GVAR(hasMod_ace_throwing)) then {
		["ace_firedPlayer", _unit getVariable [QGVAR(EH_unit_ace_firedPlayer), -1]] call CBA_fnc_removeEventHandler;
		_unit setVariable [QGVAR(EH_unit_ace_firedPlayer), ["ace_firedPlayer", {
			_this params ["", "_weapon"];

			// We only care about thrown items, to support ACE throwing.
			// Everything else is already handled by the default "FiredMan" EH.
			if (_weapon == "Throw") then {
				_this call FUNC(unit_onFired);
			};
		}] call CBA_fnc_addEventHandler, false];
	};

// AI specific
} else {
	[true, MACRO_ENUM_AI_PRIO_BASESETTINGS, _unit, "AUTOCOMBAT", false] call FUNC(ai_toggleFeature);
/*
	// Reset the unit's movement time when firing (prevents it from being flagged as stuck)
	_unit removeEventHandler ["Fired", _unit getVariable [QGVAR(EH_stuckDetection_fired), -1]];
	_unit setVariable [QGVAR(EH_stuckDetection_fired), _unit addEventHandler ["Fired", {
		params ["_unit"];

		_unit setVariable [QGVAR(lastMovedTime), time, false];
	}], false];
*/
};
