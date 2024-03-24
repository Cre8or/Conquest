/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Returns the icon associated with the given ability enumeration. Used for the drawing of UI icons.
	Arguments:
		0:	<NUMBER>	The ability enumeration
	Returns:
			<STRING>	The icon associated with the ability
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_ability", MACRO_ENUM_LOADOUT_ABILITY_INVALID, [MACRO_ENUM_LOADOUT_ABILITY_INVALID]]
];





// Fetch and return the corresponding path
switch (_ability) do {
	case MACRO_ENUM_LOADOUT_ABILITY_REPAIR:				{"res\images\abilities\ability_repairkit.paa"};
	case MACRO_ENUM_LOADOUT_ABILITY_HEAL:				{"res\images\abilities\ability_medikit.paa"};
	case MACRO_ENUM_LOADOUT_ABILITY_RESUPPLY:			{"res\images\abilities\ability_ammokit.paa"};

	case MACRO_ENUM_LOADOUT_ABILITY_BINOCULAR:			{"res\images\abilities\ability_binocular.paa"};
	case MACRO_ENUM_LOADOUT_ABILITY_NVGS:				{"res\images\abilities\ability_nvgs.paa"};
	case MACRO_ENUM_LOADOUT_ABILITY_MINEDETECTOR:			{"res\images\abilities\ability_minedetector.paa"};
	case MACRO_ENUM_LOADOUT_ABILITY_ANTITANK:			{"res\images\abilities\ability_antitank.paa"};
	case MACRO_ENUM_LOADOUT_ABILITY_HANDGRENADE_FRAG:		{"res\images\abilities\ability_handgrenade_frag.paa"};
	case MACRO_ENUM_LOADOUT_ABILITY_HANDGRENADE_SMOKE:		{"res\images\abilities\ability_handgrenade_smoke.paa"};
	case MACRO_ENUM_LOADOUT_ABILITY_GRENADELAUNCHER:		{"res\images\abilities\ability_grenadelauncher.paa"};
	case MACRO_ENUM_LOADOUT_ABILITY_EXPLOSIVES:			{"res\images\abilities\ability_explosives.paa"};
	case MACRO_ENUM_LOADOUT_ABILITY_MINE_AP:			{"res\images\abilities\ability_mine_ap.paa"};
	case MACRO_ENUM_LOADOUT_ABILITY_MINE_AT:			{"res\images\abilities\ability_mine_at.paa"};

	default								{""};
};
