/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		[LE]
		Increases the danger level of the edge between the two provided AI nodes, discouraging AI units from
		the specified side from using it.
		Used to replicate danger levels across all machines, without broadcasting the full nodemesh's state.

		If no danger level increment is specified, the default increments will be used, which is either:
		* MACRO_NM_DANGERLEVEL_INF_GAIN (for the infantry nodemesh), or
		* MACRO_NM_DANGERLEVEL_VEH_GAIN (for the vehicle nodemesh).

		Executed locally via global remoteExecCall.
	Arguments:
		0:	<NUMBER>	The UID of the first node
		1:	<NUMBER>	The UID of the second node
		2:	<BOOLEAN>	The nodemesh selector (true = vehicles, false = infantry)
		3:	<SIDE>		The affected side
		4:	<NUMBER>	The danger level increment (optional, default: -1)
	Returns:
		(nothing)
-------------------------------------------------------------------------------------------------------------------- */

#include "..\..\res\common\macros.inc"

params [
	["_nodeIDA", -1, [-1]],
	["_nodeIDB", -1, [-1]],
	["_isVehNodeMesh", -1, [-1, false]],
	["_side", sideEmpty, [sideEmpty]],
	["_increment", -1, [-1]]
];

if (_nodeIDA < 0 or {_nodeIDB < 0} or {_isVehNodeMesh isEqualType -1}) exitWith {};

// Ensure the nodemeshes are set up
if (!GVAR(nm_isSetup)) exitWith {};





// Set up some variables
private _allNodes = [GVAR(nm_nodesInf), GVAR(nm_nodesVeh)] select _isVehNodeMesh;
private _nodeA    = _allNodes param [_nodeIDA, objNull];
private _nodeB    = _allNodes param [_nodeIDB, objNull];

if (isNull _nodeA or {isNull _nodeB}) exitWith {};

private _strAB = format [QGVAR(dangerLevel_%1_%2), _nodeIDB, _side];
private _strBA = format [QGVAR(dangerLevel_%1_%2), _nodeIDA, _side];

if (_increment < 0) then {
	_increment = [MACRO_NM_DANGERLEVEL_INF_GAIN, MACRO_NM_DANGERLEVEL_VEH_GAIN] select _isVehNodeMesh;
};





// Increase the danger level on both nodes' edges
private _dangerLevelA = _nodeA getVariable [_strAB, 0];
private _dangerLevelB = _nodeB getVariable [_strBA, 0];

_nodeA setVariable [_strAB, _dangerLevelA + _increment, false];
_nodeB setVariable [_strBA, _dangerLevelB + _increment, false];

//diag_log format ["Danger level %1-%2 (%3): %4 -> %5", _nodeIDA, _nodeIDB, ["inf", "veh"] select _isVehNodeMesh, _dangerLevelA, _nodeA getVariable [_strAB, 0]];
