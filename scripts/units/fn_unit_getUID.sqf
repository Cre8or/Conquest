/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA]
		Returns the unit's UID. Intended for keeping track of server statistics.

		For AI units, this function returns a string that references their unit index.
		For players, this function returns their regular Steam UID.
	Arguments:
		0:	<OBJECT>	The concerned unit
			OR:
		0:	<NUMBER>	The AI unit index
	Returns:
			<STRING>	The unit's UID
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_unit", objNull, [objNull, 0]]
];


private "_index";
if (_unit isEqualType objNull) then {
	_index = -1;
} else {
	_index = _unit;
	_unit = objNull;
};

if (isNull _unit and {_index < 0}) exitWith {""};





private ["_UID"];

if (isPlayer _unit) then {
	_UID = format ["%1_%2", getPlayerUID _unit, name _unit];

} else {
	if (!isNull _unit) then {
		_index = _unit getVariable [QGVAR(unitIndex), -1];
	};

	_UID = "AI_" + str _index;
};

_UID;
