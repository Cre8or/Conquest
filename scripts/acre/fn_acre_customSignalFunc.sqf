/* --------------------------------------------------------------------------------------------------------------------
	Author:	 	Cre8or
	Description:
		Sets the custom signal processing function for ACRE2 radios, allowing infinite range on all radios for a more
		arcade playstyle.
		For more information, refer to:
			https://acre2.idi-systems.com/wiki/frameworks/custom-signal-processing
		 	https://github.com/IDI-Systems/acre2/blob/master/addons/api/fnc_setCustomSignalFunc.sqf
	Arguments:
		0:	<NUMBER>    The signal frequency in MHz
		1:	<NUMBER>    The transmitter power in mW
		2:	<STRING>    The classname of the transmitting radio
		3:	<STRING>    The classname of the receiving radio
	Returns:
		0:	<NUMBER>    The power percentage in range 0 .. 1
		1:	<NUMBER>    The received signal strength in dBm
-------------------------------------------------------------------------------------------------------------------- */

params [
	["_frequency", 1, [1]],
	["_power", 1, [1]],
	["_classRadioTx", "", [""]],
	["_classRadioRx", "", [""]]
];

//systemChat format ["(%1) this: %2", _this];

//private _result = _this call acre_sys_signal_fnc_getSignalCore;
private _result = [
	1, // 100% signal integrity
	-50 // Decibels
];
//systemChat format ["(%1) result: %2", _result];

_result;
