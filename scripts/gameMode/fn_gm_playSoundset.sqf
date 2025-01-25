/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LE]
		Plays a predefined soundset on the local machine. Some soundsets include multiple individual sounds or even
		music.
		For a list of possible message enums, see macros.inc.
	Arguments:
		0:      <NUMBER>	The sound event enum to be played
		1:      <BOOLEAN>	Whether the sound should be forced to play
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_enum", MACRO_ENUM_SOUNDSET_INVALID, [MACRO_ENUM_SOUNDSET_INVALID]]
];





switch (_enum) do {

	case MACRO_ENUM_SOUNDSET_TICKETSLOW_WIN;
	case MACRO_ENUM_SOUNDSET_TICKETSLOW_LOSE: {
		playSound [QGVAR(TicketsLow_Siren), 0];

		0 fadeMusic 1;
		playMusic "LeadTrack03a_F_EPA";
	};

	case MACRO_ENUM_SOUNDSET_SIDEDEFEATED_WIN: {
		0 fadeMusic 1;
		playMusic QGVAR(SideDefeated);
	};

	case MACRO_ENUM_SOUNDSET_SIDEDEFEATED_LOSE: {
		0 fadeMusic 0;
		playMusic ["AmbientTrack02_F_Orange", 20];
		5 fadeMusic 1;

/*
		0 fadeMusic 0;
		playMusic "EventTrack02b_F_EPC";
		2 fadeMusic 1;
*/

		// EventTrack01_F_EPB
		// EventTrack02b_F_EPC
		// EventTrack04_F_EPB
		// AmbientTrack02_F_Orange
	};



	case MACRO_ENUM_SOUNDSET_ENDING_VICTORY: {
		0 fadeMusic 0;
		playMusic ["LeadTrack01_F_Jets", 117];
		1 fadeMusic 1;
	};

	case MACRO_ENUM_SOUNDSET_ENDING_VICTORY_DECISIVE: {
		0 fadeMusic 0;
		playMusic ["LeadTrack01_F_Mark", 137];
		1 fadeMusic 1;
	};

	case MACRO_ENUM_SOUNDSET_ENDING_DEFEAT: {
		0 fadeMusic 0;
		playMusic ["Leadtrack06_F_Tank", 0];
		1 fadeMusic 1;
	};

	case MACRO_ENUM_SOUNDSET_ENDING_DEFEAT_DECISIVE: {
		0 fadeMusic 0;
		playMusic ["EventTrack01_F_EPC", 19.6];
		1 fadeMusic 1;
	};



	default {
		private _str = format ["[CONQUEST] (gm_playSoundSet) ERROR: Invalid enum provided! (%1)", _enum];
		systemChat _str;
		diag_log _str;
	};
};
