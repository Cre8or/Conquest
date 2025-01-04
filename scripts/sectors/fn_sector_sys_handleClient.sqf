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





MACRO_FNC_INITVAR(GVAR(sector_sys_handleClient_EH), -1);
GVAR(sector_sys_handleClient_prevSide) = sideEmpty;





removeMissionEventHandler ["EachFrame", GVAR(sector_sys_handleClient_EH)];
GVAR(sector_sys_handleClient_EH) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	private _time = time;
	private _playerChangedSides = (GVAR(sector_sys_handleClient_prevSide) != GVAR(side));
	private ["_sector", "_side", "_prevSide", "_level", "_prevLevel", "_flag", "_levelChanged", "_colour", "_marker", "_refTime", "_refLevel", "_phase", "_levelSmooth"];

	{
		_sector    = _x;
		_side      = _sector getVariable [QGVAR(side), sideEmpty];
		_prevSide  = _sector getVariable [QGVAR(cl_prevSide), sideEmpty];
		_level     = _sector getVariable [QGVAR(level), 1];
		_prevLevel = _sector getVariable [QGVAR(cl_prevLevel), -1];
		_flag      = _sector getVariable [QGVAR(flagPole), objNull];
		private _levelChanged  = (_level != _prevLevel);

		if (_side != _prevSide or {_playerChangedSides}) then {
			_colour = switch _side do {
				case GVAR(side): {"colorBlue"};
				case sideEmpty:  {"colorWhite"};
				default          {"colorRed"};
			};

			// Update the sector's marker colours
			{
				_marker = _sector getVariable [_x, ""];
				_marker setMarkerColorLocal _colour;
			} forEach [
				QGVAR(markerArea),
				QGVAR(markerAreaOutline)
			];

			_sector setVariable [QGVAR(cl_prevSide), _side, false];
			_levelChanged = true;
		};

		// Keep track of the time when the level has last changed (set by handleServer)
		if (_levelChanged) then {

			// When reaching either 0% or 100% level, skip the animation entirely, as the flag texture is alread set
			if (_level >= 1 or {_level <= 0}) then {
				_sector setVariable [QGVAR(cl_flagAnim_time), -1, false];
			} else {
				_sector setVariable [QGVAR(cl_flagAnim_time), _time, false];
			};

			_sector setVariable [QGVAR(cl_flagAnim_level), _prevLevel, false];
			_sector setVariable [QGVAR(cl_prevLevel), _level, false];
		};

		// Update the flag's animation phase
		_refTime     = _sector getVariable [QGVAR(cl_flagAnim_time), -1];
		_refLevel    = _sector getVariable [QGVAR(cl_flagAnim_level), -1];
		_phase       = ((_time - _refTime) / MACRO_SECTOR_TRIGGERINTERVAL) min 1;
		_levelSmooth = _refLevel + _phase * (_level - _refLevel);

		_flag setFlagAnimationPhase _levelSmooth;


	} forEach GVAR(allSectors);

	GVAR(sector_sys_handleClient_prevSide) = GVAR(side);
}];
