#include "res\common\macros.inc"

GVAR(debug_devFilePath)   = "dev\debug.sqf";
GVAR(debug_devFileExists) = fileExists GVAR(debug_devFilePath);





// DEBUG
FUNC(debug_addActions) = {

	if (GVAR(debug_devFileExists)) then {
		player addAction ["<t color='#0044FF'>Debug</t>", {
			if (
				isNil "cre_handle_debug") then {cre_handle_debug = scriptNull};
				terminate cre_handle_debug;
				cre_handle_debug = [] spawn compile preprocessFileLineNumbers "dev\debug.sqf"
			},
			nil, 10, false, false, "lockTargets"
		];
	};

	player addAction ["<t color='#FFFF00'>Recompile Functions</t>", {isNil {call compile preprocessFileLineNumbers "dev\fn_recompileFuncs.sqf"}}, nil, 10, false, false];

	player addAction ["<t color='#00DD00'>Init Client + Server</t>", {
		isNil {
			call compile preprocessFileLineNumbers "dev\fn_recompileFuncs.sqf";

			// Rerun the initialisation functions
			call compile preprocessFileLineNumbers "scripts\gamemode\fn_gm_postInit.sqf";
		};
	}, nil, 10, false, false];
};

if (isServer and {hasInterface}) then {
	call FUNC(debug_addActions);
	player addEventHandler ["Respawn", FUNC(debug_addActions)];
};

if (!GVAR(debug_devFileExists)) exitWith {};

GVAR(debug_runDebugFile_isFocused) = false;
addMissionEventHandler ["EachFrame", {
	if (isGameFocused != GVAR(debug_runDebugFile_isFocused)) then {
		GVAR(debug_runDebugFile_isFocused) = isGameFocused;

		if (isGameFocused) then {
			call compile preprocessFileLineNumbers "dev\debug.sqf";
		};
	};
}];
