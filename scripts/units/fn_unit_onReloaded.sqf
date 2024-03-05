/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LA][GE]
		Called whenever a local unit's "Reloaded" EH is executed.
		Used to infinitely resupply AI units with magazines, preventing them from running out of ammo.
	Arguments:
		(see https://community.bistudio.com/wiki/Arma_3:_Event_Handlers#Reloaded)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

// Passed by the engine
params [
	"_unit",
	"_weapon",
	"",
	"_newMagazine",
	"_oldMagazine"
];

if (!local _unit or {!([_unit] call FUNC(unit_isAlive))}) exitWith {};





// Only refill primary weapon and handgun ammo
if (_weapon == primaryWeapon _unit or {_weapon == handgunWeapon _unit}) then {

        // Figure out the magazine classname
        private _magClass = _oldMagazine param [0, ""];
        if (_magClass == "") then {
                _magClass = _newMagazine param [0, ""];
        };

        // Add a new magazine to the unit
        _unit addMagazine _magClass;
};
