/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Parses the mission's sides data and sets shared global variables, such as the sides name, flag, loadouts
		and abilities.

		Only executed once by all machines upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"





// Set up some constants
private _configPath_weapons = (configFile >> "CfgWeapons");
private _configPath_magazines = (configFile >> "CfgMagazines");
private _configPath_ammo = (configFile >> "CfgAmmo");
private _allThrowables = [];

// Set up some variables
private ["_side", "_sideData", "_role", "_loadout", "_abilities", "_weaponIcon", "_ammoTypeX", "_isExplosiveX", "_abilitiesLUT"];

// Compile the list of throwable magazines
{
	{
		_allThrowables pushBackUnique _x;
	} forEach getArray (_x >> "magazines");
} forEach ("isClass _x" configClasses (_configPath_weapons >> "Throw"));
private _allLoadoutData = ["", "", ""];

// Determine which sides we need to consider
if (east in GVAR(sides)) then       {_allLoadoutData set [0, "mission\sides\data_side_east.inc"]};
if (resistance in GVAR(sides)) then {_allLoadoutData set [1, "mission\sides\data_side_resistance.inc"]};
if (west in GVAR(sides)) then       {_allLoadoutData set [2, "mission\sides\data_side_west.inc"]};





// Iterate over all sides' loadout arrays
{
	_side = GVAR(sides) # _forEachIndex;

	// Ensure the side data file is valid
	_sideData = nil;
	if (_x != "" and {fileExists _x}) then {
		_sideData = call compile preprocessFileLineNumbers _x;
	};

	if (isNil "_sideData" or {!(_sideData isEqualType [])}) then {
		_sideData = [];

		private _str = format ["[CONQUEST] ERROR: Side data file is missing or invalid! (%1)", _x];
		systemChat _str;
		diag_log _str;
	};

	_sideData params [
		["_sideNameShort", "N/A", [""]],
		["_sideNameLong", "Unknown", [""]],
		["_sideFlag", MACRO_TEXTURE_FLAG_EMPTY, [""]],
		["_sideAIFaces", ["white"], ["", []]],
		["_sideAIVoices", ["english_us"], ["", []]],
		["_sideLoadouts", [], [[]]]
	];

	// Validate the parameters
	if (_sideAIVoices isEqualType "") then {
		_sideAIVoices = [_sideAIVoices];
	};
	if (_sideAIFaces isEqualType "") then {
		_sideAIFaces = [_sideAIFaces];
	};

	// Expose the common side data as global variables
	missionNamespace setVariable [format [QGVAR(shortName_%1), _side], _sideNameShort, false];
	missionNamespace setVariable [format [QGVAR(longName_%1), _side], _sideNameLong, false];
	missionNamespace setVariable [format [QGVAR(flagTexture_%1), _side], _sideFlag, false];
	missionNamespace setVariable [format [QGVAR(aiFaces_%1), _side], _sideAIFaces, false];
	missionNamespace setVariable [format [QGVAR(aiVoices_%1), _side], _sideAIVoices, false];



	// Iterate over this side's loadouts
	{
		// Fetch the current role and loadout
		_role      = _x param [0, MACRO_ENUM_ROLE_INVALID];
		_loadout   = _x param [1, []];
		_abilities = [];

		// Role-based abilities
		switch (_role) do {
			case MACRO_ENUM_ROLE_SUPPORT:  {_abilities pushBack MACRO_ENUM_LOADOUT_ABILITY_RESUPPLY};
			case MACRO_ENUM_ROLE_ENGINEER: {_abilities pushBack MACRO_ENUM_LOADOUT_ABILITY_REPAIR};
			case MACRO_ENUM_ROLE_MEDIC:    {_abilities pushBack MACRO_ENUM_LOADOUT_ABILITY_HEAL};
			case MACRO_ENUM_ROLE_INVALID:  {continue};
		};

		// Only continue if the loadout is set
		if !(_loadout isEqualTo []) then {
			_weaponIcon = "";

			// Fetch the loadout's components
			_loadout params [
				["_weaponPrimaryArray", []],
				["_weaponSecondaryArray", []],
				"", // weaponHandgun
				["_uniformArray", []],
				["_vestArray", []],
				["_backpackArray", []],
				"", // headgear
				"", // goggles
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
					};
				};
			} forEach (
				(_uniformArray param [1, []])
				+ (_vestArray param [1, []])
				+ (_backpackArray param [1, []])
			);

			// Save the loadout, abilities and weapon icon data as global variables
			missionNamespace setVariable [format [QGVAR(loadout_%1_%2), _side, _role], _loadout, false];
			missionNamespace setVariable [format [QGVAR(abilities_%1_%2), _side, _role], _abilities, false];
			missionNamespace setVariable [format [QGVAR(weaponIcon_%1_%2), _side, _role], _weaponIcon, false];
		};
	} forEach _sideLoadouts;

} forEach _allLoadoutData;





diag_log "[CONQUEST] (SHARED) Compiled sides data";
