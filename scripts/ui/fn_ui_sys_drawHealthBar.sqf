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

		private _ctrlIcon = _healthBar displayCtrl MACRO_IDC_HB_HEALTH_ICON;
		private _ctrlText = _healthBar displayCtrl MACRO_IDC_HB_HEALTH_TEXT;

		private _health = floor ((100 * (_player getVariable [QGVAR(health), 1]) min 999) max 1);
		private _colour = ([SQUARE(MACRO_COLOUR_A100_RED), SQUARE(MACRO_COLOUR_A100_WHITE)] select (_health > 50));

		_ctrlText ctrlSetText str _health;
		_ctrlIcon ctrlSetTextColor _colour;
		_ctrlText ctrlSetTextColor _colour;

	} else {

		// Hide the health bar
		if (!isNull _healthBar) then {
			QGVAR(RscHealthBar) cutRsc ["Default", "PLAIN"];
		};
	};
}];
