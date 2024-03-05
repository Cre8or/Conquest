/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Returns an array of voices that correspond to the given category (or array of categories).
		Used by fnc_ai_generateIdentities to set up AI identities.
	Arguments:
		0:	<STRING>	The voices category
				OR
			<ARRAY>		An array of voice categories
	Returns:
			<ARRAY>		An array of matching speaker voices
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_category", "", ["", []]]
];





// Set up some variables
private _result = [];
private _voices = [];
private _categories = [_category, [_category]] select (_category isEqualType ""); // If the passed argument is a string, toss it into an array - otherwise, keep it





// Iterate over all provided categories
{
	_voices = switch (toLower _x) do {
		case "chinese":		{["Male01CHI", "Male02CHI", "Male03CHI"]};
		case "english_fr":	{["Male01ENGFRE", "Male02ENGFRE"]};
		case "english_gr":	{["Male01GRE", "Male02GRE", "Male03GRE", "Male04GRE", "Male05GRE", "Male06GRE"]};
		case "english_uk":	{["Male01ENGB", "Male02ENGB", "Male03ENGB", "Male04ENGB", "Male05ENGB"]};
		case "english_us":	{["Male01ENG", "Male02ENG", "Male03ENG", "Male04ENG", "Male05ENG", "Male06ENG", "Male07ENG", "Male08ENG", "Male09ENG", "Male10ENG", "Male11ENG", "Male12ENG"]};
		case "farsi":		{["Male01PER", "Male02PER", "Male03PER"]};
		case "french":		{["Male01FRE", "Male02FRE", "Male03FRE"]};
		case "polish":		{["Male01POL", "Male02POL", "Male03POL"]};
		case "russian":		{["Male01RUS", "Male02RUS", "Male03RUS"]};
		default			{[]};
	};

	// If any voices were found, add them to the result
	if !(_voices isEqualTo []) then {
		_result = _result + _voices;
	};
} forEach _categories;

// Return the result
_result;
