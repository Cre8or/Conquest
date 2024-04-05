/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Returns the fillbar icon corresponding to the provided fill value (in range 0 .. 1).
	Arguments:
		0:	<NUMBER>	The fill value (range 0 .. 1)
	Returns:
			<STRING>	The corresponding fillbar icon path
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_fill", 0, [0]]
];





private _index = floor ((_fill * 10 max 0) min 10);

getMissionPath format ["res\images\3d\fill_%1.paa", _index];
