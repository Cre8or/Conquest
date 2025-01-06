/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Fetches the hit points of the specified item (uniform, vest or backpack) and returns the associated armour
		value as per its config entry.
		For better performance, results are cached in a hashmap.
	Arguments:
		0:  <STRING>    The concerned item classname
	Returns:
		    <ARRAY>     An array of armour values in format [hitPoint, armour, passThrough]
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"


params [
	["_class", "", [""]]
];

if (_class == "") exitWith {[]};





MACRO_FNC_INITVAR(GVAR(lo_getAllHitPointsArmour_cache), createHashMap);
//GVAR(lo_getAllHitPointsArmour_cache) = createHashMap; // DEBUG
_class = toLower _class;

// If the result is cached, fetch and return it
if (_class in GVAR(lo_getAllHitPointsArmour_cache)) exitWith {
	GVAR(lo_getAllHitPointsArmour_cache) get _class;
};

// Otherwise, cache and return it
private _result = [];

if (_class != "") then {
	private _itemConfig = configFile >> "CfgWeapons" >> _class >> "ItemInfo";
	private _itemType   = getNumber (_itemConfig >> "type");
	private ["_hitPoint", "_armour", "_passThrough"];

	switch (_itemType) do {
		case MACRO_ENUM_CFG_ITEMTYPE_HEADGEAR;
		case MACRO_ENUM_CFG_ITEMTYPE_VEST: {
			{
				_hitPoint = toLower getText (_x >> "hitPointName");
				if (_hitPoint == "") then {
					continue;
				};

				_armour      = (getNumber (_x >> "armor")) max 1; // Range 1 .. INF
				_passThrough = ((getNumber (_x >> "passThrough")) max 0) min 1; // Range 0 .. 1
				_result pushBack [_hitPoint, _armour, _passThrough];
			} forEach configProperties [_itemConfig >> "HitPointsProtectionInfo", "isClass _x"];
		};

		case MACRO_ENUM_CFG_ITEMTYPE_UNIFORM: {
			private _uniformName   = getText (_itemConfig >> "uniformClass");
			private _uniformConfig = configFile >> "CfgVehicles" >> _uniformName;

			{
				_hitPoint    = toLower configName _x;
				_armour      = (getNumber (_x >> "armor")) max 1; // Range 1 .. INF
				_passThrough = ((getNumber (_x >> "passThrough")) max 0) min 1; // Range 0 .. 1
				_result pushBack [_hitPoint, _armour, _passThrough];
			} forEach configProperties [_uniformConfig >> "HitPoints", "isClass _x"];
		};
	};
};
/*
diag_log format ["[CONQUEST] lo_getAllHitPointsArmour (%1):", toUpper _class];
{
	diag_log format ["    %1: %2", _x # 0, _x # 1];
} forEach _result;
diag_log "";
*/
GVAR(lo_getAllHitPointsArmour_cache) set [_class, _result];

_result;
