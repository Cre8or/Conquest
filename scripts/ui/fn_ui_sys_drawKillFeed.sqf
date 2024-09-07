/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles the drawing of the kill feed. Data is added to the kill feed by calling
		gm_processKillFeedEvent.

		Only executed once by the client upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"
#include "..\..\res\macros\tween_rampDown.inc"

if (!hasInterface) exitWith {};





// Set up some variables
MACRO_FNC_INITVAR(GVAR(ui_sys_drawKillFeed_EH), -1);

GVAR(ui_sys_drawKillFeed_data)  = [];
GVAR(ui_sys_drawKillFeed_ctrls) = [];

// Open the UI
QGVAR(RscKillFeed) cutRsc [QGVAR(RscKillFeed), "PLAIN"];





removeMissionEventHandler ["EachFrame", GVAR(ui_sys_drawKillFeed_EH)];
GVAR(ui_sys_drawKillFeed_EH) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	private _time = time;
	private _indexLastData = count GVAR(ui_sys_drawKillFeed_data) - 1;
	private _indexLastCtrl = count GVAR(ui_sys_drawKillFeed_ctrls) - 1;

	private _UI = uiNamespace getVariable [QGVAR(RscKillFeed), displayNull];
	private _ctrlGrpMain = _UI displayCtrl MACRO_IDC_KF_CTRLGRP;
	private _animEndTime = _UI getVariable [QGVAR(animEndTime), 0];
	private _animOffset  = _UI getVariable [QGVAR(animOffset), 0];
	private _animPhase   =  MACRO_TWEEN_RAMPDOWN(_time, _animEndTime, MACRO_UI_KILLFEED_ANIMDURATION);

	private ["_ctrls", "_indexRev", "_nameKillerWidth", "_nameVictimWidth", "_weaponIconWidth", "_iconPosX", "_fade", "_col"];

	// Draw the kill feed
	for "_index" from _indexLastData to 0 step -1 do {

		(GVAR(ui_sys_drawKillFeed_data) # _index) params [
			"_endTime",
			"_nameKiller",
			"_iconEnum",
			"_weaponIcon",
			"_nameVictim",
			["_killerColour", SQUARE(MACRO_COLOUR_A100_WHITE)],
			["_victimColour", SQUARE(MACRO_COLOUR_A100_WHITE)]
		];
		_ctrls = GVAR(ui_sys_drawKillFeed_ctrls) param [_index, []];
		_ctrls params ["_ctrlGrp", "_ctrlBackgroundVictim", "_ctrlNameVictim", "_ctrlBackgroundWeapon", "_ctrlSpecialIcon", "_ctrlWeapon", "_ctrlBackgroundKiller", "_ctrlNameKiller"];

		if (_endTime < _time) then {
			GVAR(ui_sys_drawKillFeed_data) deleteAt _index;
			{
				ctrlDelete _x;
			} forEach (GVAR(ui_sys_drawKillFeed_ctrls) deleteAt _index);

		} else {

			// Create new controls for this entry
			if (_index > _indexLastCtrl) then {
				_ctrlGrp = _UI ctrlCreate ["RscControlsGroupNoScrollbars", -1, _ctrlGrpMain];

				// Reset the animation
				_animEndTime = _time + MACRO_UI_KILLFEED_ANIMDURATION;
				_animOffset  = _animOffset * _animPhase + MACRO_POS_KF_ENTRY_HEIGHT;
				_animPhase   = 1;

				_ctrlSpecialIcon      = controlNull;
				_ctrlIconRoadKill     = controlNull;
				_ctrlBackgroundKiller = controlNull;
				_ctrlNameKiller       = controlNull;

				_UI setVariable [QGVAR(animEndTime), _animEndTime];
				_UI setVariable [QGVAR(animOffset),  _animOffset];

				// If no killer is assigned, move the victim's name control to the right (treat the entry as suicide)
				if (_nameKiller == "") then {
					_nameKillerWidth = 0;
				} else {
					// Add the width of 'w' as padding, since text controls seem to have a starting offset from their alignment side
					_nameKillerWidth = ("w" + _nameKiller) getTextWidth [MACRO_FONT_UI_MEDIUM, MACRO_POS_KF_ENTRY_TEXTSIZE];
				};

				_nameVictimWidth = ("w" + _nameVictim) getTextWidth [MACRO_FONT_UI_MEDIUM, MACRO_POS_KF_ENTRY_TEXTSIZE];

				// Determine the total weapon icon width
				if (_iconEnum != MACRO_ENUM_KF_ICON_NONE) then {
					_weaponIconWidth = MACRO_POS_KF_ICON_WIDTH + MACRO_POS_KF_WEAPON_WIDTH;
				} else {
					_weaponIconWidth = MACRO_POS_KF_WEAPON_WIDTH;
				};
				_iconPosX = (MACRO_POS_KF_WIDTH - _weaponIconWidth) / 2;

				// Killer
				if (_nameKiller != "") then {
					_ctrlBackgroundKiller = _UI ctrlCreate [QGVAR(RscFrame), -1, _ctrlGrp];
					_ctrlBackgroundKiller ctrlSetPosition [
						(MACRO_POS_KF_WIDTH - _weaponIconWidth) / 2 - _nameKillerWidth,
						0,
						_nameKillerWidth,
						MACRO_POS_KF_ENTRY_HEIGHT
					];
					_ctrlBackgroundKiller ctrlCommit 0;
					_ctrlBackgroundKiller setVariable [QGVAR(fillColour), SQUARE(MACRO_COLOUR_INGAME_BACKGROUND)];
					_ctrlBackgroundKiller ctrlSetPixelPrecision 2;

					_ctrlNameKiller = _UI ctrlCreate [QGVAR(RscKillFeed_Name_Killer), -1, _ctrlGrp];
					_ctrlNameKiller ctrlSetPosition [
						0,
						0,
						(MACRO_POS_KF_WIDTH - _weaponIconWidth) / 2,
						MACRO_POS_KF_ENTRY_HEIGHT
					];
					_ctrlNameKiller ctrlCommit 0;
					_ctrlNameKiller ctrlSetText _nameKiller;
					_ctrlNameKiller setVariable [QGVAR(textColour), _killerColour];
				};

				// Weapon
				_ctrlBackgroundWeapon = _UI ctrlCreate [QGVAR(RscFrame), -1, _ctrlGrp];
				_ctrlBackgroundWeapon ctrlSetPosition [
					_iconPosX,
					0,
					_weaponIconWidth,
					MACRO_POS_KF_ENTRY_HEIGHT
				];
				_ctrlBackgroundWeapon ctrlCommit 0;
				_ctrlBackgroundWeapon setVariable [QGVAR(fillColour), SQUARE(MACRO_COLOUR_A50_WHITE)];
				_ctrlBackgroundWeapon ctrlSetPixelPrecision 2;

				_ctrlWeapon = _UI ctrlCreate [QGVAR(RscPicture), -1, _ctrlGrp];
				_ctrlWeapon ctrlSetPosition [
					_iconPosX,
					0,
					MACRO_POS_KF_WEAPON_WIDTH,
					MACRO_POS_KF_ENTRY_HEIGHT
				];
				_ctrlWeapon ctrlCommit 0;
				_ctrlWeapon ctrlSetText _weaponIcon;
				_ctrlWeapon setVariable [QGVAR(textColour), SQUARE(MACRO_COLOUR_A100_BLACK)];

				// Special icon
				if (_iconEnum != MACRO_ENUM_KF_ICON_NONE) then {
					_ctrlSpecialIcon = _UI ctrlCreate [QGVAR(RscPicture), -1, _ctrlGrp];
					_ctrlSpecialIcon ctrlSetPosition [
						_iconPosX + MACRO_POS_KF_WEAPON_WIDTH,
						0,
						MACRO_POS_KF_ICON_WIDTH,
						MACRO_POS_KF_ENTRY_HEIGHT
					];
					_ctrlSpecialIcon ctrlCommit 0;
					_ctrlSpecialIcon setVariable [QGVAR(textColour), SQUARE(MACRO_COLOUR_A100_BLACK)];
					_ctrlSpecialIcon ctrlSetText (switch (_iconEnum) do {
						case MACRO_ENUM_KF_ICON_HEADSHOT:  {MACRO_KF_ICON_HEADSHOT};
						case MACRO_ENUM_KF_ICON_ROADKILL:  {MACRO_KF_ICON_ROADKILL};
						case MACRO_ENUM_KF_ICON_MINE:      {MACRO_KF_ICON_MINE};
						case MACRO_ENUM_KF_ICON_EXPLOSIVE: {MACRO_KF_ICON_EXPLOSIVE};
						default                            {""};
					});
				};

				// Victim
				_ctrlBackgroundVictim = _UI ctrlCreate [QGVAR(RscFrame), -1, _ctrlGrp];
				_ctrlBackgroundVictim ctrlSetPosition [
					(MACRO_POS_KF_WIDTH + _weaponIconWidth) / 2,
					0,
					_nameVictimWidth,
					MACRO_POS_KF_ENTRY_HEIGHT
				];
				_ctrlBackgroundVictim ctrlCommit 0;
				_ctrlBackgroundVictim setVariable [QGVAR(fillColour), SQUARE(MACRO_COLOUR_INGAME_BACKGROUND)];
				_ctrlBackgroundVictim ctrlSetPixelPrecision 2;

				_ctrlNameVictim = _UI ctrlCreate [QGVAR(RscKillFeed_Name_Victim), -1, _ctrlGrp];
				_ctrlNameVictim ctrlSetPosition [
					(MACRO_POS_KF_WIDTH + _weaponIconWidth) / 2,
					0,
					(MACRO_POS_KF_WIDTH - _weaponIconWidth) / 2,
					MACRO_POS_KF_ENTRY_HEIGHT
				];
				_ctrlNameVictim ctrlCommit 0;
				_ctrlNameVictim ctrlSetText _nameVictim;
				_ctrlNameVictim setVariable [QGVAR(textColour), _victimColour];

				_ctrls = [_ctrlGrp, _ctrlBackgroundVictim, _ctrlNameVictim, _ctrlBackgroundWeapon, _ctrlSpecialIcon, _ctrlWeapon, _ctrlBackgroundKiller, _ctrlNameKiller];

				GVAR(ui_sys_drawKillFeed_ctrls) set [_index, _ctrls];
			};

			// Animate the entry
			_indexRev = _indexLastData - _index;
			_ctrlGrp ctrlSetPosition [0, _indexRev * MACRO_POS_KF_ENTRY_HEIGHT - _animOffset * _animPhase];
			_ctrlGrp ctrlCommit 0;

			// Fade the solid controls
			_fade = ((_endTime - _time) min MACRO_UI_KILLFEED_ENTRYFADEDURATION) / MACRO_UI_KILLFEED_ENTRYFADEDURATION;
			{
				_col = +(_x getVariable [QGVAR(fillColour), [1,1,1,1]]);
				_col set [3, (_col # 3) * _fade];
				_x ctrlSetBackgroundColor _col;
			} forEach [
				_ctrlBackgroundVictim,
				_ctrlBackgroundWeapon,
				_ctrlBackgroundKiller
			];

			// Fade the text controls
			{
				_col = +(_x getVariable [QGVAR(textColour), [1,1,1,1]]);
				_col set [3, (_col # 3) * _fade];
				_x ctrlSetTextColor _col;
			} forEach [
				_ctrlNameKiller,
				_ctrlSpecialIcon,
				_ctrlWeapon,
				_ctrlNameVictim
			];
		};
	};
}];
