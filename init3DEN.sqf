#include "res\common\macros.inc"
#include "mission\settings.inc"





// Set up some variables
GVAR(eden_updateSectorFlags) = true;
GVAR(eden_drawData_sectors)  = [];

private _display = findDisplay 313;

// Define some functions
// We can't rely on config-defined functions here as the mission description isn't parsed yet
// (we're still in 3DEN, after all), and we can't rely on any mods/addons to help us out.
// This is janky, but it's the best we can do right now.
private _fnc_eden_cleanupEHs = {

	private _isInit = _display getVariable [QGVAR(isInit), false];
	if (!_isInit) exitWith {
		//systemChat format ["Nothing to clean up (source: %1)", _this];
	};

	//systemChat format ["Cleaning up... (source: %1)", _this];

	private _display             = findDisplay 313;
	private _EH_onMissionLoad    = _display getVariable [QGVAR(EH_onMissionLoad), -1];
	private _EH_onMissionNew     = _display getVariable [QGVAR(EH_onMissionNew), -1];
	private _EH_keyDown          = _display getVariable [QGVAR(EH_keyDown), -1];
	private _EH_onHistoryChanged = _display getVariable [QGVAR(EH_onHistoryChanged), -1];
	private _EH_onUndo           = _display getVariable [QGVAR(EH_onUndo), -1];
	private _EH_onRedo           = _display getVariable [QGVAR(EH_onRedo), -1];
	private _EH_eachFrame        = _display getVariable [QGVAR(EH_eachFrame), -1];
	private _EH_draw3D           = _display getVariable [QGVAR(EH_draw3D), -1];

	remove3DENEventHandler ["OnMissionLoad", _EH_onMissionLoad];
	remove3DENEventHandler ["OnMissionNew", _EH_onMissionNew];

	_display displayRemoveEventHandler ["KeyDown", _EH_keyDown];
	remove3DENEventHandler ["OnHistoryChange", _EH_onHistoryChanged];
	remove3DENEventHandler ["OnUndo", _EH_onUndo];
	remove3DENEventHandler ["OnRedo", _EH_onRedo];
	removeMissionEventHandler ["EachFrame", _EH_eachFrame];
	removeMissionEventHandler ["Draw3D", _EH_draw3D];

	_display setVariable [QGVAR(isInit), false];
};

// Initiate automatic cleanup
// NOTE: there seems to be a bug, as attaching these EHs immediately triggers them.
// Not sure why this is happening, but we need to work around it.
[_fnc_eden_cleanupEHs] spawn {
	params ["_fnc_eden_cleanupEHs"];
	//systemChat "Adding cleanup EHs (deferred)";

	private _display = findDisplay 313;
	private _EH_onMissionLoad = add3DENEventHandler ["OnMissionLoad", _fnc_eden_cleanupEHs];
	_display setVariable [QGVAR(EH_onMissionLoad), _EH_onMissionLoad];

	private _EH_onMissionNew = add3DENEventHandler ["OnMissionNew", _fnc_eden_cleanupEHs];
	_display setVariable [QGVAR(EH_onMissionNew), _EH_onMissionNew];
};

// Manually cleanup on init (in case this file is executed manually)
"init3DEN" call _fnc_eden_cleanupEHs;

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
			systemChat format ["WARNING: ""%1"" is not a valid sector name!", _name];
			//breakTo QGVAR(eden_eachFrame);
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
			systemChat format ["WARNING: Sector %1 has more than one flag! (only one is allowed)", _letter];
			continue;
		};



		// Update the flag's texture and position on the pole to match the sector parameters
		_texture    = "a3\data_f\flags\flag_white_co.paa";
		_level      = 0;
		_activation = (_sector get3DENAttribute "ActivationBy") # 0;
		switch (_activation select [0, 4]) do {
			case "EAST": {
				_texture = MACRO_FLAG_TEXTURE_EAST;
				_level = 1;
			};
			case "GUER": {
				_texture = MACRO_FLAG_TEXTURE_RESISTANCE;
				_level = 1;
			};
			case "WEST": {
				_texture = MACRO_FLAG_TEXTURE_WEST;
				_level = 1;
			};
		};

		_flag setFlagTexture _texture;
		_flag setFlagAnimationPhase _level;

		if (_level > 0) then {
			_isLocked = (_activation select [5, 6] != "SEIZED");
		} else {
			_isLocked = false;
		};
		GVAR(eden_drawData_sectors) pushBack [_sector, _texture, _letter, _isLocked];

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
