/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Generates the identities of the AI units and saves them in a global array.

		Only executed once by the server upon initialisation.
	Arguments:
		(none)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"
#include "..\..\mission\settings.inc"





// Set up some constants
private _allFaces = [];
private _allSpeakers = [];
private _allRoles = [
	MACRO_ENUM_ROLE_SPECOPS,
	MACRO_ENUM_ROLE_SNIPER,
	MACRO_ENUM_ROLE_ASSAULT,
	MACRO_ENUM_ROLE_SUPPORT,
	MACRO_ENUM_ROLE_ENGINEER,
	MACRO_ENUM_ROLE_MEDIC,
	MACRO_ENUM_ROLE_ANTITANK
];
private _allNames =
	#include "..\..\res\ai_names.inc"
;
private _maxRolesCount = count _allRoles;
private _maxNamesCount = count _allNames;
private _maxFaceCounts = [];
private _maxSpeakersCount = [];

// Set up some variables
private _totalWeight = 0;
private _sideIndexThresholds = [];
private _prevSideIndex = -1;
private _allNames_copy = [];
private ["_faces", "_voices", "_sideFaces", "_sideSpeakers"];
private ["_sideIndex", "_unitIndex", "_sideRoles", "_rolesCount", "_namesCount", "_facesCount", "_speakersCount", "_groupIndex", "_isLeader", "_role", "_name", "_face", "_speaker"];
GVAR(sv_AIIdentities) = [];





// Compile the data for all required sides
{
	_x params ["_side", "_sideWeight"];

	_faces  = missionNamespace getVariable [format [QGVAR(aiFaces_%1), _side], []];
	_voices = missionNamespace getVariable [format [QGVAR(aiVoices_%1), _side], []];

	// Only continue if this side exists
	if (_side in GVAR(sides)) then {
		_totalWeight = _totalWeight + (_sideWeight max 0);

		_sideFaces = [_faces] call FUNC(ai_getFaces);
		_sideSpeakers = [_voices] call FUNC(ai_getVoices);
	} else {
		_sideFaces = [];
		_sideSpeakers = [];
	};

	_allFaces pushBack _sideFaces;
	_allSpeakers pushBack _sideSpeakers;
	_maxFaceCounts pushBack count _sideFaces;
	_maxSpeakersCount pushBack count _sideSpeakers;

	_sideIndexThresholds pushBack _totalWeight;

} forEach [
	[east,       GVAR(param_AI_spawnWeight_east)],
	[resistance, GVAR(param_AI_spawnWeight_resistance)],
	[west,       GVAR(param_AI_spawnWeight_west)]
];

// Scale to the AI count
if (_totalWeight > 0) then { // Edge case for empty sides array
	_sideIndexThresholds = _sideIndexThresholds apply {_x * GVAR(param_AI_maxCount) / _totalWeight};
};

// Append a fourth dummy value to act as "stopper"
_sideIndexThresholds pushBack 9e9;





// Generate all AI identities
for "_i" from 0 to GVAR(param_AI_maxCount) - 1 do {

	// Associate the unit to a side
	_sideIndex = _sideIndexThresholds findIf {_x > _i};
	_unitIndex = _i - floor (_sideIndexThresholds param [_sideIndex - 1, 0]);

	// If the side has changed (ie the index is now in a different region), update our variables
	if (_sideIndex != _prevSideIndex) then {
		_prevSideIndex = _sideIndex;
		_sideRoles = [];
		_sideFaces = [];
		_sideSpeakers = [];
	};

	// If the roles array is empty, make a new copy
	if (_sideRoles isEqualTo []) then {
		_sideRoles = +_allRoles;
		_rolesCount = _maxRolesCount;
	};

	// If the names array is empty, make a new copy
	if (_allNames_copy isEqualTo []) then {
		_allNames_copy = +_allNames;
		_namesCount = _maxNamesCount;
	};

	// If the current faces array is empty, make a new copy
	if (_sideFaces isEqualTo []) then {
		_sideFaces = +(_allFaces param [_sideIndex, []]);
		_facesCount = _maxFaceCounts param [_sideIndex, 0];
	};

	// If the current speakers array is empty, make a new copy
	if (_sideSpeakers isEqualTo []) then {
		_sideSpeakers = +(_allSpeakers param [_sideIndex, []]);
		_speakersCount = _maxSpeakersCount param [_sideIndex, 0];
	};

	_groupIndex = floor (_unitIndex / GVAR(param_AI_maxUnitsPerGroup));
	_isLeader   = (_unitIndex mod GVAR(param_AI_maxUnitsPerGroup) == 0);

	// Sanity check: if not all data is complete, skip this identity (otherwise a script error is raised)
	if (
		_rolesCount > 0
		and {_namesCount > 0}
		and {_facesCount > 0}
		and {_speakersCount > 0}
	) then {
		// Generate a new identity and add it to the global array
		_role    = _sideRoles     deleteAt floor (random _rolesCount);
		_name    = _allNames_copy deleteAt floor (random _namesCount);
		_face    = _sideFaces     deleteAt floor (random _facesCount);
		_speaker = _sideSpeakers  deleteAt floor (random _speakersCount);
	} else {
		_role    = MACRO_ENUM_ROLE_INVALID;
		_name    = "";
		_face    = "";
		_speaker = "";
	};

	GVAR(sv_AIIdentities) pushBack [
		_sideIndex,  // MACRO_ENUM_AIIDENTITY_SIDEINDEX
		_groupIndex, // MACRO_ENUM_AIIDENTITY_GROUPINDEX
		_isLeader,   // MACRO_ENUM_AIIDENTITY_ISLEADER
		_role,       // MACRO_ENUM_AIIDENTITY_ROLE
		_name,       // MACRO_ENUM_AIIDENTITY_NAME
		_face,       // MACRO_ENUM_AIIDENTITY_FACE
		_speaker,    // MACRO_ENUM_AIIDENTITY_SPEAKER
		_i           // MACRO_ENUM_AIIDENTITY_UNITINDEX
	];

	// Decrease the array counts
	_rolesCount = _rolesCount - 1;
	_namesCount = _namesCount - 1;
	_facesCount = _facesCount - 1;
	_speakersCount = _speakersCount - 1;
};





// Broadcast a trimmed copy of the AI identities to all clients
GVAR(cl_AIIdentities) = GVAR(sv_AIIdentities) apply {_x select [0, 5]}; // Side index .. name
publicVariable QGVAR(cl_AIIdentities);

diag_log format ["[CONQUEST] (SERVER) Generated %1 AI identities", count GVAR(sv_AIIdentities)];
