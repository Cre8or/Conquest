/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles various serverside functionalities pertaining to entity deaths, such as score events.

		Only executed once by the server upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

if (!isServer) exitWith {};





// Set up some variables
MACRO_FNC_INITVAR(GVAR(EH_handleEntityDeath_entityKilled),-1);





// Handle vehicle kills
removeMissionEventHandler ["EntityKilled", GVAR(EH_handleEntityDeath_entityKilled)];
GVAR(EH_handleEntityDeath_entityKilled) = addMissionEventHandler ["EntityKilled", {

	params ["_obj", "_killer", "_instigator"];

	if (isNull _killer) then {
		_killer = _instigator;
	};

	private _sideObj    = _obj getVariable [QGVAR(side), sideEmpty];
	private _sideKiller = _killer getVariable [QGVAR(side), sideEmpty];

	// Only handle vehicles
	if (
		_obj isKindOf "Air"
		or {_obj isKindOf "LandVehicle"}
	) then {

		// Kill the crew
		{
			[
				_x,
				-1,
				MACRO_ENUM_DAMAGE_EXPLOSIVE,
				_obj,
				_killer,
				false,
				"",
				false
			] call FUNC(gm_processUnitDamage);
		} forEach (crew _obj select {alive _x});

		// If the vehicle belongs to a side, hand out a score
		if (_sideObj != sideEmpty) then {
			[
				_killer,
				[MACRO_ENUM_SCORE_DESTROYVEHICLE_ENEMY, MACRO_ENUM_SCORE_DESTROYVEHICLE_FRIENDLY] select (_sideObj == _sideKiller),
				_obj
			] call FUNC(gm_addScore);
		};
	};
}];
