#include "res\common\macros.inc"
#include "mission\settings.inc"





[] spawn {

	waitUntil {time > 0};

	// Escape schedule environment again
	isNil {

		// Set up some variables
		GVAR(eden_updateSectorFlags) = true;
		GVAR(eden_drawData_sectors)  = [];

		private _display = findDisplay 313;

		// Define some functions
		// We can't use CfgFunctions-defined functions here as the mission description isn't parsed yet
		// (we're still in 3DEN, after all), and we can't rely on any mods/addons to help us out, since we
		// don't know if they're present at this stage.
		// The following solution isn't pretty, but it's the best we can do right now.
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
			private _EH_onHistoryChanged = _display getVariable [QGVAR(EH_onHistoryChanged), -1];
			private _EH_onUndo           = _display getVariable [QGVAR(EH_onUndo), -1];
			private _EH_onRedo           = _display getVariable [QGVAR(EH_onRedo), -1];
			private _EH_eachFrame        = _display getVariable [QGVAR(EH_eachFrame), -1];
			private _EH_draw3D           = _display getVariable [QGVAR(EH_draw3D), -1];

			remove3DENEventHandler ["OnMissionLoad", _EH_onMissionLoad];
			remove3DENEventHandler ["OnMissionNew",  _EH_onMissionNew];
			remove3DENEventHandler ["OnMissionSave", _EH_onMissionSave];

			_display displayRemoveEventHandler ["KeyDown", _EH_keyDown];
			remove3DENEventHandler ["OnHistoryChange", _EH_onHistoryChanged];
			remove3DENEventHandler ["OnUndo", _EH_onUndo];
			remove3DENEventHandler ["OnRedo", _EH_onRedo];
			removeMissionEventHandler ["EachFrame", _EH_eachFrame];
			removeMissionEventHandler ["Draw3D", _EH_draw3D];

			systemChat "[CONQUEST] Unloaded 3DEN development environment";

			_display setVariable [QGVAR(isInit), false];
		};

		private _fnc_eden_checkForErrors = {

		/*
			private _nodesInf     = _objs select {typeOf _x == MACRO_CLASS_NODEMESH_NODE_INF};
			private _nodesVeh     = _objs select {typeOf _x == MACRO_CLASS_NODEMESH_NODE_VEH};
			private _occludersInf = _objs select {typeOf _x == MACRO_CLASS_NODEMESH_OCCLUDER_INF};
			private _occludersVeh = _objs select {typeOf _x == MACRO_CLASS_NODEMESH_OCCLUDER_VEH};
		*/
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
						if (_linkType isNotEqualTo "Sync" or {!(_linkTo isKindOf "EmptyDetector")}) then {
							continue;
						};

						// First sector: entity is valid
						if (isNull _sector or {_linkTo == _sector}) then {
							_sector = _linkTo;
							_error  = 0;

						// More than one sector: entity is invalid
						} else {
							_error = 2;
							breakTo QGVAR(eden_checkForErrors_loop);
						};
					} forEach get3DENConnections _x;

					switch (_error) do {
						case 1: {systemChat format ["[CONQUEST] WARNING: %1 is not linked to any sectors! It should be linked to one.", _objectKindStr]};
						case 2: {systemChat format ["[CONQUEST] WARNING: %1 is linked to more than one sector! It should only be linked to one.", _objectKindStr]};
					};

					// Move the camera to the concerned entity
					if (_error > 0) then {
						private _cam = get3DENCamera;
						private _dir = vectorDir _cam;
						_dir set [2, (_dir # 2) min 0];
						_dir = vectorNormalized _dir;

						move3DENCamera [getPosASL _x vectorAdd ((_dir vectorMultiply -5) vectorAdd [0,0,1]), false];
						_cam setVectorDirAndUp [_dir, [0,0,1]];

						breakTo QGVAR(eden_checkForErrors);
					};
				} forEach (_objs select {typeOf _x == _className});

			} forEach [
				[MACRO_CLASS_FLAG,            "Sector flag pole"],
				[MACRO_CLASS_SPAWNPOINT_INF,  "Infantry spawnpoint"],
				[MACRO_CLASS_SPAWNPOINT_VEH,  "Vehicle spawnpoint"],
				[MACRO_CLASS_ATTACKPOINT_INF, "Infantry attack point"],
				[MACRO_CLASS_ATTACKPOINT_VEH, "Vehicle attack point"]
			];
		};

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
				private _objs = get3DENSelected "object";
				private _cursorObj = get3DENMouseOver param [1, objNull];

				if (isNull _cursorObj) then {
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
			};
		}];
		_display setVariable [QGVAR(EH_keyDown), _EH_keyDown];





		// Detect changes to objects
		private _EH_onHistoryChanged = add3DENEventHandler ["OnHistoryChange", {GVAR(eden_updateSectorFlags) = true}];
		private _EH_onUndo           = add3DENEventHandler ["OnUndo", {GVAR(eden_updateSectorFlags) = true}];
		private _EH_onRedo           = add3DENEventHandler ["OnRedo", {GVAR(eden_updateSectorFlags) = true}];
		_display setVariable [QGVAR(EH_onHistoryChanged), _EH_onHistoryChanged];
		_display setVariable [QGVAR(EH_onUndo), _EH_onUndo];
		_display setVariable [QGVAR(EH_onRedo), _EH_onRedo];





		// Adjust every sector's flag to match the sector's initial side
		private _EH_eachFrame = addMissionEventHandler ["EachFrame", {

			if (!GVAR(eden_updateSectorFlags)) exitWith {};

			scopeName QGVAR(eden_eachFrame);
			//systemChat format ["(%1) Updating sector flags", diag_tickTime];

			GVAR(eden_drawData_sectors) = [];
			private ["_sector", "_name", "_letter", "_flag", "_skip", "_texture", "_level", "_activation", "_isLocked"];
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

				// Enforce one flag per sector rule
				_flag = objNull;
				_skip = false;
				{
					_x params ["_linkType", "_linkTo"];

					if (_linkType isNotEqualTo "Sync" or {!(_linkTo isKindOf MACRO_CLASS_FLAG)}) then {
						continue;
					};

					// First flag: sector is valid
					if (isNull _flag) then {
						_flag = _linkTo;

					// More than one flag: sector is invalid
					} else {
						_skip = true;
					};
				} forEach get3DENConnections _sector;

				if (_skip) then {
					systemChat format ["[CONQUEST] WARNING: Sector %1 has more than one flag! (only one is allowed)", _letter];
					continue;
				};



				// Update the flag's texture and position on the pole to match the sector parameters
				_textureIcon  = "a3\ui_f\data\GUI\Rsc\RscDisplayMultiplayerSetup\flag_bluefor_empty_ca.paa";
				_texture      = MACRO_TEXTURE_FLAG_EMPTY;
				_level        = 0;
				_activation   = (_sector get3DENAttribute "ActivationBy") # 0;
				switch (_activation select [0, 4]) do {
					case "EAST": {
						#if __has_include("mission\sides\data_side_east.inc")
							_texture = (
								#include "mission\sides\data_side_east.inc"
							) param [2, MACRO_TEXTURE_FLAG_EMPTY];
						#else
							_texture = "a3\data_f\flags\flag_red_co.paa";
							systemChat "[CONQUEST] ERROR: A critical file is missing! (mission\sides\data_side_east.inc)";
						#endif

						_level = 1;
					};
					case "GUER": {
						#if __has_include("mission\sides\data_side_resistance.inc")
							_texture = (
								#include "mission\sides\data_side_resistance.inc"
							) param [2, MACRO_TEXTURE_FLAG_EMPTY];
						#else
							_texture = "a3\data_f\flags\flag_green_co.paa";
							systemChat "[CONQUEST] ERROR: A critical file is missing! (mission\sides\data_side_resistance.inc)";
						#endif
						_level = 1;
					};
					case "WEST": {
						#if __has_include("mission\sides\data_side_west.inc")
							_texture = (
								#include "mission\sides\data_side_west.inc"
							) param [2, MACRO_TEXTURE_FLAG_EMPTY];
						#else
							_texture = "a3\data_f\flags\flag_blue_co.paa";
							systemChat "[CONQUEST] ERROR: A critical file is missing! (mission\sides\data_side_west.inc)";
						#endif
						_level = 1;
					};
				};

				// Validate the texture path
				if (!fileExists _texture) then {
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

			} forEach (all3DENEntities # 2);

			GVAR(eden_updateSectorFlags) = false;
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
