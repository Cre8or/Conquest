/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles the drawing of the player's medical effects.

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
MACRO_FNC_INITVAR(GVAR(EH_ui_sys_drawMedicalEffects), -1);
MACRO_FNC_INITVAR(GVAR(ui_med_lastDamageTime), -9e9);
MACRO_FNC_INITVAR(GVAR(ui_med_lastDamageEnum), MACRO_ENUM_DAMAGE_UNKNOWN);
MACRO_FNC_INITVAR(GVAR(ui_med_lastDamageSource), objNull);
MACRO_FNC_INITVAR(GVAR(ui_med_lastDamageSourcePos), getPosWorld GVAR(ui_med_lastDamageSource));





removeMissionEventHandler ["EachFrame", GVAR(EH_ui_sys_drawMedicalEffects)];
GVAR(EH_ui_sys_drawMedicalEffects) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	private _player = player;
	if (
		GVAR(missionState) == MACRO_ENUM_MISSION_LIVE
		and {[_player] call FUNC(unit_isAlive)}
	) then {

		if (!ppEffectEnabled GVAR(ui_med_colourFx_hurt)) then {
			GVAR(ui_med_colourFx_hurt) ppEffectEnable true;
			GVAR(ui_med_colourFx_health) ppEffectEnable true;
			GVAR(ui_med_blurFx) ppEffectEnable true;
		};

		private _time           = time;
		private _ply            = player;
		private _health         = ((_ply getVariable [QGVAR(health), 1]) min 1) max 0;
		private _healthInvSqr   = (1 - _health) ^ 2;
		private _hurtPerc       = (_time - GVAR(ui_med_lastDamageTime)) / 1 min 1;
		private _hurtPercInv    = 1 - _hurtPerc;
		private _hurtPercInvSqr = _hurtPercInv ^ 2;

		// Health-dependent effect
		GVAR(ui_med_colourFx_health) ppEffectAdjust [
			1 - _healthInvSqr * 0.7,
			1,
			-_healthInvSqr * 0.1,
			[1,0.0,0,0.025 * _healthInvSqr],
			[1,0.9,0.85,1 - _healthInvSqr * 0.9],
			[0.5, 0.5, 0, 0],
			[0.75, 0.75, 0, 0, 0, 0.25, 0.5]
		];
		GVAR(ui_med_colourFx_health) ppEffectCommit 0;

		// Hurt effect
		switch (GVAR(ui_med_lastDamageEnum)) do {

			case MACRO_ENUM_DAMAGE_BULLET;
			case MACRO_ENUM_DAMAGE_EXPLOSIVE: {
				GVAR(ui_med_colourFx_hurt) ppEffectAdjust [
					1,
					1 + _hurtPercInvSqr * 0.5,
					-_hurtPercInvSqr * 0.25,
					[0.25 + random 0.05,0,0,_hurtPercInvSqr * 0.75],
					[1,0.5,0.5,1 - _hurtPercInvSqr * 0.5],
					[0.299, 0.587, 0.114, 0],
					[0.25 + _hurtPerc * 0.75, 0.25 + _hurtPerc * 0.75, 0, 0, 0, 0, 0.5]
				];

				// Damage source effect
				private _hitEffect = uiNamespace getVariable [QGVAR(RscHitEffect), displayNull];

				if (
					_hurtPercInv > 0
					and {GVAR(ui_med_lastDamageSource) != _ply}
					and {!isNull GVAR(ui_med_lastDamageSource) or {GVAR(ui_med_lastDamageSourcePos) isNotEqualTo [0,0,0]}}
				) then {
					if (isNull _hitEffect) then {
						QGVAR(RscHitEffect) cutRsc [QGVAR(RscHitEffect), "PLAIN", 1, false];
						_hitEffect = uiNamespace getVariable [QGVAR(RscHitEffect), displayNull];
					};

					// Update the position
					if (!isNull GVAR(ui_med_lastDamageSource)) then {
						GVAR(ui_med_lastDamageSourcePos) = getPosWorld GVAR(ui_med_lastDamageSource);
					};

					private _ctrlImage = _hitEffect displayCtrl MACRO_IDC_HFX_HIT_EFFECT_IMAGE;
					private _angle = _ply getRelDir GVAR(ui_med_lastDamageSourcePos);

					_ctrlImage ctrlSetTextColor [1, 1, 1, _hurtPercInvSqr];
					_ctrlImage ctrlSetPosition [
						MACRO_POS_HFX_WIDTH * (0.01 - random 0.02),
						MACRO_POS_HFX_WIDTH * (0.01 - random 0.02),
						MACRO_POS_HFX_WIDTH,
						MACRO_POS_HFX_HEIGHT
					];

					_ctrlImage ctrlSetAngle [_angle, 0.5, 0.5];
					_ctrlImage ctrlCommit 0;

				} else {
					if (!isNull _hitEffect) then {
						QGVAR(RscHitEffect) cutRsc ["Default", "PLAIN"];
					};
				};
			};

			case MACRO_ENUM_DAMAGE_PHYSICS: {
				GVAR(ui_med_colourFx_hurt) ppEffectAdjust [
					1,
					1,
					0,
					[0.1 + random 0.02,0,0,_hurtPercInvSqr * 0.9],
					[2,1.75,1.75,1 - _hurtPercInvSqr * 0.5],
					[0.299, 0.587, 0.114, 0],
					[0.25 + _hurtPerc * 0.75, 0.25 + _hurtPerc * 0.75, 0, 0, 0, 0, 0.5]
				];
			};

		};

		GVAR(ui_med_colourFx_hurt) ppEffectCommit 0;

		GVAR(ui_med_blurFx) ppEffectAdjust [_hurtPercInvSqr ^ 2];
		GVAR(ui_med_blurFx) ppEffectCommit 0;

	} else {
		if (ppEffectEnabled GVAR(ui_med_colourFx_hurt)) then {
			GVAR(ui_med_colourFx_hurt) ppEffectEnable false;
			GVAR(ui_med_colourFx_health) ppEffectEnable false;
			GVAR(ui_med_blurFx) ppEffectEnable false;

			GVAR(ui_med_lastDamageTime) = -9e9;

			QGVAR(RscHitEffect) cutRsc ["Default", "PLAIN"];
		};
	};
}];
