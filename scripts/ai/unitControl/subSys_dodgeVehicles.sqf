if (!_isInVehicle) then {

	// Define some macros
	#define MACRO_AI_DODGEVEHICLE_MAXDISTANCE 100
	#define MACRO_AI_DODGEVEHICLE_DANGERDISTANCE 5

	// Set up some variables
	private _dodgeDistSqr         = MACRO_AI_DODGEVEHICLE_MAXDISTANCE ^ 2;
	private _closestDangerDistSqr = MACRO_AI_DODGEVEHICLE_DANGERDISTANCE ^ 2;
	private _objectToDodge        = objNull;
	private _prevObjectToDodge    = _unit getVariable [QGVAR(ai_unitControl_dodgeVehicles_obj), objNull];
	private ["_posX", "_distSqrX", "_velX", "_velXMagSqr"];





	// Determine which objects the unit should dodge
	{
		_posX     = getPosWorld _x;
		_distSqrX = _unitPos distanceSqr _posX;

		if (_distSqrX < _dodgeDistSqr) then {
			_velX       = velocity _x;
			_velXMagSqr = 15 * (vectorMagnitude _velX) ^ 2; // Coefficients tuned for best responsiveness

			if (_velXMagSqr > _distSqrX) then {
				_velX = (vectorNormalized _velX) vectorMultiply sqrt _distSqrX;
			};

			if (_velXMagSqr > 1) then {
				_distSqrX = 0 max (_unitPos distanceSqr (_posX vectorAdd _velX)) - sizeOf typeOf _x;

				if (_distSqrX < _closestDangerDistSqr) then {
					_objectToDodge        = _x;
					_closestDangerDistSqr = _distSqrX;
				};
			};
		};
	} forEach vehicles;





	private ["_dirObject", "_dirVel", "_dodgeDir", "_shouldDodgeLeft"];
	if (!isNull _objectToDodge) then {

		// Determine where to dodge
		_dirObject = _unitPos vectorDiff getPosWorld _objectToDodge;
		_dirVel    = velocity _objectToDodge;
		_dodgeDir  = _dirVel vectorCrossProduct [0, 0, 1];

		// Ensure the dodge direction stays persistent per object, to stop units from switching directions too often
		if (_objectToDodge == _prevObjectToDodge) then {
			_shouldDodgeLeft = _unit getVariable [QGVAR(ai_sys_unitControl_dodgeVehicles_left), false];
		} else {
			// When this cross product's Z is negative, the unit should dodge left (not right)
			_shouldDodgeLeft = ((_dirObject vectorCrossProduct _dirVel) # 2 < 0);

			//systemChat format ["(%1) %2 dodging %3 (%4)", diag_frameNo, _unit, _objectToDodge, _prevObjectToDodge];

			_unit setVariable [QGVAR(ai_sys_unitControl_dodgeVehicles_left), _shouldDodgeLeft, false];
		};

		if (_shouldDodgeLeft) then {
			_dodgeDir = _dodgeDir vectorMultiply -1;
		};

		[_unit, _unitPos vectorAdd _dodgeDir] call FUNC(anim_dodge);
	};

	_unit setVariable [QGVAR(ai_unitControl_dodgeVehicles_obj), _objectToDodge, false];





	#ifdef MACRO_DEBUG_AI_DODGEVEHICLES

		if (!isNull _objectToDodge) then {
			GVAR(debug_ai_unitControl_dodgeVehicles_data) set [_unitIndex, [
				[
					ASLtoATL _unitPos vectorAdd [0, 0, 0.5],
					_objectToDodge modelToWorldVisual [0, 0, 0],
					[1, 0.03, 0, 1]
				],
				[
					ASLtoATL _unitPos vectorAdd [0, 0, 0.5],
					ASLtoATL _unitPos vectorAdd [0, 0, 0.5] vectorAdd (vectorNormalized _dodgeDir vectorMultiply MACRO_AI_DODGEVEHICLE_DANGERDISTANCE),
					[1, 0.03, 0, 1]
				]
			]];
		} else {
			GVAR(debug_ai_unitControl_dodgeVehicles_data) set [_unitIndex, nil];
		};
	#endif
};
