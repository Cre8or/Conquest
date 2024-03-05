/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Returns the simple vehicle icon associated with the given vehicle type enum. Used for the drawing of UI
		icons.
	Arguments:
		0:	<NUMBER>	The vehicle's type enum
	Returns:
			<STRING>	The icon associated with the vehicle type
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_typeEnum", MACRO_ENUM_VEHICLETYPE_UNKNOWN, [MACRO_ENUM_VEHICLETYPE_UNKNOWN]]
];





// Return the corresponding icon
switch (_typeEnum) do {
	case MACRO_ENUM_VEHICLETYPE_CAR:		{"a3\ui_f\data\Map\VehicleIcons\iconCar_ca.paa"};
	case MACRO_ENUM_VEHICLETYPE_MRAP:		{"a3\ui_f\data\Map\VehicleIcons\iconCar_ca.paa"};
	case MACRO_ENUM_VEHICLETYPE_TRUCK:		{"a3\ui_f\data\Map\VehicleIcons\iconTruck_ca.paa"};

	case MACRO_ENUM_VEHICLETYPE_APC:		{"a3\ui_f\data\Map\VehicleIcons\iconAPC_ca.paa"};
	case MACRO_ENUM_VEHICLETYPE_AA:			{"a3\ui_f\data\Map\VehicleIcons\iconTank_ca.paa"};
	case MACRO_ENUM_VEHICLETYPE_TANK:		{"a3\ui_f\data\Map\VehicleIcons\iconTank_ca.paa"};

	case MACRO_ENUM_VEHICLETYPE_HELI_TRANSPORT:	{"a3\ui_f\data\Map\VehicleIcons\iconHelicopter_ca.paa"};
	case MACRO_ENUM_VEHICLETYPE_HELI_ATTACK:	{"a3\ui_f\data\Map\VehicleIcons\iconHelicopter_ca.paa"};

	case MACRO_ENUM_VEHICLETYPE_JET:		{"a3\ui_f\data\Map\VehicleIcons\iconPlane_ca.paa"};

	case MACRO_ENUM_VEHICLETYPE_BOAT_TRANSPORT:	{"a3\ui_f\data\Map\VehicleIcons\iconShip_ca.paa"};
	case MACRO_ENUM_VEHICLETYPE_BOAT_ATTACK:	{"a3\ui_f\data\Map\VehicleIcons\iconShip_ca.paa"};

	default						{"a3\ui_f\data\Map\VehicleIcons\iconVehicle_ca.paa"};
};
