/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA]
		Returns the unit's UID. Intended for keeping track of server statistics.

		For AI units, this function returns a string that references their unit index.
		For players, this function returns their regular Steam UID.
	Arguments:
		0:	<OBJECT>	The concerned unit
	Returns:
			<STRING>	The unit's UID
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_unit", objNull, [objNull]]
];

if (isNull _unit) exitWith {""};





private ["_UID"];

if (isPlayer _unit) then {
	_UID = getPlayerUID _unit;
} else {
	_UID = "AI_" + str (_unit getVariable [QGVAR(unitIndex), -1]);
};

_UID;
