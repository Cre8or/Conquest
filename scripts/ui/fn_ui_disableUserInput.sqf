/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LE]
		Disables user input by holding an empty GUI open. Works similarily to ACE3's UI handler.
		Also used to re-enable input after they have been disabled (see the arguments below).

		For a list of source enumerations, see macros.hpp.
	Arguments:
		0:	<NUMBER>	The enum of the source that disabled the input
		1:	<BOOLEAN>	Whether or not user inputs should be disabled (default: true)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "\a3\ui_f\hpp\defineDIKCodes.inc"

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

params [
	["_source", MACRO_ENUM_INPUTLOCK_UNKNOWN, [MACRO_ENUM_INPUTLOCK_UNKNOWN]],
	["_active", true, [true]]
];

if (!hasInterface or {_source == MACRO_ENUM_INPUTLOCK_UNKNOWN}) exitWith {};





// Set up some variables
MACRO_FNC_INITVAR(GVAR(ui_disableUserInput_EH), -1);
MACRO_FNC_INITVAR(GVAR(ui_disableUserInput_sources), createHashMap);

private _disabled = _active;





// Manage the sources
if (_active) then {
	GVAR(ui_disableUserInput_sources) set [_source, true];

} else {
	if (_source in GVAR(ui_disableUserInput_sources)) then {
		GVAR(ui_disableUserInput_sources) deleteAt _source;
	};

	_disabled = (count GVAR(ui_disableUserInput_sources) > 0);
};





removeMissionEventHandler ["EachFrame", GVAR(ui_disableUserInput_EH)];

if (_disabled) then {

	// Disable user input
	GVAR(ui_disableUserInput_EH) = addMissionEventHandler ["EachFrame", {

		if (isGamePaused) exitWith {};

		private _UI = uiNamespace getVariable [QGVAR(RscUserInputBlocker), displayNull];

		if (isNull _UI and {time > 0} and {!dialog} and {!visibleMap}) then {

			_UI = createDialog [QGVAR(RscUserInputBlocker), false];

			// Register CBA's event handlers on the dialog display
			[_UI] call FUNC(cba_initDisplay);

			// Allow specific keys to pass through
			_UI displayAddEventHandler ["KeyDown", {

				params ["_UI", "_key", "_shift", "_ctrl", "_alt"];
				private _consumed = false;

				// Process keys
				if (_key == DIK_ESCAPE) then {
					["ui_close", true] call FUNC(ui_scoreBoard);

					// Don't open the escape menu as dialog, or the buttons won't work! Instead, open as display.
					private _displayClass   = (["RscDisplayInterrupt", "RscDisplayMPInterrupt"] select isMultiplayer);
					private _dialogMainMenu = (findDisplay 46) createDisplay _displayClass;

					_consumed = true;
				};

				// Time acceleration (SP only)
				if (!isMultiplayer) then {
					if (_key in actionKeys "timeInc") then {
						setAccTime (accTime * 2 min 4);
						_consumed = true;
					};

					if (_key in actionKeys "timeDec") then {
						setAccTime (accTime / 2 max 1);
						_consumed = true;
					};
				};

				// Map
				if (_key in actionKeys "showMap") then {
					_UI closeDisplay 0;
					openMap true;
					_consumed = true;
				};

				_consumed;
			}];
		};
	}];

} else {
	private _UI = uiNamespace getVariable [QGVAR(RscUserInputBlocker), displayNull];

	if (!isNull _UI) then {
		_UI closeDisplay 0;
	};
};
