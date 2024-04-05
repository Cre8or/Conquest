/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA][GE]
		Called whenever a local unit's "Killed" EH is executed.
		Used to handle various gamemode aspects, such as player respawning (in singleplayer), and increasing
		the danger level of an AI's currently travelled edge.
	Arguments:
		(see https://community.bistudio.com/wiki/Arma_3:_Event_Handlers#Killed)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"

// Passed by the engine
params [
	"_unit"
];

if (isNull _unit) exitWith {};





// Set up some variables
_unit setVariable [QGVAR(isSpawned), false, false];

// Clean up the unit's ammo data lookup table
deleteLocation (_unit getVariable [QGVAR(ammoLUT), locationNull]);

scopeName QGVAR(unit_onKilled_main);





// Danger level handling
if (
	!isPlayer _unit
	and {local _unit}
) then {

	if (_unit getVariable [QGVAR(ai_unitControl_moveToPos_finished), true]) then {
		breakto QGVAR(unit_onKilled_main);
	};

	// Fetch the unit's path data
	private _pathData   = _unit getVariable [QGVAR(ai_unitControl_moveToPos_pathData), []];
	private _pathIndex  = _unit getVariable [QGVAR(ai_unitControl_moveToPos_pathIndex), 0];
	private _nodesArray = _pathData param [2, []];
	private _prevNode   = _nodesArray param [_pathIndex - 1, objNull];
	private _curNode    = _nodesArray param [_pathIndex, objNull];

	if (alive _prevNode and {alive _curNode}) then {
		private _prevNodeID = _prevNode getVariable [QGVAR(nodeID), -1];
		private _curNodeID  = _curNode getVariable [QGVAR(nodeID), -1];
		private _unitSide   = _unit getVariable [QGVAR(side), sideEmpty];

		// Globally increase the danger level along this edge
		[_prevNodeID, _curNodeID, _prevNode getVariable [QGVAR(isVehNode), false], _unitSide] remoteExecCall [QFUNC(ai_increaseDangerLevel), 0, false];
	};
};





// Serverside AI respawn
if (isServer) then {
	private _unitIndex = _unit getVariable [QGVAR(unitIndex), -1];

	if (_unitIndex >= 0 and {_unitIndex < GVAR(param_ai_maxCount)}) then {
		GVAR(ai_sys_handleRespawn_respawnTimes) set [_unitIndex, time + MACRO_GM_UNIT_RESPAWNDELAY];
	};
};





// Singleplayer: allow the player to respawn
if (!isMultiplayer and {_unit == player}) then {
	private _grp = createGroup GVAR(side);
	private _newUnit = _grp createUnit [typeOf _unit, [0,0,0], [], 0, "CAN_COLLIDE"];

	// Mark the corpse as belonging to the player (other systems have to deduce this information from the corpse)
	_unit setVariable [QGVAR(cl_sp_isPlayer), true];

	// Switch units and reassign the curator module
	unassignCurator GVAR(curatorModule);
	selectPlayer _newUnit;
	_newUnit assignCurator GVAR(curatorModule);
	GVAR(curatorModule) addCuratorEditableObjects [[_newUnit], false];

	// Workaround for the curator module being unassigned when the corpse is removed (why does this happen?)
	_unit addEventHandler ["Deleted", {
		[] spawn {
			uiSleep 0.5;
			unassignCurator GVAR(curatorModule);
			player assignCurator GVAR(curatorModule);
		};
	}];

	GVAR(cl_sp_playerName)    = name _unit;
	GVAR(cl_sp_playerFace)    = face _unit;
	GVAR(cl_sp_playerSpeaker) = speaker _unit;
	GVAR(cl_sp_prevGroup)     = group _unit;

	// Reapply the previous player identity
	_newUnit addEventHandler ["HandleIdentity", {
		params ["_unit"];
		[_unit, GVAR(cl_sp_playerName), GVAR(cl_sp_playerFace), GVAR(cl_sp_playerSpeaker)] call FUNC(unit_setIdentityLocal);

		// Edge case: rejoin the group once the identity is handled, otherwise AI won't acknowledge its side
		private _grp = group _unit;
		[_unit] joinSilent GVAR(cl_sp_prevGroup);
		deleteGroup _grp;
		true;
	}];

	// Force a respawn
	GVAR(sys_handlePlayerRespawn_forceRespawn) = true;

	// DEBUG
	call FUNC(debug_addActions);

	// Remove Arma 3's built-in blur effect upon death (pops up sometimes)
	[] spawn {
		sleep 0.25;

		private "_handle";
		{
			if (!isNil _x) then {
				_handle = missionNamespace getVariable _x;

				if (_handle isEqualType 0 and {ppEffectEnabled _handle}) then {
					_handle ppEffectEnable false;
					//systemChat format ["Disabled radialBlur handle %1 (%2)", _handle, _x];
				};
			};
		} forEach [
			"BIS_fnc_healthEffects_radialBlur",
			"bis_deathradialblur",
			"bis_uncradialblur",
			"bis_deathblur",
			"bis_uncblur",
			"bis_suffblur",
			"RscMissionEnd_radialBlur",
			"bis_fnc_feedback_damageblur",
			"bis_fnc_feedback_damageradialblur"
		];
	};
};
