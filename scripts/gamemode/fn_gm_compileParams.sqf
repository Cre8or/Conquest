/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		(Re)compiles the mission parameters. This considers the parameters that were set during slotting (in
		multiplayer), aswell as the default parameters set inside settings.inc.

		Only executed once by all machines upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"




diag_log format ["[CONQUEST] Param values: %1", missionNamespace getVariable ["paramsArray", []]];

// Fetch all mission parameters
private ["_name", "_value", "_override"];
{
	_name = configName _x;

	if (_name select [0, 6] != "header") then {

		_value    = [_name, -9e9] call BIS_fnc_getParamValue;
		_override = missionNamespace getVariable [format [QGVAR(%1_override), _name], _value];
		diag_log format ["[CONQUEST] Parameter ""%1"": %2 (%3)", _name, _value, _override];

		// DEBUG
		if (_value <= -9e9) then {
			private _valueRaw = getMissionConfigValue [_name, "???"];
			diag_log format ["[CONQUEST] -> Raw value: %1 (%2)", _valueRaw, typeName _valueRaw];
		};


		// Enable manual overriding
		if (_override isNotEqualTo _value) then {
			missionNamespace setVariable [format [QGVAR(%1), _name], _override, false];

		// Normal behaviour
		} else {
			if (getNumber (_x >> "isBoolean") != 0) then {
				missionNamespace setVariable [format [QGVAR(%1), _name], _value > 0, false];
			} else {
				missionNamespace setVariable [format [QGVAR(%1), _name], _value, false];
			};
		};
	};

} forEach ("true" configClasses (missionConfigFile >> "Params"));
