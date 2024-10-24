/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles the assigned radio channels for all valid groups. Channels are randomised on assignment to harden
		against eavesdropping, and recycled when groups are no longer valid.

		Only executed once by the server upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"
#include "..\..\res\macros\cond_isValidGroup.inc"

if (!isServer or {!GVAR(hasMod_acre)}) exitWith {};





MACRO_FNC_INITVAR(GVAR(acre_sys_assignChannels_EH), -1);

GVAR(acre_sys_assignChannels_init)       = false;
GVAR(acre_sys_assignChannels_nextUpdate) = 0;
GVAR(acre_sys_assignChannels_free)       = [];
GVAR(acre_sys_assignChannels_groups)     = [];




removeMissionEventHandler ["EachFrame", GVAR(acre_sys_assignChannels_EH)];
GVAR(acre_sys_assignChannels_EH) = addMissionEventHandler ["EachFrame", {

	if (GVAR(missionState) > MACRO_ENUM_MISSION_LIVE) exitWith {};

	private _time = time;

	if (_time < GVAR(acre_sys_assignChannels_nextUpdate)) exitWith {};



	// Init: randomise the pool of available channels
	if (!GVAR(acre_sys_assignChannels_init)) then {
		GVAR(acre_sys_assignChannels_init) = true;

		{
			_x setVariable [QGVAR(acre_channel), -1, true];
		} forEach allGroups;

		GVAR(acre_sys_assignChannels_free) resize MACRO_ACRE2_AVAILABLECHANNELS;
		for "_i" from 1 to MACRO_ACRE2_AVAILABLECHANNELS do {
			GVAR(acre_sys_assignChannels_free) set [_i - 1, _i];
		};
	};



	// Handle channel removal from known groups
	{
		_x params ["_group", "_channel"];

		if !(MACRO_COND_ISVALIDGROUP(_group)) then {
			GVAR(acre_sys_assignChannels_groups) deleteAt _forEachIndex;
			GVAR(acre_sys_assignChannels_free) pushBack _channel;

			_group setVariable [QGVAR(acre_channel), -1, true];

			//systemChat format ["[ACRE] Revoked channel %1 from group %2", _channel, _group];
		};
	} forEachReversed GVAR(acre_sys_assignChannels_groups);

	// Handle channel assignment for unassigned groups
	{
		_channel = _x getVariable [QGVAR(acre_channel), -1];

		// Skip known groups (optimisation)
		if (_channel >= 0) then {
			continue;
		};

		// Skip invalid groups
		if !(MACRO_COND_ISVALIDGROUP(_x)) then {
			continue;
		};

		private _count = count GVAR(acre_sys_assignChannels_free);

		// Failsafe
		if (_count <= 0) then {
			private _str = "[CONQUEST] (ACRE2) ERROR: Ran out of free channels to assign!";
			diag_log _str;
			systemChat _str;
			continue;
		};

		// Assign a free channel
		_channel = GVAR(acre_sys_assignChannels_free) deleteAt (floor random _count);

		GVAR(acre_sys_assignChannels_groups) pushBack [_x, _channel];
		_x setVariable [QGVAR(acre_channel), _channel, true];

		//systemChat format ["[ACRE] Assigned channel %1 to group %2", _channel, _x];
	} forEach allGroups;

	GVAR(acre_sys_assignChannels_nextUpdate) = _time + MACRO_ACRE2_SYS_ASSIGNCHANNELS_INTERVAL;
}];
