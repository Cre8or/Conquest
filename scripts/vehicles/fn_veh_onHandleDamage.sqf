/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LA][GE]
		Called whenever a local vehicle's "HandleDamage" EH is executed.
	Arguments:
		(see https://community.bistudio.com/wiki/Arma_3:_Event_Handlers#HandleDamage)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"





// Workaround for return values (see https://community.bistudio.com/wiki/exitWith)
_this call {

	if (GVAR(missionState) < MACRO_ENUM_MISSION_LIVE) exitWith {0};

	// Passed by the engine
	params [
		"_veh",
		"",
		"_damageProcessed",
		"_source",
		"_ammoType", // _projectile
		"",
		"_instigator",
		"_hitPoint",
		"_isDirect",
		"_context"
	];
	_hitPoint = toLower _hitPoint;



	private _maxDamage = (switch (_hitPoint) do {

		// Left wheels
		case "hitlfwheel";
		case "hitlf2wheel";
		case "hitlmwheel";
		case "hitlbwheel";

		// Right wheels
		case "hitrfwheel";
		case "hitrf2wheel";
		case "hitrmwheel";
		case "hitrbwheel": {0.9};

		// Tracks:
		case "hitltrack";
		case "hitrtrack": {0.89};

		// Vitals
		case "hitfuel";
		case "hitengine";
		case "hitengine1";
		case "hitengine2";
		case "hitengine3": {0.9};

		default {999}; // Anything above 1 works
	});

	private _totalDamage = (_veh getHitPointDamage _hitPoint) + _damageProcessed min _maxDamage;
	//diag_log format ["(%1) %2: %3", diag_frameNo, _hitPoint, _damageProcessed];



	_totalDamage;
};
