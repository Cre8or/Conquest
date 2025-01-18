/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Returns the localised description associated with the given ability enumeration.
	Arguments:
		0:	<NUMBER>	The ability enumeration
	Returns:
			<STRING>	The description associated with the ability
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_ability", MACRO_ENUM_LOADOUT_ABILITY_INVALID, [MACRO_ENUM_LOADOUT_ABILITY_INVALID]]
];





// Fetch and return the corresponding localised description
switch (_ability) do {
	case MACRO_ENUM_LOADOUT_ABILITY_RESUPPLY:          {LSTRING(ability_resupply) call BIS_fnc_localize};
	case MACRO_ENUM_LOADOUT_ABILITY_REPAIR:            {LSTRING(ability_repair) call BIS_fnc_localize};
	case MACRO_ENUM_LOADOUT_ABILITY_HEAL:              {LSTRING(ability_heal) call BIS_fnc_localize};

	case MACRO_ENUM_LOADOUT_ABILITY_BINOCULAR:         {LSTRING(ability_binocular) call BIS_fnc_localize};
	case MACRO_ENUM_LOADOUT_ABILITY_NVGS:              {LSTRING(ability_nvgs) call BIS_fnc_localize};
	case MACRO_ENUM_LOADOUT_ABILITY_MINEDETECTOR:      {LSTRING(ability_minedetector) call BIS_fnc_localize};
	case MACRO_ENUM_LOADOUT_ABILITY_ANTITANK:          {LSTRING(ability_antitank) call BIS_fnc_localize};
	case MACRO_ENUM_LOADOUT_ABILITY_HANDGRENADE_FRAG:  {LSTRING(ability_handgrenade_frag) call BIS_fnc_localize};
	case MACRO_ENUM_LOADOUT_ABILITY_HANDGRENADE_SMOKE: {LSTRING(ability_handgrenade_smoke) call BIS_fnc_localize};
	case MACRO_ENUM_LOADOUT_ABILITY_GRENADELAUNCHER:   {LSTRING(ability_grenadelauncher) call BIS_fnc_localize};
	case MACRO_ENUM_LOADOUT_ABILITY_EXPLOSIVES:        {LSTRING(ability_explosives) call BIS_fnc_localize};
	case MACRO_ENUM_LOADOUT_ABILITY_MINE_AP:           {LSTRING(ability_mine_ap) call BIS_fnc_localize};
	case MACRO_ENUM_LOADOUT_ABILITY_MINE_AT:           {LSTRING(ability_mine_at) call BIS_fnc_localize};

	default                                            {"Unknown ability"};
};
