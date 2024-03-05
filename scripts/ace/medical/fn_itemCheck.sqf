// This (empty) function prevents ACE from replacing Medkits and First Aid Kits with its own items.

// Make sure the variable exists
if (isNil "ace_medical_level") then {ace_medical_level = 0};

// If ACE medical is disabled, don't replace any items
if (ace_medical_level <= 0) exitWith {};





// Otherwise, let ACE do its thing (NOTE: File no longer exists since v3.13.0! Will cause a crash!)
//#include "\z\ace\addons\medical\functions\fnc_itemCheck.sqf"
