// Define some variables
private _unitSafeStart = _unit getVariable [QGVAR(ai_unitControl_safeStart_isSafe), !_missionSafeStart];





// Enforce safestart on the unit
if (_missionSafeStart != _unitSafeStart) then {

	if (_missionSafeStart) then {
		[true, MACRO_ENUM_AI_PRIO_SAFESTART, _unit, ["MOVE", "FSM", "TARGET", "AUTOTARGET"], false] call FUNC(ai_toggleFeature);

		_unit setUnitCombatMode "BLUE";

		// Turn off the vehicle engine (except for aircraft)
		if (alive _unitVehicle and {!(_unitVehicle isKindOf "Air")}) then {
			_unitVehicle engineOn false;
		};

	} else {
		[false, MACRO_ENUM_AI_PRIO_SAFESTART, _unit, ["MOVE", "FSM", "TARGET", "AUTOTARGET"]] call FUNC(ai_toggleFeature);

		_unit setUnitCombatMode "RED";
	};

	_unit setVariable [QGVAR(ai_unitControl_safeStart_isSafe), _missionSafeStart, false];
};
