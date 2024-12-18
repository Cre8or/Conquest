/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Returns the relative file path to the faction data file associated with the given faction enumeration.
		If the specified faction enumeration doesn't exist, reports an error and returns an empty string instead.
	Arguments:
		0:	<NUMBER>	The faction's enumeration (see macros.inc)
	Returns:
			<STRING>	The faction data's file path
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_enum", MACRO_ENUM_FACTION_INVALID, [MACRO_ENUM_FACTION_INVALID]]
];





private _prefix = "res\factions\";

switch (_enum) do {
	case MACRO_ENUM_FACTION_NATO: {_prefix + "faction_nato.inc"};
	case MACRO_ENUM_FACTION_AAF:  {_prefix + "faction_aaf.inc"};
	case MACRO_ENUM_FACTION_CSAT: {_prefix + "faction_csat.inc"};
	case MACRO_ENUM_FACTION_USMC: {_prefix + "faction_usmc.inc"};
	case MACRO_ENUM_FACTION_AFRF: {_prefix + "faction_afrf.inc"};

	// Not an error, but we still need to return an empty string
	case MACRO_ENUM_FACTION_INVALID: {""};

	// Error handling for unknown factions
	default {
		private _str = format ["[CONQUEST] (fac_getFilePath) ERROR: Unknown faction enumeration! (%1)", _enum];
		systemChat _str;
		diag_log _str;
		""
	};
};
