/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Returns an array containing all submunition classnames for the specified projectile classname.
		For better performance, results are cached in a hashmap.
	Arguments:
		0:  <STRING>    The concerned projectile classname
	Returns:
		    <ARRAY>     An array of submunition classnames
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"


params [
	["_class", "", [""]]
];





MACRO_FNC_INITVAR(GVAR(proj_getSubmunitionClasses_cache), createHashMap);

_class = toLower _class;

// If the result is cached, fetch and return it
if (_class in GVAR(proj_getSubmunitionClasses_cache)) exitWith {
	GVAR(proj_getSubmunitionClasses_cache) get _class;
};

// Otherwise, cache and return it
private _result     = [];
private _classX     = _class;
private _configAmmo = configFile >> "CfgAmmo";

scopeName QGVAR(proj_getSubmunitionClasses);

// Limit the loop to 100 iterations for safety
for "_i" from 1 to 100 do {
	_classX = getText (_configAmmo >> _classX >> "submunitionAmmo");

	if (_classX == "") then {
		breakTo QGVAR(proj_getSubmunitionClasses);
	};

	_result pushBack _classX;
};

GVAR(proj_getSubmunitionClasses_cache) set [_class, _result];

_result;
