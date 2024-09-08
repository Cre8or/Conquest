/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Hooks into the UnitInfo display in order to unhide the ammo count control.

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
MACRO_FNC_INITVAR(GVAR(ui_hookUnitInfoCtrls_EH), -1);





["ace_infoDisplayChanged", GVAR(ui_hookUnitInfoCtrls_EH)] call CBA_fnc_removeEventHandler;

GVAR(ui_hookUnitInfoCtrls_EH) = ["ace_infoDisplayChanged", {
	private _displays = ((uiNamespace getVariable "IGUI_displays") + [findDisplay 46]) select {ctrlIDD _x == 300}; // RscUnitInfo

    // Loop through IGUI displays as they can be present several times for some reason
	{
        private _control = _x displayCtrl 184; // CA_AmmoCount

		// Unhide the ammo count
        _control ctrlSetFade 0;
        _control ctrlCommit 0;
    } forEach _displays;

}] call CBA_fnc_addEventHandler;
