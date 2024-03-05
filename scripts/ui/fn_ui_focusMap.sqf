/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LE]
		Focuses the given map control on the mission's playable area. This includes all sectors, aswell as the
		combat area.
	Arguments:
		0:	<CONTROL>	The map control to be focused
		1:	<NUMBER>	The amount of padding, as percentage of the area (0 .. 1) (optional,
					default: 0)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_ctrlMap", controlNull, [controlNull]],
	["_padding", 0, [0]]
];

if (isNull _ctrlMap) exitWith {};




_ctrlMap setVariable [QGVAR(ui_focusMap_padding), _padding];

// Ensure the map is open before focusing
_ctrlMap ctrlRemoveEventHandler ["Draw", _ctrlMap getVariable [QGVAR(EH_focusMap), -1]];
_ctrlMap setVariable [QGVAR(EH_focusMap), _ctrlMap ctrlAddEventHandler ["Draw", {

	params ["_ctrlMap"];

	private _padding = _ctrlMap getVariable [QGVAR(ui_focusMap_padding), 0];
	private "_flagPole";

	// Calculate the bounding box of the map's sectors and combat area
	private _allPositions = (
		(GVAR(allSectors) apply {
			_flagPole = _x getVariable [QGVAR(flagPole), objNull];

			if (isNull _flagPole) then {
				getPosWorld _x;
			} else {
				getPosWorld _flagPole;
			}
		}) + (
			missionNamespace getVariable [format [QGVAR(CA_%1), GVAR(side)], []]
		)
	);
	([_allPositions] call FUNC(math_boundingBox2D)) params ["_posBL", "_posTR"];

	// Center the map
	[
		_ctrlMap,
		_posBL,
		_posTR,
		_padding
	] call FUNC(ui_focusMapOnArea);

	// Remove the event handler
	_ctrlMap ctrlRemoveEventHandler ["Draw", _ctrlMap getVariable [QGVAR(EH_focusMap), -1]];
}]];
