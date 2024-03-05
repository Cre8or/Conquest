/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Compiles the mission's role loadouts (and their abilities) and stores them onto the mission namespace
		for later use.

		Only executed once by all machines upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"





// Include the loadout data files
private _loadoutData_east =
	#include "..\..\mission\loadouts\data_loadouts_east.inc"
;
private _loadoutData_resistance =
	#include "..\..\mission\loadouts\data_loadouts_resistance.inc"
;
private _loadoutData_west =
	#include "..\..\mission\loadouts\data_loadouts_west.inc"
;

// Set up some constants
private _configPath_weapons = (configFile >> "CfgWeapons");
private _configPath_magazines = (configFile >> "CfgMagazines");
private _configPath_ammo = (configFile >> "CfgAmmo");
private _allThrowables = [];

// Set up some variables
private ["_side", "_role", "_loadout", "_abilities", "_weaponIcon", "_ammoTypeX", "_isExplosiveX"];

// Compile the list of throwable magazines
{
	{
		_allThrowables pushBackUnique _x;
	} forEach getArray (_x >> "magazines");
} forEach ("isClass _x" configClasses (_configPath_weapons >> "Throw"));
private _allLoadoutData = [[], [], []];

// Determine which sides we need to consider
if (east in GVAR(sides)) then {		_allLoadoutData set [0, _loadoutData_east]};
if (resistance in GVAR(sides)) then {	_allLoadoutData set [1, _loadoutData_resistance]};
if (west in GVAR(sides)) then {		_allLoadoutData set [2, _loadoutData_west]};





// Iterate over all sides' loadout arrays
{
	_side = GVAR(sides) # _forEachIndex;

	// Iterate over this side's loadouts
	{
		// Fetch the current role and loadout
		_role = _x # 0;
		_loadout = _x # 1;
		_abilities = _x param [2, []];

		// Only continue if the loadout is set
		if !(_loadout isEqualTo []) then {

			_weaponIcon = "";

			// Fetch the loadout's components
			_loadout params [
				["_weaponPrimaryArray", []],
				["_weaponSecondaryArray", []],
				"",				// weaponHandgun
				["_uniformArray", []],
				["_vestArray", []],
				["_backpackArray", []],
				"",				// headgear
				"",				// goggles
				["_binocularArray", []],
				["_itemsArray", []]
			];

			// Check for a primary weapon
			if !(_weaponPrimaryArray isEqualTo []) then {
				_weaponIcon = getText (_configPath_weapons >> _weaponPrimaryArray param [0, ""] >> "picture");
			};

			// Check for a launcher
			if !(_weaponSecondaryArray isEqualTo []) then {
				if !(getArray (_configPath_weapons >> _weaponSecondaryArray # 0 >> "magazines") isEqualTo []) then {
					_abilities pushBack MACRO_ENUM_LOADOUT_ABILITY_ANTITANK;
				};
			};

			// Check for binoculars
			if !(_binocularArray isEqualTo []) then {
				_abilities pushBack MACRO_ENUM_LOADOUT_ABILITY_BINOCULAR;
			};

			// Check for night visions
			if !(_itemsArray param [5, ""] isEqualTo "") then {
				_abilities pushBack MACRO_ENUM_LOADOUT_ABILITY_NVGS;
			};

			// Iterate over all items contained inside the loadout's uniform/vest/backpack
			{
				_x params ["_classX", "_amountX", ["_ammoCountX", -1]];

				// If the class is an array, it's a weapon
				if (_classX isEqualType []) then {
					_classX = _classX param [0, ""];

				// Otherwise, it's probably a magazine or a tool
				} else {

					// If the ammo count is greater or equal to 0, it's a magazine
					if (_ammoCountX > 0) then {

						_ammoTypeX = getText (_configPath_magazines >> _classX >> "ammo");
						_isExplosiveX = (getNumber (_configPath_ammo >> _ammoTypeX >> "explosive") > 0);

						// Check if the item is throwable
						if (_classX in _allThrowables) then {

							if (_isExplosiveX) then {
								_abilities pushBackUnique MACRO_ENUM_LOADOUT_ABILITY_HANDGRENADE_FRAG;
							} else {
								if (toLower getText (_configPath_ammo >> _ammoTypeX >> "simulation") isEqualTo "shotsmokex") then {
									_abilities pushBackUnique MACRO_ENUM_LOADOUT_ABILITY_HANDGRENADE_SMOKE;
								};
							};

						// Otherwise...
						} else {
							// If the ammunition is explosive, check what it is
							if (_isExplosiveX) then {

								switch (true) do {

									// It's a grenade launcher magazine
									case (_classX in MACRO_LOADOUT_MAGAZINES_GRENADELAUNCHER): {
										_abilities pushBackUnique MACRO_ENUM_LOADOUT_ABILITY_GRENADELAUNCHER;
									};

									// It's an explosive charge
									case (_classX in MACRO_LOADOUT_EXPLOSIVES): {
										_abilities pushBackUnique MACRO_ENUM_LOADOUT_ABILITY_EXPLOSIVES;
									};

									// It's an anti-personnel mine
									case (_classX in MACRO_LOADOUT_MINES_AP): {
										_abilities pushBackUnique MACRO_ENUM_LOADOUT_ABILITY_MINE_AP;
									};

									// It's an anti-tank mine
									case (_classX in MACRO_LOADOUT_MINES_AT): {
										_abilities pushBackUnique MACRO_ENUM_LOADOUT_ABILITY_MINE_AT;
									};
								};
							};
						};

					// Otherwise, it's a tool
					} else {
						switch (true) do {

							// It's a toolkit
							case (_classX isKindOf ["ToolKit", _configPath_weapons]): {
								_abilities pushBackUnique MACRO_ENUM_LOADOUT_ABILITY_REPAIRKIT;
							};

							// It's a medikit
							case (_classX isKindOf ["Medikit", _configPath_weapons]): {
								_abilities pushBackUnique MACRO_ENUM_LOADOUT_ABILITY_MEDIKIT;
							};

							// It's a mine detector
							case (_classX isKindOf ["MineDetector", _configPath_weapons]): {
								_abilities pushBackUnique MACRO_ENUM_LOADOUT_ABILITY_MINEDETECTOR;
							};
						};
					};
				};
			} forEach (
				(_uniformArray param [1, []])
				+ (_vestArray param [1, []])
				+ (_backpackArray param [1, []])
			);

			// Save the loadout, abilities and weapon icon data onto the mission namespace
			missionNamespace setVariable [format [QGVAR(loadout_%1_%2), _side, _role], _loadout, false];
			missionNamespace setVariable [format [QGVAR(abilities_%1_%2), _side, _role], _abilities, false];
			missionNamespace setVariable [format [QGVAR(weaponIcon_%1_%2), _side, _role], _weaponIcon, false];
		};
	} forEach _x;
} forEach _allLoadoutData;
