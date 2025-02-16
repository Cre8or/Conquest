/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Returns the damage data for the specified projectile classname.
		For better performance, results are cached in a hashmap.
	Arguments:
		0:  <STRING>    The concerned projectile classname
	Returns:
		    <ARRAY>     A nested array in format [damageDirect, damageIndirect, damageExplosive]
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"


params [
	["_class", "", [""]]
];





MACRO_FNC_INITVAR(GVAR(proj_getDamageData_cache), createHashMap);

_class = toLower _class;

// If the result is cached, fetch and return it
if (_class in GVAR(proj_getDamageData_cache)) exitWith {
	GVAR(proj_getDamageData_cache) get _class;
};

// Otherwise, cache and return it
private "_result";
switch (_class) do {

	// Edge cases: dampen vehicle cookoff explosions
	case "fuelexplosion";
	case "fuelexplosionbig": {
		_result = [100, 10000, 1]; // Originally [100, 100, 1]
		// Counter-intuitively, boosting indirect damage dampens the explosion, as the calculate damage
		// within unit_onHandleDamage normalises engine-computed damage using this value.
	};

	default {
		private _config          = configFile >> "CfgAmmo" >> _class;
		private _damageDirect    = getNumber (_config >> "hit");
		private _damageIndirect  = getNumber (_config >> "indirectHit");
		private _damageExplosive = getNumber (_config >> "explosive");

		_result = [_damageDirect, _damageIndirect, _damageExplosive];
	};
};

GVAR(proj_getDamageData_cache) set [_class, _result];

_result;
