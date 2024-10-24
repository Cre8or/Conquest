/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Enforces the player group's radio channel as assigned by acre_sys_assignChannels. Also ensures that the player
		always has access to only one radio.

		Only executed once by the client upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

if (!hasInterface or {!GVAR(hasMod_acre)}) exitWith {};





MACRO_FNC_INITVAR(acre_sys_data_radioData, locationNull); // Interface with ACRE

MACRO_FNC_INITVAR(GVAR(acre_sys_handleRadios_EH), -1);





removeMissionEventHandler ["EachFrame", GVAR(acre_sys_handleRadios_EH)];
GVAR(acre_sys_handleRadios_EH) = addMissionEventHandler ["EachFrame", {

	if (GVAR(missionState) > MACRO_ENUM_MISSION_LIVE) exitWith {};

	private _player      = player;
	private _veh         = vehicle _player;
	private _targetRadio = [MACRO_ACRE2_RADIO_CLASSNAME] call acre_api_fnc_getRadioByType;

	// Ensure the player has a proper radio
	if (isNil "_targetRadio" or {_targetRadio == ""}) exitWith {
		if !([_player, MACRO_ACRE2_RADIO_CLASSNAME] call acre_api_fnc_hasKindOfRadio) then {
			_player addItem MACRO_ACRE2_RADIO_CLASSNAME;
			systemChat format ["[ACRE] (%1) Added base radio: %2", time, MACRO_ACRE2_RADIO_CLASSNAME];
		};
	};

	// Remove all vehicle rack radios
	if (_veh != _player) then {
		_veh setVariable ["acre_sys_rack_queue", [], false];
		_veh setVariable ["acre_sys_rack_vehicleRacks", [], false];
	};

	// Delete any additional radios the player might have
	{
		if (_x != _targetRadio) then {
			_player removeItem _x;
			systemChat format ["[ACRE] (%1) Removed non-standard radio: %2", time, _x];
		};
	} forEach (call acre_api_fnc_getCurrentRadioList);

	// Switch to the correct radio
	if (_targetRadio != (call acre_api_fnc_getCurrentRadio)) then {
		[_targetRadio] call acre_api_fnc_setCurrentRadio;
	};



	// Force the player radio to stay on the group's channel
	private _group         = group _player;
	private _curChannel    = [_targetRadio] call acre_api_fnc_getRadioChannel;
	private _targetChannel = _group getVariable [QGVAR(acre_channel), -1];

	// If the player's current group is invalid (has no target channel), turn the radio off so they
	// can't keep broadcasting
	private _radioData = acre_sys_data_radioData getVariable [_targetRadio, locationNull];
	_radioData setVariable ["radioOn", parseNumber (_targetChannel >= 0)];

	if (_targetChannel > 0 and {_curChannel != _targetChannel}) then {
		systemChat format ["[ACRE] (%1) Set channel (%2) to %3", time, _targetRadio, _targetChannel];
		[_targetRadio, _targetChannel] call acre_api_fnc_setRadioChannel;
	};
}];
