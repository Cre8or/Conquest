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
#include "..\..\res\macros\fnc_allUnitRoleEnums.inc"
#include "..\..\res\macros\fnc_allVehicleTypeEnums.inc"

#include "..\..\mission\settings.inc"





// Set up some constants
private _configPath_weapons   = (configFile >> "CfgWeapons");
private _configPath_magazines = (configFile >> "CfgMagazines");
private _configPath_ammo      = (configFile >> "CfgAmmo");
private _configPath_vehicles  = (configFile >> "CfgVehicles");
private _allThrowables        = [];

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
private ["_sideData", "_abilities", "_allMagazines", "_magazinesCache", "_weaponIcon","_magazinePrimary", "_magazinePrimaryAlt", "_magazineSecondary", "_magazineHandgun", "_ammoTypeX", "_isExplosiveX"];
private ["_vehTypesCache", "_vehTypesIndexCache", "_definitionsXCopy"];
private ["_accuracyMulCache", "_totalAccuracyMul"];
{
	_x params ["_side", "_filePath"];

	// Validate the file path
	if (fileExists _filePath) then {
		_sideData = call compile preprocessFileLineNumbers _filePath;

		if (isNil "_sideData" or {!(_sideData isEqualType [])} or {_sideData isEqualTo []}) then {
			_sideData = [];
			private _str = format ["[CONQUEST] ERROR: Side data file appears to be invalid! (%1)", _filePath];
			systemChat _str;
			diag_log _str;
		};

	} else {
		_sideData = [];

		private _str = format ["[CONQUEST] ERROR: Side data file is missing! (%1)", _filePath];
		systemChat _str;
		diag_log _str;
	};



	_sideData params [
		["_sideNameShort", "ERROR", [""]],
		["_sideNameLong", "ERROR: Unknown Faction", [""]],
		["_sideFlag", MACRO_TEXTURE_FLAG_EMPTY, [""]],
		["_sideAIFaces", [], ["", []]],
		["_sideAISpeakers", [], ["", []]],
		["_sideLoadouts", [], [[]]],
		["_sideVehicleDefinitions", [], [[]]],
		["_sideAIBalancing", [], [[]]]
	];

	diag_log format ["[CONQUEST] Compiling side %1 (%2)", _sideNameShort, _side];

	// Validate the parameters
	if (_sideAIFaces isEqualType "") then {
		_sideAIFaces = [_sideAIFaces];
	};
	if (_sideAISpeakers isEqualType "") then {
		_sideAISpeakers = [_sideAISpeakers];
	};



	// Expose the common side data as global variables
	missionNamespace setVariable [format [QGVAR(shortName_%1), _side], _sideNameShort, false];
	missionNamespace setVariable [format [QGVAR(longName_%1), _side], _sideNameLong, false];
	missionNamespace setVariable [format [QGVAR(flagTexture_%1), _side], _sideFlag, false];
	missionNamespace setVariable [format [QGVAR(aiFaces_%1), _side], _sideAIFaces, false];
	missionNamespace setVariable [format [QGVAR(aiSpeakers_%1), _side], _sideAISpeakers, false];



	// Iterate over this side's loadouts
	{
		_x params [
			["_role", MACRO_ENUM_ROLE_INVALID, [MACRO_ENUM_ROLE_INVALID]],
			["_loadout", [], [[]]]
		];

		// Role-based abilities
		_abilities = [];
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



	// Iterate over this side's vehicle definitions
	_vehTypesCache      = createHashMap;
	_vehTypesIndexCache = createHashMap;
	{
		_x params [
			["_enumX", "", [""]],
			["_definitionsX", [], [[]]]
		];
		_enumX = toUpper _enumX;

		if !(_enumX in MACRO_FNC_ALLVEHICLETYPEENUMS) then {
			diag_log format ["[CONQUEST] ERROR: Invalid vehicle enumeration type ""%1""!", _enumX];
			continue;
		};

		if (_enumX in _vehTypesCache) then {
			diag_log format ["[CONQUEST] ERROR: Vehicle enumeration type ""%1"" is defined multiple times!", _enumX];
			continue;
		};

		_definitionsXCopy = [];
		{
			_x params [["_classX", "", [""]]]; // There are more parameters, but we only care about the classname for now

			if !(isClass (_configPath_vehicles >> _classX)) then {
				diag_log format ["[CONQUEST] ERROR: Vehicle class ""%1"" does not exist!", _classX];
				systemChat format ["[CONQUEST] ERROR: Vehicle class ""%1"" does not exist!", _classX];
				continue;
			};

			_definitionsXCopy pushBack _x;
		} forEach _definitionsX;

		_vehTypesCache      set [_enumX, _definitionsXCopy];
		_vehTypesIndexCache set [_enumX, [0, (count _definitionsXCopy) - 1]]; // [indexCurrent, indexLast]

	} forEach _sideVehicleDefinitions;

	missionNamespace setVariable [format [QGVAR(vehTypesCache_%1), _side], _vehTypesCache, false];
	missionNamespace setVariable [format [QGVAR(vehTypesIndexCache_%1), _side], _vehTypesIndexCache, false];



	// Parse the side's AI balancing data
	_accuracyMulCache = createHashMap;
	_sideAIBalancing params [
		["_overallAccuracyMul", MACRO_AI_SKILL_BASEACCURACY, [MACRO_AI_SKILL_BASEACCURACY]],
		["_roleAccuracyMulArr", [], [[]]]
	];

	{
		_x params [
			["_role", MACRO_ENUM_ROLE_INVALID, [MACRO_ENUM_ROLE_INVALID]],
			["_roleAccuracyMul", 1, [1]]
		];

		if !(_role in MACRO_FNC_ALLUNITROLEENUMS) then {
			diag_log format ["[CONQUEST] ERROR: Invalid unit role ""%1""!", _role];
			continue;
		};

		if (_role in _accuracyMulCache) then {
			diag_log format ["[CONQUEST] ERROR: Accuracy multiplier for unit role ""%1"" is defined multiple times!", _role];
			continue;
		};

		_totalAccuracyMul = ((_overallAccuracyMul * _roleAccuracyMul) max 0) min 1;
		_accuracyMulCache set [_role, _totalAccuracyMul];
	} forEach _roleAccuracyMulArr;

	missionNamespace setVariable [format [QGVAR(accuracyMulCache_%1), _side], _accuracyMulCache, false];

} forEach _allSides;





diag_log "[CONQUEST] (SHARED) Compiled sides data";
