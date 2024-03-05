/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA][LE]
		Sets up the identity of a unit with the provided name, face and speaker.
	Arguments:
		0:	<OBJECT>	The unit whose identity should be set
		1:	<STRING>	The unit's new name
		2:	<STRING>	The new face class
		3:	<STRING>	The new speaker class
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

// Fetch our params
params [
	["_unit", objNull, [objNull]],
	["_name", "", [""]],
	["_face", "", [""]],
	["_speaker", "", [""]]
];





if (_name != "") then {
	_unit setName _name;
};
if (_face != "") then {
	_unit setFace _face;
};
if (_speaker != "") then {
	_unit setSpeaker _speaker;
};
