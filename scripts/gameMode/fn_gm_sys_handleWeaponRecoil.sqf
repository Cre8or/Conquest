/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Handles the per-muzzle weapon recoil for the player. Custom recoil multipliers are set inside the faction
		definition files and only apply to player units.

		Only executed once by the client upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

if (!hasInterface) exitWith {};





MACRO_FNC_INITVAR(GVAR(gm_sys_handleWeaponRecoil_EH), -1);

GVAR(gm_sys_handleWeaponRecoil_prevMuzzle) = "";





removeMissionEventHandler ["EachFrame", GVAR(gm_sys_handleWeaponRecoil_EH)];
GVAR(gm_sys_handleWeaponRecoil_EH) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	private _player = player;
	private _muzzle = currentMuzzle _player;

	// Trigger on muzzle changes
	if (_muzzle == GVAR(gm_sys_handleWeaponRecoil_prevMuzzle)) exitWith {};
	GVAR(gm_sys_handleWeaponRecoil_prevMuzzle) = _muzzle;

	private _muzzleRecoilMulCache = missionNamespace getVariable [format [QGVAR(muzzleRecoilMulCache_%1), GVAR(side)], createHashMap];
	private _recoilMul = _muzzleRecoilMulCache getOrDefault [_muzzle, 1];

	_player setUnitRecoilCoefficient _recoilMul;
	systemChat format ["Recoil multiplier: %1 (%2)", _recoilMul, GVAR(gm_sys_handleWeaponRecoil_prevMuzzle)];
}];
