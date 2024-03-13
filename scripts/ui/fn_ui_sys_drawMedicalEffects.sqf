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
		private _healthPulse    = sin (_time * 80) ^ 2;
		private _healthTotalMul = _healthInvSqr * (0.8 + _healthPulse * 0.2);

		private _lastDamage       = (0.4 + GVAR(ui_med_lastDamageAmount) max 0) min 1.1;
		private _hurtPerc         = (_time - GVAR(ui_med_lastDamageTime)) / (_lastDamage + 1) min 1;
		private _hurtPercInv      = 1 - _hurtPerc;
		private _hurtPercTotal    = 1 - (_hurtPercInv * _lastDamage);
		private _hurtPercInvTotal = _hurtPercInv ^ 2 * _lastDamage;

		private _imagePerc         = _hurtPerc * 3 min 1;
		private _imagePercInv      = 1 - _imagePerc;
		private _imagePercInvTotal = _hurtPercInv ^ 2 * _lastDamage;

		// Health-dependent effect
		GVAR(ui_med_colourFx_health) ppEffectAdjust [
			1 - _healthTotalMul * 0.8,
			1,
			-_healthTotalMul * 0.1,
			[1,0.0,0,0.08 * _healthTotalMul],
			[1,0.6,0.5,1 - _healthTotalMul * 0.8],
			[0.5, 0.5, 0, 0],
			[0.6, 0.6, 0, 0, 0, 0.1, 0.5]
		];
		GVAR(ui_med_colourFx_health) ppEffectCommit 0;

		// Hurt effect
		switch (GVAR(ui_med_lastDamageEnum)) do {

			case MACRO_ENUM_DAMAGE_BULLET;
			case MACRO_ENUM_DAMAGE_EXPLOSIVE: {
				GVAR(ui_med_colourFx_hurt) ppEffectAdjust [
					1,
					1 + _hurtPercInvTotal * 0.5,
					-_hurtPercInvTotal * 0.25,
					[0.4,0,0,_hurtPercInvTotal * 0.95],
					[1,0.6,0.5,1 - _hurtPercInvTotal * 0.6],
					[0.299, 0.587, 0.114, 0],
					[0.25 + _hurtPercTotal * 0.75, 0.25 + _hurtPercTotal * 0.75, 0, 0, 0, 0, 0.5]
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

					_ctrlImage ctrlSetTextColor [1, 1, 1, _imagePercInv];
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
					[0.1 + random 0.02,0,0,_hurtPercInvTotal * 0.9],
					[2,1.75,1.75,1 - _hurtPercInvTotal * 0.5],
					[0.299, 0.587, 0.114, 0],
					[0.25 + _hurtPercTotal * 0.75, 0.25 + _hurtPercTotal * 0.75, 0, 0, 0, 0, 0.5]
				];
			};

		};

		GVAR(ui_med_colourFx_hurt) ppEffectCommit 0;

		GVAR(ui_med_blurFx) ppEffectAdjust [2 * _hurtPercInvTotal ^ 2];
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
