/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[S]
		Handles various serverside functionalities to entity deaths, such as score events.

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
MACRO_FNC_INITVAR(GVAR(gm_sys_handleEntityDeaths_EH),-1);





// Handle vehicle kills
removeMissionEventHandler ["EntityKilled", GVAR(gm_sys_handleEntityDeaths_EH)];
GVAR(gm_sys_handleEntityDeaths_EH) = addMissionEventHandler ["EntityKilled", {

	params ["_obj", "_killer", "_instigator"];

	// Only handle vehicles
	if !(_obj isKindOf "Air" or {_obj isKindOf "LandVehicle"}) exitWith {};

	if (isNull _instigator or {!(_instigator isKindOf "Man")}) then {
		_instigator = _killer;
	};

	private _sideObj        = _obj getVariable [QGVAR(side), sideEmpty];
	private _sideInstigator = _instigator getVariable [QGVAR(side), sideEmpty];

	// Kill the crew
	{
		[
			_x,
			-1,
			MACRO_ENUM_DAMAGE_EXPLOSIVE,
			_killer,
			_instigator,
			false,
			"",
			false
		] call FUNC(gm_processUnitDamage);
	} forEach (crew _obj select {alive _x});

	// If the vehicle belongs to a side, hand out a score
	if (_sideObj != sideEmpty) then {
		[
			_instigator,
			[MACRO_ENUM_SCORE_DESTROYVEHICLE_ENEMY, MACRO_ENUM_SCORE_DESTROYVEHICLE_FRIENDLY] select (_sideObj == _sideInstigator),
			_obj
		] call FUNC(gm_addScore);
	};
}];
