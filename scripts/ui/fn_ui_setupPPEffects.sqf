/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LE]
		Creates various post process effects that are shared among different scripts, and stores their handles
		into GVARs for later use.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"





// Set up some functions
private _fnc_setupPPEffect = {
	params ["_ppEffectType", "_index"];
	private _ppEffect = -1;

	// Search for a free ID
	while {
		_ppEffect = ppEffectCreate [_ppEffectType, _index];
		_ppEffect < 0
	} do {
		_index = _index + 1;
	};

	//systemChat format ["Created %1 with priority %2, handle %3", _ppEffectType, _index, _ppEffect];
	_ppEffect ppEffectEnable true;
	_ppEffect ppEffectForceInNVG true;

	// Return the effect handler
	_ppEffect;
};





// Remove the old post-process effects (if they exist)
if (!isNil QGVAR(ui_sm_blurFx))           then {ppEffectDestroy GVAR(ui_sm_blurFx)};
if (!isNil QGVAR(ui_ca_colourFx))         then {ppEffectDestroy GVAR(ui_ca_colourFx)};
if (!isNil QGVAR(ui_med_colourFx_hurt))   then {ppEffectDestroy GVAR(ui_med_colourFx_hurt)};
if (!isNil QGVAR(ui_med_colourFx_health)) then {ppEffectDestroy GVAR(ui_med_colourFx_health)};
if (!isNil QGVAR(ui_med_blurFx))          then {ppEffectDestroy GVAR(ui_med_blurFx)};

// Set up the new post-process effects
GVAR(ui_sm_blurFx)           = ["DynamicBlur", 400] call _fnc_setupPPEffect;
GVAR(ui_ca_colourFx)         = ["ColorCorrections", 8000] call _fnc_setupPPEffect;
GVAR(ui_med_colourFx_hurt)   = ["ColorCorrections", 8001] call _fnc_setupPPEffect;
GVAR(ui_med_colourFx_health) = ["ColorCorrections", 8002] call _fnc_setupPPEffect;
GVAR(ui_med_blurFx)          = ["RadialBlur", 100] call _fnc_setupPPEffect;
