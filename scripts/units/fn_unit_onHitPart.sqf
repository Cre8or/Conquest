/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[GA][LE]
		Called whenever a local unit's "HitPart" EH is executed.
		Handles local hit detection (for hit markers) to the given unit.
	Arguments:
		(see https://community.bistudio.com/wiki/Arma_3:_Event_Handlers#HitPart)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"





// Set up some variables
private _player = player;
private _target = _this param [0, []] param [0, objNull]; // First entry

if (
	GVAR(ui_sys_drawHitMarkers_trigger)
	or {_player == _target}
	or {GVAR(side) == _target getVariable [QGVAR(side), sideEmpty]}
	or {!([_target] call FUNC(unit_isAlive))}
) exitWith {};





scopename QGVAR(unit_onHitPart);

{
	_x params ["_target", "", "_projectile", "_position", "", "_selection", "_ammo", "", "", "", "_isDirect"];
	(getShotParents _projectile) params ["", "_instigator"];

	// Consume the first valid hit and exit
	if (_isDirect and {_instigator == _player}) then {
		_selection = _selection param [0, ""];
		private _offset = _target worldToModelVisual ASLtoATL _position;

		if (_selection != "") then {
			_offset = (_target selectionPosition _selection) vectorDiff _offset;
		};

		GVAR(ui_sys_drawHitMarkers_trigger) = true;
		GVAR(ui_sys_drawHitMarkers_data) pushBack [
			time + MACRO_UI_HITMARKERS_DURATION,
			_target,
			_selection,
			_offset
		];

		breakTo QGVAR(unit_onHitPart);
	};
} forEach _this;
