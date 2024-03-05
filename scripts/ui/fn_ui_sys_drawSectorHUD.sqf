/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles the drawing of the sector HUD.

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
MACRO_FNC_INITVAR(GVAR(ui_sys_drawSectorHUD_EH), -1);





removeMissionEventHandler ["EachFrame", GVAR(ui_sys_drawSectorHUD_EH)];
GVAR(ui_sys_drawSectorHUD_EH) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	private _sectorHUD = uiNamespace getVariable [QGVAR(RscSectorHUD), displayNull];

	if (GVAR(missionState) <= MACRO_ENUM_MISSION_LIVE) then {

		private _player = player;
		private _sector = GVAR(allSectors) param [GVAR(allSectors) findIf {_player inArea _x}, objNull];

		// Only continue if we're within a sector's area
		if (alive _sector and {_player getVariable [QGVAR(canCaptureSectors), false]}) then {

			if (isNull _sectorHUD) then {
				QGVAR(RscSectorHUD) cutRsc [QGVAR(RscSectorHUD), "PLAIN"];
				_sectorHUD = uiNamespace getVariable [QGVAR(RscSectorHUD), displayNull];
			};

			private _ctrlGrp        = _sectorHUD displayCtrl MACRO_IDC_SHUD_CTRLGRP;
			private _ctrlLetter     = _ctrlGrp controlsGroupCtrl MACRO_IDC_SHUD_LETTER_TEXT;
			private _ctrlFlag       = _ctrlGrp controlsGroupCtrl MACRO_IDC_SHUD_FLAG_PICTURE;
			private _ctrlLevelBack  = _ctrlGrp controlsGroupCtrl MACRO_IDC_SHUD_LEVEL_BACK;
			private _ctrlLevelFront = _ctrlGrp controlsGroupCtrl MACRO_IDC_SHUD_LEVEL_FRONT;
			private _ctrlLockIcon   = _ctrlGrp controlsGroupCtrl MACRO_IDC_SHUD_LOCK_ICON;

			// Update the controls
			private _side = _sector getVariable [QGVAR(side), sideEmpty];
			private _sideCapturing = [_side, _sector getVariable [QGVAR(sideCapturing), sideEmpty]] select (_side == sideEmpty);
			private _level = _sector getVariable [QGVAR(level), 0];
			private _maxHeight = ctrlPosition _ctrlGrp # 3;
			private _ctrlPos = ctrlPosition _ctrlLevelFront;
			private _colour = switch (_sideCapturing) do {
				case GVAR(side): {SQUARE(MACRO_COLOUR_A100_FRIENDLY)};
				case sideEmpty:  {SQUARE(MACRO_COLOUR_A100_WHITE)};
				default	         {SQUARE(MACRO_COLOUR_A100_ENEMY)};
			};
			private _locked = _sector getVariable [QGVAR(isLocked), false];

			_ctrlLetter ctrlSetText (_sector getVariable [QGVAR(letter), "?"]);
			_ctrlFlag ctrlSetText ([_side] call FUNC(gm_getFlagTexture));

			_ctrlLevelBack ctrlSetPositionH ((1 - _level) * _maxHeight);
			_ctrlLevelFront ctrlSetPosition [
				_ctrlPos # 0,
				_maxHeight * (1 - _level),
				_ctrlPos # 2,
				_maxHeight * _level
			];
			_ctrlLevelBack ctrlCommit 0;
			_ctrlLevelFront ctrlCommit 0;

			_ctrlLevelFront ctrlSetBackgroundColor _colour;
			_ctrlLockIcon ctrlSetTextColor ([SQUARE(MACRO_COLOUR_A0), SQUARE(MACRO_COLOUR_SECTOR_LOCKED)] select _locked);

		} else {
			if (!isNull _sectorHUD) then {
				QGVAR(RscSectorHUD) cutRsc ["Default", "PLAIN"];
			};
		};

	} else {
		if (!isNull _sectorHUD) then {
			QGVAR(RscSectorHUD) cutRsc ["Default", "PLAIN"];
		};
	};
}];
