/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Monitors the player's position and displays a warning if the player leaves the combat area.

		Only executed once by the client upon initialisation.
	Arguments:
		(none)
	Returns:
		(none)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"
#include "..\..\res\macros\fnc_tweens.inc"





// Set up some variables
MACRO_FNC_INITVAR(GVAR(ca_sys_playerCombatArea_EH), -1);

MACRO_FNC_INITVAR(GVAR(ui_ca_colourFx), -1);

GVAR(ca_sys_playerCombatArea_state)      = true;
GVAR(ca_sys_playerCombatArea_leaveTime)  = 0;
GVAR(ca_sys_playerCombatArea_nextUpdate) = 0;

// Clear the UI, if it is present
QGVAR(RscCombatArea) cutRsc ["Default", "PLAIN"];





// Handle the player leaving the combat area
removeMissionEventHandler ["EachFrame", GVAR(ca_sys_playerCombatArea_EH)];
GVAR(ca_sys_playerCombatArea_EH) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	// Update the state periodically
	private _time = time;

	if (_time > GVAR(ca_sys_playerCombatArea_nextUpdate)) then {

		private _player   = player;
		private _newState = true; // Default to true (inside the combat area)

		if (
			GVAR(missionState) == MACRO_ENUM_MISSION_LIVE
		 	and {[_player] call FUNC(unit_isAlive)}
		) then {
			_newState = [getPosWorld _player, GVAR(side)] call FUNC(ca_isInCombatArea);
		};

		#ifdef MACRO_DEBUG_CA_DISABLED
			_newState = true;
		#endif

		// Act on state changes (the player left or entered the combat area)
		if (_newState != GVAR(ca_sys_playerCombatArea_state)) then {

			// If the player was previously outside of the combat area and just returned to it, remove the warning message
			if (_newState) then {
				QGVAR(RscCombatArea) cutRsc ["Default", "PLAIN"];

				// Remove the colour correction FX
				GVAR(ui_ca_colourFx) ppEffectAdjust [1, 1, 0, [0,0,0,0], [1,1,1,1], [0.299, 0.587, 0.114, 0], [0,0,0,0,0,0,0]];
				GVAR(ui_ca_colourFx) ppEffectCommit MACRO_CA_WARNING_ANIMDURATION;

			} else {
				GVAR(ca_sys_playerCombatArea_leaveTime) = _time;

				// Start the combat area warning display
				QGVAR(RscCombatArea) cutRsc [QGVAR(RscCombatArea), "PLAIN"];

				// Enable the colour correction FX
				GVAR(ui_ca_colourFx) ppEffectAdjust [1, 1, 0, [0,0,0,0], [1,1,1,0], [0.299, 0.587, 0.114, 0], [0,0,0,0,0,0,0]];
				GVAR(ui_ca_colourFx) ppEffectCommit MACRO_CA_WARNING_ANIMDURATION;

				// Play a radio callout
				[MACRO_ENUM_RADIOMSG_LEAVINGCOMBATAREA] call FUNC(gm_playRadioMsg);
			};

			GVAR(ca_sys_playerCombatArea_state) = _newState;
		};

		// If the player is outside of the combat area for too long, kill them
		if (!_newState and {_time > GVAR(ca_sys_playerCombatArea_leaveTime) + GVAR(param_ca_graceDuration)}) then {
			[_player, -1, MACRO_ENUM_DAMAGE_COMBATAREA, _player, _player, false] call FUNC(gm_processUnitDamage);
		};

		GVAR(ca_sys_playerCombatArea_nextUpdate) = _time + MACRO_CA_PLAYER_INTERVAL;
	};



	// Update the display every frame, if it is open
	private _display = uiNamespace getVariable [QGVAR(RscCombatArea), displayNull];

	if (!isNull _display) then {
		private _ctrlGrp  = _display displayCtrl MACRO_IDC_CA_CTRLGRP;
		private _ctrlText = _ctrlGrp controlsGroupCtrl MACRO_IDC_CA_TEXT_COUNTDOWN;
		private _ctrlPos   = ctrlPosition _ctrlGrp;

		// Perform a fade-in animation, starting centered and expanding vertically in both directions

		private _animPhase = MACRO_TWEEN_CUBIC_OUT(GVAR(ca_sys_playerCombatArea_leaveTime), _time, MACRO_CA_WARNING_ANIMDURATION);
		_ctrlGrp ctrlSetPositionY (safeZoneY + safezoneH / 2 - MACRO_POS_CA_HEIGHT * (0.5 + 0.5 * _animPhase));
		_ctrlGrp ctrlSetPositionH (MACRO_POS_CA_HEIGHT * _animPhase);
		_ctrlGrp ctrlCommit 0;

		// Update the countdown
		private _delay = ceil ((GVAR(ca_sys_playerCombatArea_leaveTime) + GVAR(param_ca_graceDuration) - _time) max 0);
		_ctrlText ctrlSetText str _delay;
	};
}];
