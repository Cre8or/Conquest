#include "res\common\macros.inc"
#include "res\macros\fnc_allVehicleTypeEnums.inc"

#include "mission\settings.inc"





[] spawn {

	//systemChat format ["Display found: %1", !isNull findDisplay 313];
	waitUntil {time > 1};

	// Escape schedule environment again
	isNil {

		// Set up some variables
		GVAR(eden_updateSectors)              = true;
		GVAR(eden_updateSectors_reportErrors) = false;
		GVAR(eden_drawData_sectors)           = [];
		GVAR(eden_validSectorLinkedClasses)   = [
			MACRO_CLASS_SPAWNPOINT_INF,
			MACRO_CLASS_SPAWNPOINT_VEH,
			MACRO_CLASS_ATTACKPOINT_INF,
			MACRO_CLASS_ATTACKPOINT_VEH,
			MACRO_CLASS_FLAG
		] apply {toLower _x};

		GVAR(eden_validSectorLinkedClassesExtended) = (GVAR(eden_validSectorLinkedClasses) + ["EmptyDetector"] apply {toLower _x});

		GVAR(eden_validLinkableClasses) = (GVAR(eden_validSectorLinkedClasses) + [
			MACRO_CLASS_COMBATAREA_NODE,
			MACRO_CLASS_NODEMESH_NODE_INF,
			MACRO_CLASS_NODEMESH_NODE_VEH,
			MACRO_CLASS_NODEMESH_OCCLUDER_INF,
			MACRO_CLASS_NODEMESH_OCCLUDER_VEH
		] apply {toLower _x});

		#ifdef MACRO_MISSION_USES_INDFOR
			GVAR(eden_usesIndfor) = true;
		#else
			GVAR(eden_usesIndfor) = false;
		#endif

		private _display = findDisplay 313;



		// Pick the factions that should be used for visualisation in 3DEN
		GVAR(param_gm_factionEnum_east)       = MACRO_GM_FACTIONENUM_OPFOR;
		GVAR(param_gm_factionEnum_resistance) = MACRO_GM_FACTIONENUM_INDFOR;
		GVAR(param_gm_factionEnum_west)       = MACRO_GM_FACTIONENUM_BLUFOR;

		// Define some functions
		// We can't use CfgFunctions-defined functions here as the mission description isn't parsed yet
		// (we're still in 3DEN, after all), and we can't rely on any mods/addons to help us out, since we
		// don't know if they're present at this stage.
		// The following solution isn't pretty, but it's the best we can do right now.
		FUNC(fac_getData)     = compile preprocessFileLineNumbers "scripts\factions\fn_fac_getData.sqf";
		FUNC(fac_getFilePath) = compile preprocessFileLineNumbers "scripts\factions\fn_fac_getFilePath.sqf";

		FUNC(gm_compileSidesData) = compile preprocessFileLineNumbers "scripts\gamemode\fn_gm_compileSidesData.sqf";

		FUNC(lo_getAllHitPointsArmour) = compile preprocessFileLineNumbers "scripts\loadouts\fn_lo_getAllHitPointsArmour.sqf";

		FUNC(sector_addVehicleSpawn) = compile preprocessFileLineNumbers "scripts\sectors\fn_sector_addVehicleSpawn.sqf";

		FUNC(veh_setCustomisation)  = compile preprocessFileLineNumbers "scripts\vehicles\fn_veh_setCustomisation.sqf";
		FUNC(veh_getNextDefinition) = compile preprocessFileLineNumbers "scripts\vehicles\fn_veh_getNextDefinition.sqf";

		FUNC(eden_moveCameraToObject) = {
			params [["_obj", objNull, [objNull]]];

			private _cam = get3DENCamera;
			private _dir = vectorDir _cam;
			_dir set [2, (_dir # 2) min 0];
			_dir = vectorNormalized _dir;

			move3DENCamera [getPosASL _obj vectorAdd ((_dir vectorMultiply -5) vectorAdd [0,0,1]), false];
			_cam setVectorDirAndUp [_dir, [0,0,1]];

		};

		FUNC(eden_resetVehicleDefinitionIndexes) = {

			private ["_vehTypesIndexCache"];
			{
				_vehTypesIndexCache = missionNamespace getVariable [format [QGVAR(vehTypesIndexCache_%1), _x], createHashMap];
				{
					_vehTypesIndexCache set [_x, [0, _y # 1]]; // Reset the current index
				} forEach _vehTypesIndexCache;
			} forEach [east, resistance, west]
		};

		private _fnc_eden_cleanupEHs = {

			private _isInit = _display getVariable [QGVAR(isInit), false];
			if (!_isInit) exitWith {
				//systemChat format ["Nothing to clean up (source: %1)", _this];
			};

			//systemChat format ["Cleaning up... (source: %1)", _this];

			private _display             = findDisplay 313;
			private _EH_onMissionLoad    = _display getVariable [QGVAR(EH_onMissionLoad), -1];
			private _EH_onMissionNew     = _display getVariable [QGVAR(EH_onMissionNew), -1];
			private _EH_onMissionSave    = _display getVariable [QGVAR(EH_onMissionSave), -1];
			private _EH_keyDown          = _display getVariable [QGVAR(EH_keyDown), -1];

			//private _EH_onHistoryChange           = _display getVariable [QGVAR(EH_onHistoryChange), -1];
			private _EH_onUndo                    = _display getVariable [QGVAR(EH_onUndo), -1];
			private _EH_onRedo                    = _display getVariable [QGVAR(EH_onRedo), -1];
			private _EH_onPaste                   = _display getVariable [QGVAR(EH_onPaste), -1];
			private _EH_onPasteUnitOrig           = _display getVariable [QGVAR(EH_onPasteUnitOrig), -1];
			//private _EH_onEditableEntityAdded     = _display getVariable [QGVAR(EH_onEditableEntityAdded), -1];
			private _EH_onEditableEntityRemoved   = _display getVariable [QGVAR(EH_onEditableEntityRemoved), -1];
			private _EH_onConnectingEnd           = _display getVariable [QGVAR(EH_onConnectingEnd), -1];
			private _EH_onEntityAttributeChanged  = _display getVariable [QGVAR(EH_onEntityAttributeChanged), -1];

			private _EH_eachFrame        = _display getVariable [QGVAR(EH_eachFrame), -1];
			private _EH_draw3D           = _display getVariable [QGVAR(EH_draw3D), -1];

			remove3DENEventHandler ["OnMissionLoad", _EH_onMissionLoad];
			remove3DENEventHandler ["OnMissionNew",  _EH_onMissionNew];
			remove3DENEventHandler ["OnMissionSave", _EH_onMissionSave];
			_display displayRemoveEventHandler ["KeyDown", _EH_keyDown];

			//remove3DENEventHandler ["OnHistoryChange", _EH_onHistoryChange];
			remove3DENEventHandler ["OnUndo", _EH_onUndo];
			remove3DENEventHandler ["OnRedo", _EH_onRedo];
			remove3DENEventHandler ["OnPaste", _EH_onPaste];
			remove3DENEventHandler ["OnPasteUnitOrig", _EH_onPasteUnitOrig];
			//remove3DENEventHandler ["OnEditableEntityAdded", _EH_onEditableEntityAdded];
			remove3DENEventHandler ["OnEditableEntityRemoved", _EH_onEditableEntityRemoved];
			remove3DENEventHandler ["OnConnectingEnd", _EH_onConnectingEnd];
			remove3DENEventHandler ["OnEntityAttributeChanged", _EH_onEntityAttributeChanged];

			removeMissionEventHandler ["EachFrame", _EH_eachFrame];
			removeMissionEventHandler ["Draw3D", _EH_draw3D];



			systemChat "[CONQUEST] Unloaded 3DEN development environment";

			_display setVariable [QGVAR(isInit), false];
		};

		private _fnc_eden_checkForErrors = {

			scopeName QGVAR(eden_checkForErrors);

			private _objs = all3DENEntities # 0;

			// Warn about incorrectly linked game objects
			private ["_sector", "_error"];
			{
				_x params ["_className", "_objectKindStr"];

				{
					scopeName QGVAR(eden_checkForErrors_loop);

					_sector = objNull;
					_error  = 1;

					{
						_x params ["_linkType", "_linkTo"];
						if (_linkType isNotEqualTo "Sync") then {
							continue;
						};

						// Ensure objects are only linked to sectors
						if !(_linkTo isKindOf "EmptyDetector") then {
							_error = 2;
							breakTo QGVAR(eden_checkForErrors_loop);
						};

						// First sector: entity is valid
						if (isNull _sector or {_linkTo == _sector}) then {
							_sector = _linkTo;
							_error  = 0;

						// More than one sector: entity is invalid
						} else {
							_error = 3;
							breakTo QGVAR(eden_checkForErrors_loop);
						};
					} forEach get3DENConnections _x;

					switch (_error) do {
						case 1: {systemChat format ["[CONQUEST] WARNING: %1 is not linked to any sectors! It should be linked to one.", _objectKindStr]};
						case 2: {systemChat format ["[CONQUEST] WARNING: %1 has a link to something other than a sector! It should only be linked to a sector.", _objectKindStr]};
						case 3: {systemChat format ["[CONQUEST] WARNING: %1 is linked to more than one sector! It should only be linked to one.", _objectKindStr]};
					};

					// Move the camera to the concerned entity
					if (_error > 0) then {
						[_x] call FUNC(eden_moveCameraToObject);
						breakOut QGVAR(eden_checkForErrors);
					};
				} forEach (_objs select {typeOf _x == _className});

			} forEach [
				[MACRO_CLASS_SPAWNPOINT_INF,  "Infantry spawnpoint"],
				[MACRO_CLASS_SPAWNPOINT_VEH,  "Vehicle spawnpoint"],
				[MACRO_CLASS_ATTACKPOINT_INF, "Infantry attack point"],
				[MACRO_CLASS_ATTACKPOINT_VEH, "Vehicle attack point"],
				[MACRO_CLASS_FLAG,            "Sector flag pole"]
			];



			// Check for unknown objects linked to sectors
			_error = 0;
			private ["_name", "_letter", "_letterPos", "_objX", "_classX"];
			{
				scopeName QGVAR(eden_checkForErrors_loop);

				_sector    = _x;
				_name      = (_sector get3DENAttribute "Name") # 0;
				_letter    = toUpper (_name select [7, 1]);
				_letterPos = (toArray _letter) param [0, 0];

				// Only check triggers that the user likely intends to use as sectors
				if !(_name select [0,7] == "sector_" and {_letterPos >= 65} and {_letterPos <= 90}) then { // 'A' .. 'Z'
					continue;
				};

				// Check the sector's connections
				{
					_x params ["_linkType", "_linkTo"];
					_objX = _linkTo;

					if (_linkType isNotEqualTo "Sync") then {
						continue;
					};

					// Detect sectors linked to other triggers
					if (_objX != _sector and {_objX isKindOf "EmptyDetector"}) then {
						_error = 1;
						breakTo QGVAR(eden_checkForErrors_loop);
					};

					// Detect unidentified object classes (e.g. after changing classname macros)
					_classX = typeOf _objX;
					if (GVAR(eden_validSectorLinkedClasses) findIf {_classX == _x} < 0) then {
						_error = 2;
						breakTo QGVAR(eden_checkForErrors_loop);
					};
				} forEach get3DENConnections _sector;

				if (_error > 0) then {
					switch (_error) do {
						case 1: {systemChat format ["[CONQUEST] WARNING: Sector %1 is linked to a trigger! This isn't an error, but that link should not be there. Please remove it.", _letter]};
						case 2: {systemChat format ["[CONQUEST] WARNING: Sector %1 has an unidentified object linked to it (%2)! Perhaps it should be a different classname?", _letter, _classX]};
					};

					// Move the camera to the concerned entity
					[_objX] call FUNC(eden_moveCameraToObject);
					breakOut QGVAR(eden_checkForErrors);
				};
			} forEach (all3DENEntities # 2);



			// Finally, trigger the sector updater EH
			GVAR(eden_updateSectors)              = true;
			GVAR(eden_updateSectors_reportErrors) = true;
		};





		// Preinitialise
		call FUNC(gm_compileSidesData);

		// Manually cleanup on init (in case this file is executed manually)
		"init3DEN" call _fnc_eden_cleanupEHs;

		// Initiate automatic cleanup
		private _display = findDisplay 313;
		private _EH_onMissionLoad = add3DENEventHandler ["OnMissionLoad", _fnc_eden_cleanupEHs];
		_display setVariable [QGVAR(EH_onMissionLoad), _EH_onMissionLoad];

		private _EH_onMissionNew = add3DENEventHandler ["OnMissionNew", _fnc_eden_cleanupEHs];
		_display setVariable [QGVAR(EH_onMissionNew), _EH_onMissionNew];

		// Also add error checking on mission save
		private _EH_onMissionSave = add3DENEventHandler ["OnMissionSave", _fnc_eden_checkForErrors];
		_display setVariable [QGVAR(EH_onMissionSave), _EH_onMissionSave];

		_display setVariable [QGVAR(isInit), true];





		// Add a new EH to detect keypresses (to sync nodes)
		_EH_keyDown = _display displayAddEventHandler ["KeyDown", {
			params ["_display", "_key", "_shift", "_ctrl", "_alt"];

			scopeName QGVAR(init3DEN_keyDown);

			if (_key == 45) then {	// "X"
				private _cursorObj = get3DENMouseOver param [1, objNull];
				private _objs      = (get3DENSelected "object") select {toLower typeOf _x in GVAR(eden_validLinkableClasses)};

				if (isNull _cursorObj or {_objs isEqualTo []}) then {
					breakTo QGVAR(init3DEN_keyDown);
				};

				if (_shift) then {
					collect3DENHistory {
						{
							private _from = _x;
							{
								private _to = _x select 1;

								if (_to == _cursorObj) then {
									remove3DENConnection [_x select 0, [_from], _to];
								};
							} forEach get3DENConnections _from;
						} forEach _objs;
					};

				} else {
					add3DENConnection ["Sync", _objs, _cursorObj];
				};

				GVAR(eden_updateSectors) = true;
			};
		}];
		_display setVariable [QGVAR(EH_keyDown), _EH_keyDown];





		// Detect changes to objects
		//private _EH_onHistoryChange         = add3DENEventHandler ["OnHistoryChange", {GVAR(eden_updateSectors) = true}];
		private _EH_onUndo                   = add3DENEventHandler ["OnUndo", {GVAR(eden_updateSectors) = true}];
		private _EH_onRedo                   = add3DENEventHandler ["OnRedo", {GVAR(eden_updateSectors) = true}];
		private _EH_onPaste                  = add3DENEventHandler ["OnPaste", {GVAR(eden_updateSectors) = true}];
		private _EH_onPasteUnitOrig          = add3DENEventHandler ["OnPasteUnitOrig", {GVAR(eden_updateSectors) = true}];
		//private _EH_onEditableEntityAdded    = add3DENEventHandler ["OnEditableEntityAdded", {GVAR(eden_updateSectors) = true}];
		private _EH_onEditableEntityRemoved  = add3DENEventHandler ["OnEditableEntityRemoved", {params [["_obj", objNull]]; if (_obj isEqualType objNull and {toLower typeOf _obj in GVAR(eden_validSectorLinkedClassesExtended)}) then {GVAR(eden_updateSectors) = true}}];
		private _EH_onConnectingEnd          = add3DENEventHandler ["OnConnectingEnd", {params ["", ["_obj", objNull]]; if (_obj isEqualType objNull and {toLower typeOf _obj in GVAR(eden_validSectorLinkedClassesExtended)}) then {GVAR(eden_updateSectors) = true}}];
		private _EH_onEntityAttributeChanged = add3DENEventHandler ["OnEntityAttributeChanged", {params [["_obj", objNull]]; if (_obj isEqualType objNull and {toLower typeOf _obj in GVAR(eden_validSectorLinkedClassesExtended)}) then {GVAR(eden_updateSectors) = true}}];

		//_display setVariable [QGVAR(EH_onHistoryChange), _EH_onHistoryChange];
		_display setVariable [QGVAR(EH_onUndo), _EH_onUndo];
		_display setVariable [QGVAR(EH_onRedo), _EH_onRedo];
		_display setVariable [QGVAR(EH_onPaste), _EH_onPaste];
		_display setVariable [QGVAR(EH_onPasteUnitOrig), _EH_onPasteUnitOrig];
		//_display setVariable [QGVAR(EH_onEditableEntityAdded), _EH_onEditableEntityAdded];
		_display setVariable [QGVAR(EH_onEditableEntityRemoved), _EH_onEditableEntityRemoved];
		_display setVariable [QGVAR(EH_onConnectingEnd), _EH_onConnectingEnd];
		_display setVariable [QGVAR(EH_onEntityAttributeChanged), _EH_onEntityAttributeChanged];





		// Adjust every sector's flag to match the sector's initial side
		private _EH_eachFrame = addMissionEventHandler ["EachFrame", {

			if (!GVAR(eden_updateSectors)) exitWith {};

			scopeName QGVAR(eden_eachFrame);
			//systemChat format ["(%1) Updating sector flags", diag_tickTime];

			private _allSectors                   = [];
			private _reportErrors                 = GVAR(eden_updateSectors_reportErrors);
			GVAR(eden_updateSectors)              = false;
			GVAR(eden_updateSectors_reportErrors) = false;
			GVAR(eden_drawData_sectors)           = [];

			call FUNC(gm_compileSidesData);

			private ["_sector", "_name", "_letter", "_flag", "_skip", "_spawnPointsVeh", "_texture", "_level", "_activation", "_side", "_textureIcon", "_isLocked"];
			{
				_sector = _x;
				_name   = (_sector get3DENAttribute "Name") # 0;

				// Only check triggers that the user likely intends to use as sectors
				if (_name select [0,7] != "sector_") then {
					continue;
				};

				// Enforce a valid naming scheme
				if (count _name != 8) then {
					systemChat format ["[CONQUEST] WARNING: ""%1"" is not a valid sector name! Sector names must be ""sector_?"", where ""?"" is a letter.", _name];
					continue;
				};
				_letter = _name select [7, 1];

				_flag = objNull;
				_skip = false;
				_spawnPointsVeh = [];
				{
					_x params ["_linkType", "_linkTo"];

					if (_linkType isNotEqualTo "Sync") then {
						continue;
					};

					switch (toLower typeOf _linkTo) do {

						// Enforce one flag per sector rule
						case toLower MACRO_CLASS_FLAG: {

							if (isNull _flag) then { // First flag: sector is valid
								_flag = _linkTo;
							} else { // More than one flag: sector is invalid
								_skip = true;
							};
						};

						case toLower MACRO_CLASS_SPAWNPOINT_VEH: {
							_spawnPointsVeh pushBack _linkTo;
						};
					};
				} forEach get3DENConnections _sector;

				if (_skip) then {
					systemChat format ["[CONQUEST] WARNING: Sector %1 has more than one flag! (only one is allowed)", _letter];
					continue;
				};

				// Update the flag's texture and position on the pole to match the sector parameters
				_texture    = MACRO_TEXTURE_FLAG_EMPTY;
				_level      = 0;
				_activation = (_sector get3DENAttribute "ActivationBy") # 0;

				switch (toLower _activation select [0, 4]) do {
					case "east": {
						_side        = east;
						_textureIcon = "a3\data_f\flags\flag_red_co.paa";
					};
					case "guer": {
						_side        = [sideEmpty, resistance] select GVAR(eden_usesIndfor);
						_textureIcon = "a3\data_f\flags\flag_green_co.paa";
					};
					case "west": {
						_side        = west;
						_textureIcon = "a3\data_f\flags\flag_blue_co.paa";
					};
					default {
						_side = sideEmpty;
					};
				};

				if (_side != sideEmpty) then {
					_texture = missionNamespace getVariable [format [QGVAR(flagTexture_%1), _side], MACRO_TEXTURE_FLAG_EMPTY];
					_level   = 1;
				};

				// Validate the texture path
				if (!fileExists _texture) then {
					systemChat format ["[CONQUEST] WARNING: The flag texture for faction %1 does not exist! (""%2"")", _factionName, _texture];
					_texture = MACRO_TEXTURE_FLAG_EMPTY;
				} else {
					_textureIcon = _texture;
				};

				_flag setFlagTexture _texture;
				_flag setFlagAnimationPhase _level;

				if (_level > 0) then {
					_isLocked = (_activation select [5, 6] != "SEIZED");
				} else {
					_isLocked = false;
				};

				GVAR(eden_drawData_sectors) pushBack [_sector, _textureIcon, _letter, _isLocked];
				_allSectors pushBack [_letter, _sector, _side, _spawnPointsVeh];
			} forEach (all3DENEntities # 2);

			_allSectors sort true;



			// Update the sector's vehicle spawnpoints
			call FUNC(eden_resetVehicleDefinitionIndexes);

			private ["_spawnPoint", "_enums", "_index", "_veh", "_curDefinition", "_shouldUpdate", "_newDefinition"];
			{
				_x params ["_letter", "_sector", "_side", "_spawnPointsVeh"];
				{
					_spawnPoint = _x;

					// Run the spawnpoint's init field to fetch its type
					this = _spawnPoint; // Hack; "this" is not defined in this scope
					call compile (_spawnPoint get3DENAttribute "Init" select 0);
					_enums = (_spawnPoint getVariable [QGVAR(enums), []]) apply {toUpper _x};

					if (_enums isEqualTo []) then {
						if (_reportErrors) then {
							systemChat "[CONQUEST] WARNING: Vehicle spawnpoint does not have a valid enumeration type set! Did you remember to fill out the init field?";
							[_spawnPoint] call FUNC(eden_moveCameraToObject);
							breakOut QGVAR(eden_eachFrame);
						} else {
							continue;
						};
					};

					_index = _enums findIf {!(_x in MACRO_FNC_ALLVEHICLETYPEENUMS)};
					if (_index >= 0) then {
						if (_reportErrors) then {
							systemChat format ["[CONQUEST] WARNING: Vehicle spawnpoint uses an unrecognised enumeration type (""%1"")! Please refer to the list of valid types.", _enums # _index];
							[_spawnPoint] call FUNC(eden_moveCameraToObject);
							breakOut QGVAR(eden_eachFrame);
						} else {
							continue;
						};
					};

					// Figure out which vehicle to preview on this sector
					_enums findIf {
						_newDefinition = [_side, _x] call FUNC(veh_getNextDefinition);
						(_newDefinition isNotEqualTo []); // Stop at the first valid result
					};
					_veh          = _spawnPoint getVariable [QGVAR(init3DEN_vehicle), objNull];
					_shouldUpdate = (isNull _veh);

					if (!_shouldUpdate) then {
						_curDefinition = _spawnPoint getVariable [QGVAR(init3DEN_definition), []];
						_shouldUpdate  = (_curDefinition isNotEqualTo _newDefinition);
					};

					if (_shouldUpdate) then {
						deleteVehicle _veh;

						_newDefinition params [["_classX", "", [""]], "_texturesX", "_animationsX", "_pylonsX"];
						if (_classX == "") then {
							continue;
						};

						_veh = _classX createVehicle [0,0,0];
						_veh enableSimulation false;
						_veh allowDamage false;
						[_veh, _texturesX, _animationsX, _pylonsX] call FUNC(veh_setCustomisation);

						_spawnPoint setVariable [QGVAR(init3DEN_vehicle), _veh, false];
						_spawnPoint setVariable [QGVAR(init3DEN_definition), _newDefinition, false];

						// Handle cleanup
						{
							_x params ["_EH_name", "_EH_ID"];
							_spawnPoint removeEventHandler [_EH_name, _spawnPoint getVariable [_EH_ID, -1]];
							_spawnPoint setVariable [_EH_ID, _spawnPoint addEventHandler [_EH_name, {
								params ["_obj"];
								deleteVehicle (_obj getVariable [QGVAR(init3DEN_vehicle), objNull]);
								_obj setVariable [QGVAR(init3DEN_vehicle), objNull];
							}]];
						} forEach [
							["ConnectionChanged3DEN",     QGVAR(EH_connectionChanged)],
							["UnregisteredFromWorld3DEN", QGVAR(EH_unregisteredFromWorld)]
						];

						// Handle following the 3DEN object
						_spawnPoint removeEventHandler ["Dragged3DEN", _spawnPoint getVariable [QGVAR(EH_dragged), -1]];
						_spawnPoint setVariable [QGVAR(EH_dragged), _spawnPoint addEventHandler ["Dragged3DEN", {
							params ["_obj"];
							private _veh = _obj getVariable [QGVAR(init3DEN_vehicle), objNull];

							_veh setPos ASLtoAGL getPosWorld _obj;
							_veh setVectorDirAndUp [vectorDir _obj, vectorUp _obj];
						}]];
					};

					_veh setPos ASLtoAGL getPosWorld _spawnPoint;
					_veh setVectorDirAndUp [vectorDir _spawnPoint, vectorUp _spawnPoint];

				} forEach _spawnPointsVeh;

			} forEach _allSectors;
		}];
		_display setVariable [QGVAR(EH_eachFrame), _EH_eachFrame];



		// Draw a 3D overlay
		private _EH_draw3D = addMissionEventHandler ["Draw3D", {

			if (isGamePaused) exitWith {};

			private _scale       = 0.02;
			private _alpha       = 0.75;
			private _lockTexture = getMissionPath "res\images\sector_locked.paa";
			private _lockColour  = SQUARE(MACRO_COLOUR_SECTOR_LOCKED);
			private ["_pos"];
			_lockColour set [3, _alpha];

			{
				_x params ["_sector", "_texture", "_letter", "_isLocked"];
				_pos = ASLtoAGL getPosWorld _sector;

				cameraEffectEnableHUD true;
				drawIcon3D [
					_texture,
					[1, 1, 1, _alpha],
					_pos,
					48 * _scale,
					32 * _scale,
					0,
					_letter,
					0,
					0.05,
					MACRO_FONT_UI_MEDIUM,
					"center",
					false,
					0,
					0
				];

				if (_isLocked) then {
					drawIcon3D [
						_lockTexture,
						_lockColour,
						_pos,
						80 * _scale,	// undo the 4:5 ratio of the icon, thus offsetting the icon into the correct position
						64 * _scale,
						0
					];
				};
			} foreach GVAR(eden_drawData_sectors);
		}];
		_display setVariable [QGVAR(EH_draw3D), _EH_draw3D];

		systemChat "[CONQUEST] Initialised 3DEN development environment";
	};
};

nil;
