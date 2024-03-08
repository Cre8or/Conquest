/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Prevent the use of third person view while the camera is not attached to the player (e.g. panorama
		camera). This is simply to prevent quirky interface with the scripted camera scenes, and does not
		prevent third person view in vehicles/on foot.

		Only executed once by the client upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

#include "..\..\res\macros\fnc_initVar.inc"

if (!hasInterface) exitWith {};





// Set up some variales
MACRO_FNC_INITVAR(GVAR(EH_sys_enforceFPVInCamera_eachFrame),-1);





removeMissionEventHandler ["EachFrame", GVAR(EH_sys_enforceFPVInCamera_eachFrame)];
GVAR(EH_sys_enforceFPVInCamera_eachFrame) = addMissionEventHandler ["EachFrame", {

	if (isGamePaused) exitWith {};

	private _cam = cameraOn;

	if (typeOf _cam == "camera") then {
		_cam switchCamera "Internal";
	};
}];
