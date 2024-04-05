// Client component (stage 2)
diag_log "[CONQUEST] Client initialisation (stage 2) starting...";





// Player whitelist for closed testing (TODO: to be removed in beta version)
if (isMultiplayer and {!(getPlayerUID player in [
	"76561197990033729",
	"76561198906648345",
	"76561197970677684",
	"76561198030888670",
	"76561198043936460",
	"76561197997583060"
])}) exitWith {
	endMission "Not_Whitelisted";
};





// Define shared global variables (broadcast by the server)
MACRO_FNC_INITVAR(GVAR(sides),[]);
MACRO_FNC_INITVAR(GVAR(safeStart), false);
MACRO_FNC_INITVAR(GVAR(missionState), MACRO_ENUM_MISSION_INIT);

MACRO_FNC_INITVAR(GVAR(ticketsEast), MACRO_GM_STARTINGTICKETS);
MACRO_FNC_INITVAR(GVAR(ticketsResistance), MACRO_GM_STARTINGTICKETS);
MACRO_FNC_INITVAR(GVAR(ticketsWest), MACRO_GM_STARTINGTICKETS);
MACRO_FNC_INITVAR(GVAR(ticketBleedEast), false);
MACRO_FNC_INITVAR(GVAR(ticketBleedResistance), false);
MACRO_FNC_INITVAR(GVAR(ticketBleedWest), false);

MACRO_FNC_INITVAR(GVAR(cl_AIIdentities),[]);

// Define global client variables
MACRO_FNC_INITVAR(GVAR(side),sideEmpty);
GVAR(role) = MACRO_ENUM_ROLE_INVALID;
GVAR(spawnSector) = objNull;

MACRO_FNC_INITVAR(GVAR(cam_panorama),objNull);
MACRO_FNC_INITVAR(GVAR(STHUD_UIMode),0);
MACRO_FNC_INITVAR(GVAR(UI_prevPlayerSide),GVAR(side));	// Used to update sector colours if the player changes sides





// Set up the panorama camera
camDestroy GVAR(cam_panorama);
GVAR(cam_panorama) = "camera" camCreate [0,0,0];
GVAR(cam_panorama) setPosWorld MACRO_MISSION_CAMERAPOSITION;
GVAR(cam_panorama) setVectorDirAndUp [MACRO_MISSION_CAMERADIRECTION, [0,0,1]];

call FUNC(act_registerKeybindings);

call FUNC(ca_handleCombatArea_player);

call FUNC(gm_sys_enforceFPVInCamera);
call FUNC(gm_sys_updatePlayerVars);
call FUNC(gm_sys_handlePlayerRespawn);

call FUNC(sector_handleClient);

call FUNC(ui_setupPPEffects); // Executes first, to initialise the handles
call FUNC(ui_sys_hookMapCtrls);
call FUNC(ui_sys_drawHealthBar);
call FUNC(ui_sys_drawHitMarkers);
call FUNC(ui_sys_drawIcons3D);
call FUNC(ui_sys_drawKillFeed);
call FUNC(ui_sys_drawMedicalEffects);
call FUNC(ui_sys_drawSectorHUD);
call FUNC(ui_sys_drawScoreFeed);

// Add unit EHs on all existing units. Useful for JIP.
// This won't add the EHs to the player (as they haven't spawned yet), but that will be handled by gm_spawnPlayer.
{
	if (_x getVariable [QGVAR(isSpawned), false]) then {
		[_x] call FUNC(unit_onInit);
	};
} forEach allUnits;

// Prevent AI squad mates from cluttering up the player with radio messages
enableRadio false;





// Delete all sector markers (DEBUG)
{
	deleteMarkerLocal (_x getVariable [QGVAR(markerArea), ""]);
	deleteMarkerLocal (_x getVariable [QGVAR(markerAreaOutline), ""]);

	_x setVariable [QGVAR(sideLast), sideEmpty, false];
} forEach GVAR(allSectors);

