/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Returns the texture path of the vehicle's icon, as defined in its config. By Arma convention, vehicle icons are
		typically drawn as a top-down line art image representing the concerned vehicle.
	Arguments:
		0:	<STRING>	The vehicle's classname
	Returns:
			<STRING>	The vehicle's icon texture path
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

// Define a fallback for invalid results
#define MACRO_VEHICLEICON_UNKNOWN "a3\ui_f\data\Map\VehicleIcons\iconVehicle_ca.paa"

params [
	["_class", "", [""]]
];

if (_class == "") exitWith {MACRO_VEHICLEICON_UNKNOWN};





MACRO_FNC_INITVAR(GVAR(ui_getVehicleIcon_cache), createHashMap);





_class = toLower _class;
private _icon = GVAR(ui_getVehicleIcon_cache) get _class;

// if no icon is returned, fetch and cache it
if (isNil "_icon") then {

	_icon = getText (configFile >> "CfgVehicles" >> _class >> "Icon");

	// Fallback to prevent script errors
	if (_icon == "" or {!fileExists _icon}) then {
		_icon = MACRO_VEHICLEICON_UNKNOWN;
	};

	GVAR(ui_getVehicleIcon_cache) set [_class, _icon];
};

_icon;
