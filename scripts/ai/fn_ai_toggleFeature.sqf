/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LA][LE]
		Sets a unit's AI feature to the specified value.

		This function handles deconfliction between all systems which use the same set of low-level AI features.
		When submitting a request, the unit's AI feature is not guaranteed to be set to the specified value,
		as other currently active requests may outrank it (higher priorities outrank lower ones).
		For ease of use, multiple AI features can be toggled with one call.
	Arguments:
		0:	<BOOLEAN>	True to submit a request, false to withdraw it
		1:	<NUMBER>	The request priority
		2:	<OBJECT>	The concerned unit
		3:	<STRING>	The AI feature enum to toggle (see disableAI documentation)
					OR:
			<ARRAY>		A list of AI feature enums to toggle
		4:	<BOOLEAN>	The desired value for the AI feature(s) (optional, only used for requests
					submissions)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_isRequest", true, [true]],
	["_priority", -1, [-1]],
	["_unit", objNull, [objNull]],
	["_featureOrArray", "", ["", []]],
	"_desiredValue"
];

// Enforce a vald iunit
if (!local _unit or {!([_unit] call FUNC(unit_isAlive))}) exitWith {};

// Enforce valid requests
if (_priority < 0 or {_isRequest and {isNil "_desiredValue" or {!(_desiredValue isEqualType true)}}}) exitWith {};





#define MACRO_ALLFEATURES ["AIMINGERROR", "ANIM", "AUTOCOMBAT", "AUTOTARGET", "CHECKVISIBLE", "COVER", "FSM", "LIGHTS", "MINEDETECTION", "MOVE", "NVG", "PATH", "RADIOPROTOCOL", "SUPPRESSION", "TARGET", "TEAMSWITCH", "WEAPONAIM"]

private "_features";
if (_featureOrArray isEqualType "") then {
	if (_featureOrArray == "ALL") then {
		_features = MACRO_ALLFEATURES;
	} else {
		_features = [toUpper _featureOrArray];
	};
} else {
	_features = _featureOrArray apply {toUpper _x};
};

private ["_varName", "_allRequests", "_error", "_index", "_value"];





{
	if (_x in MACRO_ALLFEATURES) then {
		_varName     = format [QGVAR(ai_tf_%1), _x];
		_allRequests = _unit getVariable [_varName, []];
		_error       = false;

		// Handle request submission and widthdrawal
		if (_isRequest) then {
			_error = (_allRequests pushBackUnique [_priority, _desiredValue]) < 0;
			_allRequests sort false;
		} else {
			_index = _allRequests findIf {_x # 0 == _priority};

			if (_index >= 0) then {
				_allRequests deleteAt _index;
			} else {
				_error = true;
			};
		};

		if (!_error) then {
			_unit setVariable [_varName, _allRequests, false];

			// Evaluate the resulting feature value
			_value = _allRequests param [0, []] param [1, true];

			_unit enableAIFeature [_x, _value];
		};
	};

} forEach _features;