// Create map markers for all sectors
{
	// Fetch the sector's letter, position, direction and size
	private _letter = _x getVariable [QGVAR(letter), ""];
	private _pos = position _x;
	private _size = triggerArea _x;
	private _posFlag = position (_x getVariable [QGVAR(flagPole), _x]);

	// Create a marker for the sector's area
	private _markerArea = format [QGVAR(mkr_%1_area), _letter];
	createMarkerLocal [_markerArea, _pos];
	_markerArea setMarkerDirLocal (_size select 2);
	_markerArea setMarkerSizeLocal [_size select 0, _size select 1];
	_markerArea setMarkerShapeLocal (["ELLIPSE", "RECTANGLE"] select (_size select 3));
	_markerArea setMarkerBrushLocal "SolidFull";
	_markerArea setMarkerColorLocal "colorWhite";
	_markerArea setMarkerAlphaLocal 0.25;

	// Create a marker for the sector's area's outline
	private _markerAreaOutline = format [QGVAR(mkr_%1_outline), _letter];
	createMarkerLocal [_markerAreaOutline, _pos];
	_markerAreaOutline setMarkerDirLocal (_size select 2);
	_markerAreaOutline setMarkerSizeLocal [_size select 0, _size select 1];
	_markerAreaOutline setMarkerShapeLocal (["ELLIPSE", "RECTANGLE"] select (_size select 3));
	_markerAreaOutline setMarkerBrushLocal "Border";
	_markerAreaOutline setMarkerColorLocal "colorWhite";

	// Save the markers onto the sector
	_x setVariable [QGVAR(markerArea), _markerArea, false];
	_x setVariable [QGVAR(markerAreaOutline), _markerAreaOutline, false];
} forEach GVAR(allSectors);

// Edge case for locally hosted games
if (!isServer) then {

	// Disable all sector triggers from executing
	{
		_x setTriggerType "NONE";
		_x setTriggerStatements ["false", "", ""];
		_x setTriggerInterval 9e9;
	} forEach GVAR(allSectors);
};





/*
// ACE3 - Allow medics to use PAKs in basic medical
if (!isNil QGVAR(ACE3_addedActionPAK)) then {
	GVAR(ACE3_addedActionPAK) = true;

	if (!isNil "ace_medical_level" and {ace_medical_level == 1}) then {

		// Define the healing actions
		private _actionHealSelf = [
			QGVAR(healSelf),
			"Heal Self (PAK)",
			"",
			{[_player, _player] spawn FUNC(ace_usePAK)},
			{
				params [["_player", objNull]];
				"ACE_personalAidKit" in items _player;
			}
		] call ace_interact_menu_fnc_createAction;

		private _actionHealOther = [
			QGVAR(healOther),
			"Heal (PAK)",
			"",
			{[_player, _target] spawn FUNC(ace_usePAK)},
			{
				params [["_player", objNull], ["_target", objNull]];
				("ACE_personalAidKit" in items _player) or {"ACE_personalAidKit" in items _target};
			}
		] call ace_interact_menu_fnc_createAction;

		// Add the new actions to the ACE menu
		["CAManBase", 1, ["ACE_SelfActions", "Medical", "ACE_Torso"], _actionHealSelf, true] call ace_interact_menu_fnc_addActionToClass;
		["CAManBase", 0, ["ACE_Torso"], _actionHealOther, true] call ace_interact_menu_fnc_addActionToClass;
		["CAManBase", 0, ["ACE_MainActions", "Medical", "ACE_Torso"], _actionHealOther, true] call ace_interact_menu_fnc_addActionToClass;
	};
};
*/





// Preslotting (debug)
#ifdef MACRO_DEBUG_GM_PRESLOT

	// Select the first valid side and spawnable sector
	GVAR(side) = GVAR(sides) param [GVAR(sides) findIf {_x != sideEmpty}, sideEmpty];
	GVAR(role) = MACRO_ENUM_ROLE_ASSAULT;
	GVAR(spawnSector) = GVAR(allSectors) param [GVAR(allSectors) findIf {
		_x getVariable [QGVAR(side), sideEmpty] == GVAR(side)
		and {_x getVariable [format [QGVAR(spawnPoints_%1), GVAR(side)], []] isNotEqualTo []}
	}, objNull];

	// Skip the spawn menu altogether
	GVAR(sys_handlePlayerRespawn_spawnRequested) = true;
	GVAR(sys_handlePlayerRespawn_state) = MACRO_ENUM_RESPAWN_SECTORSELECTED;
#endif





diag_log "[CONQUEST] Client initialisation (stage 2) done.";
