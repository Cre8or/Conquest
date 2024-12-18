/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Returns the faction data of the given faction.
		If the specified faction enumeration doesn't exist, or the corresponding file is missing, reports an error and
		and returns an empty array instead.
	Arguments:
		0:	<NUMBER>	The faction's enumeration (see macros.inc)
	Returns:
			<ARRAY>		The faction's data array
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_enum", MACRO_ENUM_FACTION_INVALID, [MACRO_ENUM_FACTION_INVALID]]
];





private _filePath = [_enum] call FUNC(fac_getFilePath);
if (_filePath == "") exitWith {[]}; // Error reporting is handled by fac_getFilePath

if (!fileExists _filePath) exitWith {
	private _str = format ["[CONQUEST] (fac_getData) ERROR: File not found! (%1)", _filePath];
	systemChat _str;
	diag_log _str;
	[]
};

private _data = call compile preprocessFileLineNumbers _filePath;
if !(_data isEqualType []) exitWith {
	private _str = format ["[CONQUEST] (fac_getData) ERROR: Faction data is invalid! (%1)", _filePath];
	systemChat _str;
	diag_log _str;
	[]
};

_data
