/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Monitors the player's position and displays a warning if the player leaves the combat area.
		Executed once upon client init.
	Arguments:
		(none)
	Returns:
		(none)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"

#include "..\..\res\macros\fnc_initVar.inc"





#define MACRO_CA_UPDATEDELAY 0.1	// How long, in seconds, the delay between two combat area checks should be (to reduce the performance impact)
#define MACRO_CA_ANIMATIONDELAY 0.1	// How long, in seconds, the UI animation transitions should last

// Set up some variables
MACRO_FNC_INITVAR(GVAR(EH_ca_handleCombatArea_player),-1);
MACRO_FNC_INITVAR(GVAR(EH_ca_warningUI),-1);

GVAR(CA_player_wasInCombatArea) = true;
GVAR(CA_player_punishTime) = 0;
GVAR(CA_player_nextUpdate) = 0;

// Remove the UI, if it is present
QGVAR(RscCombatArea) cutRsc ["Default", "PLAIN"];





removeMissionEventHandler ["EachFrame", GVAR(EH_ca_handleCombatArea_player)];
removeMissionEventHandler ["EachFrame", GVAR(EH_ca_warningUI)];

GVAR(EH_ca_handleCombatArea_player) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	private _time = time;

	// Check if we're allowed to test the combat area in this frame
	if (_time > GVAR(CA_player_nextUpdate)) then {

		// (Re)set some variables
		GVAR(CA_player_isInCombatArea) = true;
		private _player = player;

		// Only continue if the player is alive
		if (GVAR(missionState) == MACRO_ENUM_MISSION_LIVE and {[_player] call FUNC(unit_isAlive)}) then {

			private _combatArea = missionNamespace getVariable [format [QGVAR(CA_%1), GVAR(side)], []];

			if !(_combatArea isEqualTo []) then {

				// Determine whether the player is inside the combat area
				GVAR(CA_player_isInCombatArea) = (getPos _player inPolygon _combatArea);
			};
		};



		// If the player's combat area status changed (they left or entered the combat area), check what we should do
		if !(GVAR(CA_player_wasInCombatArea) isEqualTo GVAR(CA_player_isInCombatArea)) then {

			// If the player was previously outside of the combat area and just returned to it, remove the warning message
			if (GVAR(CA_player_isInCombatArea)) then {

				// Remove the combat area warning display
				QGVAR(RscCombatArea) cutRsc ["Default", "PLAIN"];

				// Remove the eachFrame EH
				removeMissionEventHandler ["EachFrame", GVAR(EH_ca_warningUI)];

				// Remove the colour correction FX
				GVAR(ui_ca_colourFx) ppEffectAdjust [1, 1, 0, [0,0,0,0], [1,1,1,1], [0,0,0,0], [0,0,0,0,0,0,0]];
				GVAR(ui_ca_colourFx) ppEffectCommit MACRO_CA_ANIMATIONDELAY;

			// Otherwise, if the player just left the combat area, display the warning message
			} else {
				GVAR(CA_player_punishTime) = _time + MACRO_CA_DELAYUNTILDEATH;

				// Start the combat area warning display
				QGVAR(RscCombatArea) cutRsc [QGVAR(RscCombatArea), "PLAIN"];

				// Update the display every frame
				GVAR(EH_ca_warningUI) = addMissionEventHandler ["EachFrame", {
					private _ctrlGrp = (uiNamespace getVariable [QGVAR(RscCombatArea), displayNull]) displayCtrl MACRO_IDC_CA_CTRLGRP;
					private _ctrlText = _ctrlGrp controlsGroupCtrl MACRO_IDC_CA_TEXT_COUNTDOWN;

					_ctrlText ctrlSetText (str (100 + ceil (GVAR(CA_player_punishTime) - time) max 0) select [1, 2]);		// Displays the remaining seconds with a leading 0 (if needed)
				}];

				// Perform a small fade-in animation
				private _ctrlGrp = (uiNamespace getVariable [QGVAR(RscCombatArea), displayNull]) displayCtrl MACRO_IDC_CA_CTRLGRP;
				private _ctrlPos = ctrlPosition _ctrlGrp;
				_ctrlGrp ctrlSetPositionY (_ctrlPos # 1 + (_ctrlPos # 3) / 2);
				_ctrlGrp ctrlSetPositionH 0;
				_ctrlGrp ctrlCommit 0;

				_ctrlGrp ctrlSetPosition _ctrlPos;
				_ctrlGrp ctrlCommit MACRO_CA_ANIMATIONDELAY;

				// Enable the colour correction FX
				GVAR(ui_ca_colourFx) ppEffectAdjust [1, 1, 0, [0,0,0,0], [1,1,1,0], [0.5,0.5,0.5,0], [0,0,0,0,0,0,0]];
				GVAR(ui_ca_colourFx) ppEffectCommit MACRO_CA_ANIMATIONDELAY;

				// Play a radio callout
				[MACRO_ENUM_RADIOMSG_LEAVINGCOMBATAREA] call FUNC(gm_playRadioMsg);
			};

			GVAR(CA_player_wasInCombatArea) = GVAR(CA_player_isInCombatArea);

		// Otherwise, if no change occured...
		} else {

			// ...if the player is outside of the combat area for too long, kill him
			if (!GVAR(CA_player_isInCombatArea) and {_time > GVAR(CA_player_punishTime)}) then {
				_player setDamage 1;
				[_player, _player] remoteExecCall [QFUNC(ui_processKillFeedEvent), 0, false];
			};
		};

		GVAR(CA_player_nextUpdate) = _time + MACRO_CA_UPDATEDELAY;
	};
}];
