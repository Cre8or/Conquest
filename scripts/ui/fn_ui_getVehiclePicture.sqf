/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Returns the texture path of the vehicle's picture, as defined in its config. By Arma convention, vehicle
		pictures are generally a side-shot stencil image of the concerned vehicle.
	Arguments:
		0:	<STRING>	The vehicle's classname
	Returns:
			<STRING>	The vehicle's picture texture path
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

// Define a fallback for invalid results
#define MACRO_VEHICLEPICTURE_UNKNOWN "a3\ui_f\data\Map\VehicleIcons\iconVehicle_ca.paa"

params [
	["_class", "", [""]]
];

if (_class == "") exitWith {MACRO_VEHICLEPICTURE_UNKNOWN};





MACRO_FNC_INITVAR(GVAR(ui_getVehiclePicture_cache), createHashMap);





_class = toLower _class;
private _picture = GVAR(ui_getVehiclePicture_cache) get _class;

// if no picture is returned, fetch and cache it
if (isNil "_picture") then {

	_picture = getText (configFile >> "CfgVehicles" >> _class >> "Picture");

	// Fallback to prevent script errors
	if (_picture == "" or {!fileExists _picture}) then {
		_picture = MACRO_VEHICLEPICTURE_UNKNOWN;
	};

	GVAR(ui_getVehiclePicture_cache) set [_class, _picture];
};

_picture;
