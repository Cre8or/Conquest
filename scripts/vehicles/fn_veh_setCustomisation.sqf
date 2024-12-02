/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LA][GE]
		Configures a vehicle's customisation by adjusting its textures, animation states and pylons. Used to set
		vehicles to a predefined style provided via faction data files.

		Textures can either be an array of individual textures in format [ID, texturePath], or a string representing
		a class-defined texture source (e.g. "CSAT").
		Animation states to be set are passed in pairs of format [animation, phase].
	Arguments:
		0:	<OBJECT>	The vehicle to be customised
		1:	<ARRAY>		Array of textures to apply (optional, default: [])
			OR
			<STRING>	A class-defined texture source (optional, default: "")
		2:	<ARRAY>		Animation states to set (optional, default: [])
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_veh", objNull, [objNull]],
	["_textures", "", ["", []]],
	["_animations", [], [[]]]
];

if (!local _veh) exitWith {};





// Disable randomisation
if (
	_animations isNotEqualTo []
	or {_textures isNotEqualTo "" and {_textures isNotEqualTo []}}
) then {
	_veh setVariable ["BIS_enableRandomization", false, true];
};





// Handle custom textures
if (_textures isEqualType []) then {
	{
		_veh setObjectTextureGlobal _x;
	} forEach _textures;
} else {
	if (_textures != "") then {
		private _currentTextures = getObjectTextures _veh;
		private _targetTextures  = getArray (configFile >> "CfgVehicles" >> typeOf _veh >> "textureSources" >> _textures >> "textures");

		{
			if (_x != _currentTextures param [_forEachIndex, ""]) then {
				_veh setObjectTextureGlobal [_forEachIndex, _x];
			};
		} forEach _targetTextures;
	};
};





// Handle animations
if (_animations isNotEqualTo []) then {

	private _class   = typeOf _veh;
	private _hashMap = createHashMap;

	// Map the intended animations onto a hashmap for referencing
	{
		// Validation
		if (count _x != 2) then {
			systemChat format ["Skipping animation %1 (bad count)", _x];
			continue;
		};

		_hashMap set [toLower (_x # 0), _x # 1];
	} forEach _animations;

	// Reset all animation phases to either default or specified values
	private ["_source", "_phaseCurrent", "_phaseDefault", "_phaseTarget"];
	{
		_source       = toLower configName _x;
		_phaseCurrent = _veh animationPhase _source;
		_phaseDefault = getNumber (_x >> "initPhase");
		_phaseTarget = _hashMap getOrDefault [_source, _phaseDefault];

		if (_phaseCurrent != _phaseTarget) then {
			//systemChat format ["Setting %1: %2 -> %3 (is door: %4)", _source, _phaseCurrent, _phaseTarget, getText (_x >> "source") == "door"];

			if (getText (_x >> "source") == "door") then {
				_veh animateDoor [_source, _phaseDefault, true];
			} else {
				if (getNumber (_x >> "useSource") == 1) then {
					_veh animateSource [_source, _phaseTarget, true];
				} else {
					_veh animate [_source, _phaseTarget, true]
				};
			};
		};
	} forEach configProperties [configFile >> "CfgVehicles" >> _class >> "AnimationSources", "true", true];
};
