// Typing a character
case "ui_char_entered": {
	_eventExists = true;

	#include "..\..\..\..\res\macros\cond_isValidGroup.inc"

	// Fetch the parameters
	_args params ["", "_char"];




	// Check if we are awaiting any characters (currently only for the custom group callsign)
	if (_spawnMenu getVariable [QGVAR(menuRole_isNamingGroup), false]) then {
		private _buffer = _spawnMenu getVariable [QGVAR(menuRole_textBuffer), ""];

		// Check the length of the group name
		if (count _buffer < MACRO_UI_CALLSIGN_MAXIMUM_LENGTH) then {

			// Append the character to the buffer
			_spawnMenu setVariable [QGVAR(menuRole_textBuffer), _buffer + toString [_char]];

			// Remove the group name error (if it was on)
			_spawnMenu setVariable [QGVAR(menuRole_hasNameCollision), false];

			// Update the role UI
			["ui_update_role"] call FUNC(ui_spawnMenu);
		};
	};
};
