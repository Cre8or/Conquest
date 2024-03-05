/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Draws 3D hit marker icons on the screen. Hits are added to the data array via unit_onHitPart.

		Only executed once by the client upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

if (!hasInterface) exitWith {};





// Set up some variables
MACRO_FNC_INITVAR(GVAR(ui_sys_drawHitMarkers_EH), -1);

GVAR(ui_sys_drawHitMarkers_trigger) = false;
GVAR(ui_sys_drawHitMarkers_data)    = [];





removeMissionEventHandler ["Draw3D", GVAR(ui_sys_drawHitMarkers_EH)];
GVAR(ui_sys_drawHitMarkers_EH) = addMissionEventHandler ["Draw3D", {

	if (isGamePaused) exitWith {};

	// Detect and reset the trigger
	if (GVAR(ui_sys_drawHitMarkers_trigger)) then {
		GVAR(ui_sys_drawHitMarkers_trigger) = false;

		// Play a sound
		playSound QGVAR(HitMarker);
	};

	private _time = time;
	private ["_phase", "_phaseSqr", "_pos"];

	// Draw the hit markers
	for "_index" from count GVAR(ui_sys_drawHitMarkers_data) - 1 to 0 step -1 do {

		(GVAR(ui_sys_drawHitMarkers_data) # _index) params ["_endTime", "_obj", "_selection", "_offset"];

		if (_endTime < _time) then {
			GVAR(ui_sys_drawHitMarkers_data) deleteAt _index;

		} else {
			_phase    = (_endTime - _time) / MACRO_UI_HITMARKERS_DURATION;
			_phaseSqr = _phase ^ 2;

			if (isNull _obj) then {
				_pos = ASLtoATL _offset;
			} else {
				if (_selection != "") then {
					_offset = (_obj selectionPosition _selection) vectorDiff _offset;
				};

				_pos = _obj modelToWorldVisual _offset
			};

			drawIcon3D [
				"a3\ui_f\data\IGUI\Cfg\Cursors\iconCursorSupport_ca.paa",
				[1,1,1, ((_phase * 1.25) ^ 2) min 1],
				_pos,
				_phaseSqr * 2,
				_phaseSqr * 2,
				0
			];
		};
	};
}];
