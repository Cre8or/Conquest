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
private ["_sideData", "_role", "_loadout", "_abilities", "_allMagazines", "_magazinesCache", "_weaponIcon","_magazinePrimary", "_magazinePrimaryAlt", "_magazineSecondary", "_magazineHandgun", "_ammoTypeX", "_isExplosiveX"];

// Compile the list of throwable magazines
{
	{
		_allThrowables pushBackUnique _x;
	} forEach getArray (_x >> "magazines");
} forEach ("isClass _x" configClasses (_configPath_weapons >> "Throw"));

private _allSides = [ // Fixed order by framework convention
	[east,       "mission\sides\data_side_east.inc"],
	[resistance, "mission\sides\data_side_resistance.inc"],
	[west,       "mission\sides\data_side_west.inc"]
];





// Parse all sides' data files
{
	_x params ["_side", "_filePath"];

	// Validate the file path
	_sideData = nil;
	if (fileExists _filePath) then {
		_sideData = call compile preprocessFileLineNumbers _filePath;
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
		_role      = _x param [0, MACRO_ENUM_ROLE_INVALID];
		_loadout   = _x param [1, []];
		_abilities = [];

		// Role-based abilities
		switch (_role) do {
			case MACRO_ENUM_ROLE_SUPPORT:  {_abilities pushBack MACRO_ENUM_LOADOUT_ABILITY_RESUPPLY};
			//case MACRO_ENUM_ROLE_ENGINEER: {_abilities pushBack MACRO_ENUM_LOADOUT_ABILITY_REPAIR};
			case MACRO_ENUM_ROLE_MEDIC:    {_abilities pushBack MACRO_ENUM_LOADOUT_ABILITY_HEAL};
		};

		// Only continue if the loadout is set
		if !(_loadout isEqualTo []) then {
			_allMagazines   = [];
			_magazinesCache = createHashMap;
			_weaponIcon     = "";

			_loadout params [
				["_weaponPrimaryArray", []],
				["_weaponSecondaryArray", []],
				["_weaponHandgunArray", []],
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
				_weaponIcon         = getText (_configPath_weapons >> _weaponPrimaryArray param [0, ""] >> "picture");
				_magazinePrimary    = _weaponPrimaryArray param [4, []];
				_magazinePrimaryAlt = _weaponPrimaryArray param [5, []];

				if !(_magazinePrimary isEqualTo []) then {
					_allMagazines pushBack [_magazinePrimary param [0, ""], 1];
				};
				if !(_magazinePrimaryAlt isEqualTo []) then {
					_allMagazines pushBack [_magazinePrimaryAlt param [0, ""], 1];
				};
			};

			// Check for a launcher
			if !(_weaponSecondaryArray isEqualTo []) then {
				_magazineSecondary = _weaponSecondaryArray param [4, []];

				if !(_magazineSecondary isEqualTo []) then {
					_allMagazines pushBack [_magazineSecondary param [0, ""], 1];
				};

				if !(getArray (_configPath_weapons >> _weaponSecondaryArray # 0 >> "magazines") isEqualTo []) then {
					_abilities pushBack MACRO_ENUM_LOADOUT_ABILITY_ANTITANK;
				};
			};

			// Check for a handgun
			if !(_weaponHandgunArray isEqualTo []) then {
				_magazineHandgun = _weaponHandgunArray param [4, []];

				if !(_magazineHandgun isEqualTo []) then {
					_allMagazines pushBack [_magazineHandgun param [0, ""], 1];
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

			// Iterate over all remaining items inside the loadout's uniform/vest/backpack
			{
				_x params ["_classX", "_amountX", ["_ammoCountX", -1]];

				// If the class is an array, it's a weapon
				if (_classX isEqualType []) then {
					_classX = _classX param [0, ""];

				// Otherwise, it's probably a magazine or a tool
				} else {

					// If the ammo count is greater than 0, it's a magazine
					if (_ammoCountX > 0) then {
						_allMagazines pushBack [_classX, _amountX];

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

			// Determine the overall counts for every magazine classname (deduplicating the array)
			{
				_x params ["_magazineX", "_countX"];
				_magazineX = toLower _magazineX;
				_countX    = _countX + (_magazinesCache getOrDefault [_magazineX, 0]);

				_magazinesCache set [_magazineX, _countX];
			} forEach _allMagazines;

			// Add the total ammo count of every magazine classname
			{
				_magazinesCache set [_x, [
					1 max getNumber (_configPath_magazines >> _x >> "count"), // Ammo per magazine
					_y // Total magazines count
				]];
			} forEach _magazinesCache;

			// Save the loadout, abilities and weapon icon data as global variables
			missionNamespace setVariable [format [QGVAR(loadout_%1_%2), _side, _role], _loadout, false];
			missionNamespace setVariable [format [QGVAR(abilities_%1_%2), _side, _role], _abilities, false];
			missionNamespace setVariable [format [QGVAR(weaponIcon_%1_%2), _side, _role], _weaponIcon, false];
			missionNamespace setVariable [format [QGVAR(magazinesCache_%1_%2), _side, _role], _magazinesCache, false];
		};
	} forEach _sideLoadouts;

} forEach _allSides;





diag_log "[CONQUEST] (SHARED) Compiled sides data";
