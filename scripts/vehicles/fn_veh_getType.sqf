/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA]
		Returns the objet's vehicle type enum. For a list of possible values, see macros.inc.
	Arguments:
		0:	<OBJECT>	The vehicle to be inspected
	Returns:
			<NUMBER>	The object's vehicle type enum
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_class", "", [""]]
];

if (_class == "") exitWith {MACRO_ENUM_VEHICLETYPE_UNKNOWN};





// Fetch the vehicle's type enum from the namespace
private _namespace = missionNamespace getVariable [QGVAR(ns_veh_getVehType), locationNull];
private _vehType = _namespace getVariable _class;

// If it doesn't exist yet, determine it
if (isNil "_vehType") then {

	_vehType = MACRO_ENUM_VEHICLETYPE_UNKNOWN;

	// Ensure that the namespace exists
	if (isNull _namespace) then {
		_namespace = createLocation ["NameVillage", [0,0,0], 0, 0];
		missionNamespace setVariable [QGVAR(ns_veh_getVehType), _namespace, false];
	};

	scopeName "getVehType";

	private _config = configFile >> "CfgVehicles" >> _class;
	private _nameSound = toLower getText (_config >> "nameSound");
	switch (toLower getText (_config >> "simulation")) do {

		case "carx": {

			// Special cases
			if (_class isKindOf "AFV_Wheeled_01_base_F") then {	// Rhino MGS
				_vehType = MACRO_ENUM_VEHICLETYPE_TANK;
				breakTo "getVehType";
			};

			switch (_nameSound) do {
				case "veh_vehicle_mrap_s": {
					_vehType = MACRO_ENUM_VEHICLETYPE_MRAP;
				};
				case "veh_vehicle_truck_s": {
					_vehType = MACRO_ENUM_VEHICLETYPE_TRUCK;
				};
				case "veh_vehicle_apc_s": {
					_vehType = MACRO_ENUM_VEHICLETYPE_APC;
				};
				default {
					_vehType = MACRO_ENUM_VEHICLETYPE_CAR;
				};
			};
		};

		case "tankx": {

			// Special cases
			switch (toLower getText (_config >> "editorSubcategory")) do {
				case "edsubcat_aas": {
					_vehType = MACRO_ENUM_VEHICLETYPE_AA;
				};
				case "edsubcat_apcs": {
					_vehType = MACRO_ENUM_VEHICLETYPE_APC;
				};
			};

			if (_vehType != MACRO_ENUM_VEHICLETYPE_UNKNOWN) then {
				breakTo "getVehType";
			};

			switch (_nameSound) do {
				case "veh_vehicle_apc_s": {
					_vehType = MACRO_ENUM_VEHICLETYPE_APC;
				};
				default {
					_vehType = MACRO_ENUM_VEHICLETYPE_TANK;
				};
			};
		};

		case "helicopter";
		case "helicopterrtd": {
			switch (_nameSound) do {
				case "veh_air_gunship_s": {
					_vehType = MACRO_ENUM_VEHICLETYPE_HELI_ATTACK;
				};
				default {
					_vehType = MACRO_ENUM_VEHICLETYPE_HELI_TRANSPORT;
				};
			};
		};

		case "airplanex": {
			_vehType = MACRO_ENUM_VEHICLETYPE_JET;
		};

		case "shipx": {
			switch (_nameSound) do {
				case "veh_ship_attackboat_s": {
					_vehType = MACRO_ENUM_VEHICLETYPE_BOAT_ATTACK;
				};
				default {
					_vehType = MACRO_ENUM_VEHICLETYPE_BOAT_TRANSPORT;
				};
			};
		};

	};

	// Save the roles array onto the namespace
	_namespace setVariable [_class, _vehType];
};

_vehType;
