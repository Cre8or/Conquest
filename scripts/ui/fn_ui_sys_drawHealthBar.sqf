/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles the drawing of the player's health bar.

		Only executed once by the client upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

if (!hasInterface) exitWith {};





// Set up some variables
MACRO_FNC_INITVAR(GVAR(ui_sys_drawHealthBar_EH),-1);

// Define some macros
#define MACRO_BLINK_INTERVAL 0.5





removeMissionEventHandler ["EachFrame", GVAR(ui_sys_drawHealthBar_EH)];
GVAR(ui_sys_drawHealthBar_EH) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	private _healthBar = uiNamespace getVariable [QGVAR(RscHealthBar), displayNull];
	private _player    = player;

	if (GVAR(missionState) <= MACRO_ENUM_MISSION_LIVE and {[_player] call FUNC(unit_isAlive)}) then {

		// Show the health bar
		if (isNull _healthBar) then {
			QGVAR(RscHealthBar) cutRsc [QGVAR(RscHealthBar), "PLAIN"];
			_healthBar = uiNamespace getVariable [QGVAR(RscHealthBar), displayNull];
		};

		private _ctrlBackground = _healthBar displayCtrl MACRO_IDC_HB_HEALTH_BACKGROUND;
		private _ctrlIcon       = _healthBar displayCtrl MACRO_IDC_HB_HEALTH_ICON;
		private _ctrlText       = _healthBar displayCtrl MACRO_IDC_HB_HEALTH_TEXT;
		private _health         = _player getVariable [QGVAR(health), 1];
		private ["_colourText", "_colourBackground"];

		// Below critical health, pulse the health bar
		if (_health < MACRO_UI_HB_LOWHEALTH) then {
			private _inverted = ((time mod (2 * MACRO_BLINK_INTERVAL)) < MACRO_BLINK_INTERVAL);

			_colourBackground = ([SQUARE(MACRO_COLOUR_INGAME_BACKGROUND), SQUARE(MACRO_COLOUR_A100_RED)] select _inverted);
			_colourText       = ([SQUARE(MACRO_COLOUR_A100_RED), SQUARE(MACRO_COLOUR_A100_WHITE)] select _inverted);
		} else {
			_colourBackground = SQUARE(MACRO_COLOUR_INGAME_BACKGROUND);
			_colourText       = SQUARE(MACRO_COLOUR_A100_WHITE);
		};

		_health = floor ((100 * _health min 999) max 1);
		_ctrlText ctrlSetText str _health;

		_ctrlBackground ctrlSetBackgroundColor _colourBackground;
		_ctrlIcon ctrlSetTextColor _colourText;
		_ctrlText ctrlSetTextColor _colourText;

	} else {

		// Hide the health bar
		if (!isNull _healthBar) then {
			QGVAR(RscHealthBar) cutRsc ["Default", "PLAIN"];
		};
	};
}];
