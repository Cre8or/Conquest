/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA][LE]
		Processes a kill feed event by appending the corresponding data to the kill feed UI handler.

		Only executed on the client.
	Arguments:
		0:	<OBJECT>	The killer unit
		1:	<OBJECT>	The victim unit
		2:	<ARRAY>		The kill data, in format [classKind, iconClass, iconEnum]
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

params [
	["_killer", objNull],
	["_victim", objNull],
	["_killData", [], [[]]]
];

if (!hasInterface or {isNull _victim}) exitWith {};





// Set up some macros
#define MACRO_ICON_UNKNOWN "a3\ui_f\data\IGUI\Cfg\simpleTasks\types\unknown_ca.paa"
#define MACRO_ICON_SUICIDE getMissionPath "res\images\suicide.paa"

// Set up some variables
MACRO_FNC_INITVAR(GVAR(ui_sys_drawKillFeed_data), []);

private _unitsPly = units group player;
private _isKillerFriendly = (GVAR(side) == _killer getVariable [QGVAR(side), sideEmpty]);
private _isVictimFriendly = (GVAR(side) == _victim getVariable [QGVAR(side), sideEmpty]);
private _iconEnum   = MACRO_ENUM_KF_ICON_NONE;
private _weaponIcon = MACRO_ICON_UNKNOWN;
private ["_colourKiller", "_colourVictim"];

if (_killer in _unitsPly) then {
	_colourKiller = SQUARE(MACRO_COLOUR_A100_SQUAD);
} else {
	_colourKiller = [SQUARE(MACRO_COLOUR_A100_ENEMY), SQUARE(MACRO_COLOUR_A100_FRIENDLY)] select _isKillerFriendly;
};

if (_victim in _unitsPly) then {
	_colourVictim = SQUARE(MACRO_COLOUR_A100_SQUAD);
} else {
	_colourVictim = [SQUARE(MACRO_COLOUR_A100_ENEMY), SQUARE(MACRO_COLOUR_A100_FRIENDLY)] select _isVictimFriendly;
};





// Parse the kill data
_killData params [
	["_iconEnumArg", MACRO_ENUM_KF_ICON_NONE, [MACRO_ENUM_KF_ICON_NONE]],
	["_classKind", MACRO_ENUM_CLASSKIND_NONE, [MACRO_ENUM_CLASSKIND_NONE]],
	["_iconClass", "", [""]]
];
_iconEnum = _iconEnumArg;

if (_iconClass != "") then {
	switch (_classKind) do {
		case MACRO_ENUM_CLASSKIND_VEHICLE:  {_weaponIcon = getText (configFile >> "CfgVehicles" >> _iconClass >> "picture")};
		case MACRO_ENUM_CLASSKIND_WEAPON:   {_weaponIcon = getText (configFile >> "CfgWeapons" >> _iconClass >> "picture")};
		case MACRO_ENUM_CLASSKIND_MAGAZINE: {_weaponIcon = getText (configFile >> "CfgMagazines" >> _iconClass >> "picture")};
		case MACRO_ENUM_CLASSKIND_AMMO: {
			private _magazine = getText (configFile >> "CfgAmmo" >> _iconClass >> "defaultMagazine");

			if (_magazine != "") then {
				_weaponIcon = getText (configFile >> "CfgMagazines" >> _magazine >> "picture");
			};
		};
	};
};

// Special case 1: Mines don't use any weapon icons
if (_iconEnum == MACRO_ENUM_KF_ICON_MINE) then {
	_weaponIcon = MACRO_KF_ICON_MINE;
	_iconEnum = MACRO_ENUM_KF_ICON_NONE;

} else {
	// Special case 2: Suicide (from physics damage, or from self-damage with no additional data)
	if (_iconClass == "" and {_killer == _victim}) then {
		_weaponIcon = MACRO_ICON_SUICIDE;
	};
};

// Fallback - default icon
if (_weaponIcon == "") then {
	_weaponIcon = MACRO_ICON_UNKNOWN;
};





// Append the event data to the kill feed
if (!isNull _killer and {_killer != _victim}) then {

	GVAR(ui_sys_drawKillFeed_data) pushBack [
		time + MACRO_UI_KILLFEED_ENTRYLIFETIME,
		name _victim,
		_iconEnum,
		_weaponIcon,
		name _killer,
		_colourKiller,
		_colourVictim
	];

} else {

	GVAR(ui_sys_drawKillFeed_data) pushBack [
		time + MACRO_UI_KILLFEED_ENTRYLIFETIME,
		name _victim,
		_iconEnum,
		_weaponIcon,
		"",
		_colourKiller,
		_colourVictim
	];
};
