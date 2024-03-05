/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Plays a predefined radio message on the local machine. If a message with a higher priority is already
		playing, it will only be interrupted if the requested message has a higher priority, or if is forced
		to play (see arguments).
		For a list of possible message enums, see macros.inc.
	Arguments:
		0:      <NUMBER>	The radio message enum to be played
		1:      <BOOLEAN>	Whether the sound should be forced to play
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

// Fetch our params
params [
	["_messageEnum", MACRO_ENUM_RADIOMSG_INVALID, [MACRO_ENUM_RADIOMSG_INVALID]],
	["_forced", false, [false]]
];




// Set up some variables
MACRO_FNC_INITVAR(GVAR(radioMsg_dummy),objNull);
MACRO_FNC_INITVAR(GVAR(radioMsg_curMessage),MACRO_ENUM_RADIOMSG_INVALID);





// Fetch the corresponding sound file
private _sound = switch (_messageEnum) do {

	case MACRO_ENUM_RADIOMSG_ROUNDSTART: {
		QGVAR(RoundStart)
	};



	case MACRO_ENUM_RADIOMSG_LEAVINGCOMBATAREA: {
		QGVAR(LeavingCombatArea)
	};



	case MACRO_ENUM_RADIOMSG_SECTORCAPTURING_1: {
		QGVAR(SectorCapturing_1)
	};
	case MACRO_ENUM_RADIOMSG_SECTORCAPTURING_2: {
		QGVAR(SectorCapturing_2)
	};
	case MACRO_ENUM_RADIOMSG_SECTORCAPTURING_3: {
		QGVAR(SectorCapturing_3)
	};



	case MACRO_ENUM_RADIOMSG_SECTORCAPTURED_1: {
		QGVAR(SectorCaptured_1)
	};
	case MACRO_ENUM_RADIOMSG_SECTORCAPTURED_2: {
		QGVAR(SectorCaptured_2)
	};
	case MACRO_ENUM_RADIOMSG_SECTORCAPTURED_3: {
		QGVAR(SectorCaptured_3)
	};



	case MACRO_ENUM_RADIOMSG_SECTORLOSING_1: {
		QGVAR(SectorLosing_1)
	};
	case MACRO_ENUM_RADIOMSG_SECTORLOSING_2: {
		QGVAR(SectorLosing_2)
	};
	case MACRO_ENUM_RADIOMSG_SECTORLOSING_3: {
		QGVAR(SectorLosing_3)
	};



	case MACRO_ENUM_RADIOMSG_SECTORLOST_1: {
		QGVAR(SectorLost_1)
	};
	case MACRO_ENUM_RADIOMSG_SECTORLOST_2: {
		QGVAR(SectorLost_2)
	};



	case MACRO_ENUM_RADIOMSG_TICKETSLOW_WIN: {
		QGVAR(TicketsLow_Win)
	};

	case MACRO_ENUM_RADIOMSG_TICKETSLOW_LOSE: {
		QGVAR(TicketsLow_Lose)
	};



	case MACRO_ENUM_RADIOMSG_SIDEDEFEATED_WIN: {
		QGVAR(SideDefeated_Win)
	};

	case MACRO_ENUM_RADIOMSG_SIDEDEFEATED_LOSE: {
		QGVAR(SideDefeated_Lose)
	};



	default {""};
};

/*
"D:\Steam\SteamApps\common\ArmA 2 Mods\P Drive\a3\dubbing_f_epc\C_m01\03_Stage_1\c_m01_03_stage_1_BHQ_0.ogg"
"D:\Steam\SteamApps\common\ArmA 2 Mods\P Drive\a3\dubbing_f_gamma\showcase_armed_assault\15_UAVOnline\showcase_armed_assault_15_uavonline_BHQ_0.ogg"
"D:\Steam\SteamApps\common\ArmA 2 Mods\P Drive\a3\dubbing_f_gamma\showcase_armed_assault\15_UAVOnline\showcase_armed_assault_17_uavdestroyed_BHQ_0.ogg"
"D:\Steam\steamapps\common\Arma 2 Mods\P Drive\a3\dubbing_f_tank\ta_showcase_tank_destroyers\032_ex_leaving_ao\ta_showcase_tank_destroyers_032_ex_leaving_ao_TDHQ_1.ogg"
*/





// Play the sound
if (_sound != "" and {_forced or {isNull GVAR(radioMsg_dummy)} or {GVAR(radioMsg_curMessage) < _messageEnum}}) then {
	deleteVehicle GVAR(radioMsg_dummy);

	GVAR(radioMsg_dummy) = playSound [_sound, 2];
	GVAR(radioMsg_curMessage) = _messageEnum;
};
