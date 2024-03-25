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
	case MACRO_ENUM_LOADOUT_ABILITY_RESUPPLY:          {getMissionPath "res\images\abilities\ability_resupply.paa"};
	case MACRO_ENUM_LOADOUT_ABILITY_REPAIR:            {getMissionPath "res\images\abilities\ability_repair.paa"};
	case MACRO_ENUM_LOADOUT_ABILITY_HEAL:              {getMissionPath "res\images\abilities\ability_heal.paa"};

	case MACRO_ENUM_LOADOUT_ABILITY_BINOCULAR:         {getMissionPath "res\images\abilities\ability_binocular.paa"};
	case MACRO_ENUM_LOADOUT_ABILITY_NVGS:              {getMissionPath "res\images\abilities\ability_nvgs.paa"};
	case MACRO_ENUM_LOADOUT_ABILITY_MINEDETECTOR:      {getMissionPath "res\images\abilities\ability_minedetector.paa"};
	case MACRO_ENUM_LOADOUT_ABILITY_ANTITANK:          {getMissionPath "res\images\abilities\ability_antitank.paa"};
	case MACRO_ENUM_LOADOUT_ABILITY_HANDGRENADE_FRAG:  {getMissionPath "res\images\abilities\ability_handgrenade_frag.paa"};
	case MACRO_ENUM_LOADOUT_ABILITY_HANDGRENADE_SMOKE: {getMissionPath "res\images\abilities\ability_handgrenade_smoke.paa"};
	case MACRO_ENUM_LOADOUT_ABILITY_GRENADELAUNCHER:   {getMissionPath "res\images\abilities\ability_grenadelauncher.paa"};
	case MACRO_ENUM_LOADOUT_ABILITY_EXPLOSIVES:        {getMissionPath "res\images\abilities\ability_explosives.paa"};
	case MACRO_ENUM_LOADOUT_ABILITY_MINE_AP:           {getMissionPath "res\images\abilities\ability_mine_ap.paa"};
	case MACRO_ENUM_LOADOUT_ABILITY_MINE_AT:           {getMissionPath "res\images\abilities\ability_mine_at.paa"};

	default                                            {""};
};
