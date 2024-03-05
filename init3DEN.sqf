#include "res\common\macros.inc"
#include "mission\settings.inc"





// Remove the old Sync EH
private _display = findDisplay 313;
private _3DEN_eachFrameEH = _display getVariable [QGVAR(eden_EH_eachFrame), -1];

if (_3DEN_eachFrameEH >= 0) then {
	_display displayRemoveEventHandler ["KeyDown", _3DEN_eachFrameEH];
	uiNamespace setVariable [QGVAR(eden_EH_eachFrame), 0];
};

// Add a new EH to detect keypresses (to sync nodes)
_3DEN_eachFrameEH = _display displayAddEventHandler ["KeyDown", {

	//systemChat str _this;
	params ["_display", "_key", "_shift", "_ctrl", "_alt"];

	if (_key == 45) then {	// X
		private _objs = get3DENSelected "object";
		private _cursorObj = get3DENMouseOver param [1, objNull];

		if (!isNull _cursorObj) then {
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
//				systemChat "Test";
				add3DENConnection ["Sync", _objs, _cursorObj];
			};
		};
	};
}];
_display setVariable [QGVAR(eden_EH_eachFrame), _3DEN_eachFrameEH];





// Handle sector flag textures and level
[] spawn {
	while {true} do {
		{
			private _flag = _x;
			{
				_x params ["_linkType", "_linkTo"];

				if (_linkType isEqualTo "Sync") then {

					if (_linkTo isKindOf "EmptyDetector") then {
						private _name = (_linkTo get3DENAttribute "Name") select 0;

						if (_name select [0,7] isEqualTo "sector_") then {
							private _texture = "a3\data_f\flags\flag_white_co.paa";
							private _level = 0;

							switch ((_linkTo get3DENAttribute "ActivationBy") select 0) do {
								case "EAST";
								case "EAST SEIZED": {
									_texture = MACRO_FLAG_TEXTURE_EAST;
									_level = 1;
								};
								case "GUER";
								case "GUER SEIZED": {
									_texture = MACRO_FLAG_TEXTURE_RESISTANCE;
									_level = 1;
								};
								case "WEST";
								case "WEST SEIZED": {
									_texture = MACRO_FLAG_TEXTURE_WEST;
									_level = 1;
								};
							};

							_flag setFlagTexture _texture;
							_flag setFlagAnimationPhase _level;
						};
					};
				};
			} forEach get3DENConnections _flag;
		} forEach ((all3DENEntities # 0) select {_x isKindOf MACRO_CLASS_FLAG});

		uiSleep 0.25;
	};
};
