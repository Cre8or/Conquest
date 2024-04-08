/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LE]
		Overrides the map scale of the GPS-type info panels to no longer be velocity-dependant.

		Called internally via the control's "Draw" EH.
	Arguments:
		0:	<CONTROL>	The map control to scale
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

// No parameter validation, as this is an internal function
params ["_ctrlMap"];





private _player    = player;
private _inVehicle = (_player != vehicle _player);

_ctrlMap ctrlMapAnimAdd [0, [MACRO_UI_GPS_SCALE_INF, MACRO_UI_GPS_SCALE_VEH] select _inVehicle, getPosWorld _player];
ctrlMapAnimCommit _ctrlMap;
