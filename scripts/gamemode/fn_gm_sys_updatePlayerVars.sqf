/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Monitors and updates the player's object variables in accordance to the gamemode's global vars.

		Only executed once by the client upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"
#include "..\..\res\macros\fnc_leaveGroup.inc"

// If this machine doesn't have an interface, do nothing
if (!hasInterface) exitWith {};





// Set up some variales
MACRO_FNC_INITVAR(GVAR(EH_sys_updatePlayerVars_eachFrame),-1);





removeMissionEventHandler ["EachFrame", GVAR(EH_sys_updatePlayerVars_eachFrame)];
GVAR(EH_sys_updatePlayerVars_eachFrame) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	// Set up some variables
	private _player = player;
	private _group  = group _player;

	// Broadcast the player's side (if it has been set)
	if (GVAR(side) != sideEmpty and {GVAR(side) != _player getVariable [QGVAR(side), sideEmpty]}) then {
		_player setVariable [QGVAR(side), GVAR(side), true];
	};

	// Broadcast the player's role
	if (GVAR(role) != _player getVariable [QGVAR(role), MACRO_ENUM_ROLE_INVALID]) then {
		_player setVariable [QGVAR(role), GVAR(role), true];
	};

	// Move the player into a new group on side changes
	if (side _group != GVAR(side)) then {
		MACRO_FNC_LEAVEGROUP(_group);
	};

	// Prevent the player from joing AI driver groups (redirect to the real group instead)
	if (_group getVariable [QGVAR(isVehicleGroup), false]) then {
		private _unit          = units _group select {!isPlayer _x} param [0, objNull];
		private _groupIndex    = _unit getVariable [QGVAR(groupIndex), 0];
		private _originalGroup = missionNamespace getVariable [format [QGVAR(AIGroup_%1_%2), GVAR(side), _groupIndex], grpNull];

		if (side _originalGroup == GVAR(side) and {_group != _originalGroup}) then {
			[_player] joinSilent _originalGroup;

		// Fallback: create a new group if the original AI group no longer exists
		} else {
			MACRO_FNC_LEAVEGROUP(_group);
		};
	};
}];
