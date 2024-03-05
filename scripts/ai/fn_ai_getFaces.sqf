/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Returns an array of faces that correspond to the given category (or array of categories).
		Used by fnc_ai_generateIdentities to set up AI identities.
	Arguments:
		0:	<STRING>	The face category
				OR
			<ARRAY>		An array of face categories
	Returns:
			<ARRAY>		An array of matching faces
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_category", "", ["", []]]
];





// Set up some variables
private _result = [];
private _faces = [];
private _categories = [_category, [_category]] select (_category isEqualType ""); // If the passed argument is a string, toss it into an array - otherwise, keep it





// Iterate over all provided categories
{
	_faces = switch (toLower _x) do {
		case "african":		{["AfricanHead_01", "AfricanHead_02", "AfricanHead_03", "Barklem"]};
		case "african_camo":	{["CamoHead_African_01_F", "CamoHead_African_02_F", "CamoHead_African_03_F"]};
		case "asian":		{["AsianHead_A3_01", "AsianHead_A3_02", "AsianHead_A3_03", "AsianHead_A3_04", "AsianHead_A3_05", "AsianHead_A3_06", "AsianHead_A3_07"]};
		case "asian_camo":	{["CamoHead_Asian_01_F", "CamoHead_Asian_02_F", "CamoHead_Asian_03_F"]};
		case "greek":		{["GreekHead_A3_01", "GreekHead_A3_02", "GreekHead_A3_03", "GreekHead_A3_04", "GreekHead_A3_05", "GreekHead_A3_06", "GreekHead_A3_07", "GreekHead_A3_08", "GreekHead_A3_09", "GreekHead_A3_11", "GreekHead_A3_12", "GreekHead_A3_13", "GreekHead_A3_14", "Mavros", "IG_Leader", "Ioannou", "Nikos"]};
		case "greek_camo":	{["CamoHead_Greek_01_F", "CamoHead_Greek_02_F", "CamoHead_Greek_03_F", "CamoHead_Greek_04_F", "CamoHead_Greek_05_F", "CamoHead_Greek_01_F", "CamoHead_Greek_06_F", "CamoHead_Greek_07_F", "CamoHead_Greek_08_F", "CamoHead_Greek_09_F", "GreekHead_A3_10_a", "GreekHead_A3_10_l", "GreekHead_A3_10_sa"]};
		case "livonian":	{["LivonianHead_1", "LivonianHead_2", "LivonianHead_3", "LivonianHead_4", "LivonianHead_5", "LivonianHead_6", "LivonianHead_7", "LivonianHead_8", "LivonianHead_9", "LivonianHead_10"]};
		case "persian":		{["PersianHead_A3_01", "PersianHead_A3_02", "PersianHead_A3_03"]};
		case "persian_camo":	{["CamoHead_Persian_01_F", "CamoHead_Persian_02_F", "CamoHead_Persian_03_F", "PersianHead_A3_04_a", "PersianHead_A3_04_l", "PersianHead_A3_04_sa"]};
		case "russian":		{["RussianHead_1", "RussianHead_2", "RussianHead_3", "RussianHead_4", "RussianHead_5"]};
		case "tanoan":		{["TanoanHead_A3_01", "TanoanHead_A3_02", "TanoanHead_A3_03", "TanoanHead_A3_04", "TanoanHead_A3_05", "TanoanHead_A3_06", "TanoanHead_A3_07", "TanoanHead_A3_08", "TanoanBossHead"]};
		case "white":		{["WhiteHead_01", "WhiteHead_02", "WhiteHead_03", "WhiteHead_04", "WhiteHead_05", "WhiteHead_06", "WhiteHead_07", "WhiteHead_08", "WhiteHead_09", "WhiteHead_10", "WhiteHead_11", "WhiteHead_12", "WhiteHead_13", "WhiteHead_14", "WhiteHead_15", "WhiteHead_16", "WhiteHead_17", "WhiteHead_18", "WhiteHead_19", "WhiteHead_20", "WhiteHead_21", "WhiteHead_23", "WhiteHead_24", "WhiteHead_25", "WhiteHead_26", "WhiteHead_27", "WhiteHead_28", "WhiteHead_29", "WhiteHead_30", "WhiteHead_31", "WhiteHead_32", "Kerry_A_F", "Kerry_B2_F", "Miller", "Sturrock"]};
		case "white_camo":	{["CamoHead_White_01_F", "CamoHead_White_02_F", "CamoHead_White_03_F", "CamoHead_White_04_F", "CamoHead_White_05_F", "CamoHead_White_06_F", "CamoHead_White_07_F", "CamoHead_White_08_F", "CamoHead_White_09_F", "CamoHead_White_10_F", "CamoHead_White_11_F", "CamoHead_White_12_F", "CamoHead_White_13_F", "CamoHead_White_14_F", "CamoHead_White_15_F", "CamoHead_White_16_F", "CamoHead_White_17_F", "CamoHead_White_18_F", "CamoHead_White_19_F", "CamoHead_White_20_F", "CamoHead_White_21_F", "WhiteHead_22_a", "WhiteHead_22_l", "WhiteHead_22_sa"]};
		default			{[]};
	};

	// If any faces were found, add them to the result
	if !(_faces isEqualTo []) then {
		_result = _result + _faces;
	};
} forEach _categories;

// Return the result
_result;
