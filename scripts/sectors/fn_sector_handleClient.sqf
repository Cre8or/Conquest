/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Continuously upates all sector flags and map markers. Also handles the sector HUD.

		Only executed once upon client init.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

if (!hasInterface) exitWith {};





MACRO_FNC_INITVAR(GVAR(EH_sector_handleClient_eachFrame),-1);





removeMissionEventHandler ["EachFrame", GVAR(EH_sector_handleClient_eachFrame)];
GVAR(EH_sector_handleClient_eachFrame) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	private _playerChangedSides = (GVAR(UI_prevPlayerSide) != GVAR(side));
	private ["_sector", "_side", "_sideLast", "_colour", "_marker"];

	{
		_sector   = _x;
		_side     = _sector getVariable [QGVAR(side), sideEmpty];
		_sideLast = _sector getVariable [QGVAR(sideLast), sideEmpty];

		if (_side != _sideLast or {_playerChangedSides}) then {

			_colour = switch _side do {
				case GVAR(side): 	{"colorBlue"};
				case sideEmpty:		{"colorWhite"};
				default			{"colorRed"};
			};

			// Update the sector's marker colours
			{
				_marker = _sector getVariable [_x, ""];
				_marker setMarkerColorLocal _colour;
			} forEach [
				QGVAR(markerArea),
				QGVAR(markerAreaOutline)
			];

			_sector setVariable [QGVAR(sideLast), _side, false];
		};

	} forEach GVAR(allSectors);

	GVAR(UI_prevPlayerSide) = GVAR(side);
}];
