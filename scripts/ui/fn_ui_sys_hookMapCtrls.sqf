/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Attaches the custom UI drawing functions to the main map and any map-based IGUI displays (e.g. GPS).

		Only executed once by the client upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

if (!hasInterface) exitWith {};





// Set up some variales
MACRO_FNC_INITVAR(GVAR(ui_sys_hookMapCtrls_EH), -1);

GVAR(ui_sys_hookMapCtrls_hookedMap)   = false;
GVAR(ui_sys_hookMapCtrls_hookedMapMP) = (time > 0) or !(isMultiplayer or {is3DENMultiplayer}); // Only relevant in multiplayer (on briefing only)
GVAR(ui_sys_hookMapCtrls_hookedIGUIs) = false;





removeMissionEventHandler ["EachFrame", GVAR(ui_sys_hookMapCtrls_EH)];
GVAR(ui_sys_hookMapCtrls_EH) = addMissionEventHandler ["EachFrame", {

	// Hook into the main map
	if (!GVAR(ui_sys_hookMapCtrls_hookedMap)) then {
		private _ctrlMap = (findDisplay 12) displayCtrl 51;	// RscDisplayMainMap

		if (!isNull _ctrlMap) then {
			{
				_ctrlMap ctrlRemoveEventHandler ["Draw", _x];
			} forEach (_ctrlMap getVariable [QGVAR(UI_EH_draw), []]);

			_ctrlMap setVariable [QGVAR(UI_EH_draw), [
				_ctrlMap ctrlAddEventHandler ["Draw", FUNC(ui_drawUnitIcons2D)],
				_ctrlMap ctrlAddEventHandler ["Draw", FUNC(ui_drawSectorFlags)],
				_ctrlMap ctrlAddEventHandler ["Draw", FUNC(ui_drawSectorLocations)],
				_ctrlMap ctrlAddEventHandler ["Draw", FUNC(ui_drawCombatArea_map)]
			]];

			GVAR(ui_sys_hookMapCtrls_hookedMap) = true;
		};
	};

	// Hook into the post-slotting map (multiplayer only)
	if (!GVAR(ui_sys_hookMapCtrls_hookedMapMP)) then {
		private "_ctrlMap";
		if (isServer) then {
			_ctrlMap = (findDisplay 52) displayCtrl 51;	// RscDisplayServerGetReady
		} else {
			_ctrlMap = (findDisplay 53) displayCtrl 51;	// RscDisplayClientGetReady
		};

		if (!isNull _ctrlMap) then {
			{
				_ctrlMap ctrlRemoveEventHandler ["Draw", _x];
			} forEach (_ctrlMap getVariable [QGVAR(UI_EH_draw), []]);

			_ctrlMap setVariable [QGVAR(UI_EH_draw), [
				_ctrlMap ctrlAddEventHandler ["Draw", FUNC(ui_drawSectorFlags)],
				_ctrlMap ctrlAddEventHandler ["Draw", FUNC(ui_drawSectorLocations)],
				_ctrlMap ctrlAddEventHandler ["Draw", FUNC(ui_drawCombatArea_map)]
			]];

			[_ctrlMap, MACRO_UI_MAPFOCUS_PADDING_FULLSCREEN] call FUNC(ui_focusMap);

			// Bonus: center the cursor (prevents accidental panning)
			setMousePosition [0.5, 0.5];

			GVAR(ui_sys_hookMapCtrls_hookedMapMP) = true;
		};
	};

	// Hook into all map panels (GPS and helicopter terrain avoidance)
	if (!GVAR(ui_sys_hookMapCtrls_hookedIGUIs)) then {
		{
			private _ctrlMap = _x displayCtrl 101;	// See a3/ui_f/config.cpp

			if (!isNull _ctrlMap) then {
				{
					_ctrlMap ctrlRemoveEventHandler ["Draw", _x];
				} forEach (_ctrlMap getVariable [QGVAR(UI_EH_draw), []]);

				_ctrlMap setVariable [QGVAR(UI_EH_draw), [
					_ctrlMap ctrlAddEventHandler ["Draw", FUNC(ui_drawUnitIcons2D)],
					_ctrlMap ctrlAddEventHandler ["Draw", FUNC(ui_drawSectorFlags)],
					_ctrlMap ctrlAddEventHandler ["Draw", FUNC(ui_drawCombatArea_gps)]
				]];

				GVAR(ui_sys_hookMapCtrls_hookedIGUIs) = true;
			};
		} forEach ((uiNamespace getVariable ["IGUI_Displays", []]) select {ctrlIDD _x == 311});	// See a3/ui_f/config.cpp
	};





	// Clean up once all map controls have been hooked into
	if (
		GVAR(ui_sys_hookMapCtrls_hookedMap)
		and {GVAR(ui_sys_hookMapCtrls_hookedMapMP)}
		and {GVAR(ui_sys_hookMapCtrls_hookedIGUIs)}
	) then {
		removeMissionEventHandler ["EachFrame", GVAR(ui_sys_hookMapCtrls_EH)];
		GVAR(ui_sys_hookMapCtrls_EH) = -1;
	};
}];
