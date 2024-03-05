// Fetch our params
params ["_player", "_target"];





// Wait until the menu is closed
waitUntil {!(uiNamespace getVariable ["ace_interact_menu_cursorMenuOpened", false])};
sleep 0.01;

// Get the player's weapons
private _curWeapon = currentWeapon _player;
private _rifle = primaryWeapon _player;
private _pistol = handgunWeapon _player;

// If the player doesn't have a weapon selected, give them one
private _usingRifle = true;
if (_curWeapon == "") then {
	if (_rifle == "") then {
		if (_pistol == "") then {
			_player addWeapon "ACE_FakePrimaryWeapon";
			_player selectWeapon "ACE_FakePrimaryWeapon";
		} else {
			_usingRifle = false;
			_player selectWeapon _pistol;
		};
	} else {
		_player selectWeapon _rifle;
	};
} else {
	if (_curWeapon == _pistol) then {
		_usingRifle = false;
	};
};

// If we're not in a vehicle, play an animation
if (vehicle _player == _player) then {
	if (_usingRifle) then {
		_player playMoveNow "ainvpknlmstpslaywrfldnon_medic";
	} else {
		_player playMoveNow "ainvpknlmstpslaywpstdnon_medic";
	};
};

// Start the progress bar
[
        5,
        _this,
        {
		(_this select 0) params ["_player", "_target"];
		private _itemClass = ["FirstAidKit", "ACE_personalAidKit"] select (ace_medical_level > 0);

                // Consume the PAK and heal the other unit
		private _canHeal = false;
		if (_itemClass in items _player) then {
			_canHeal = true;
                	_player removeItem _itemClass;
		} else {
			if (_itemClass in items _target) then {
				_canHeal = true;
	                	_target removeItem _itemClass;
			};
		};

		// Remove the fake weapon
		_player removeWeapon "ACE_FakePrimaryWeapon";

		// If we have a PAK, heal the target
		if (_canHeal) then {
			[_player, _target] call ace_medical_fnc_treatmentAdvanced_fullHeal;
		};
        },
        {
		(_this select 0) params ["_player", "_target"];

		// Get the player's weapons
		private _rifle = primaryWeapon _player;
		private _pistol = handgunWeapon _player;

		// Remove the fake weapon
		if (_rifle == "ACE_FakePrimaryWeapon" or {_rifle == "" and _pistol == ""}) then {
			_player removeWeapon "ACE_FakePrimaryWeapon";
			_player switchMove "amovpknlmstpsnonwnondnon";
		} else {
			if (currentWeapon _player == _rifle) then {
				player switchMove "amovpknlmstpslowwrfldnon";
			} else {
				player switchMove "amovpknlmstpslowwpstdnon";
			};
		};
	},
        "Healing...",
        {
		(_this select 0) params ["_player", "_target"];

		// Make sure both units are alive
		alive _player and {alive _target};
	},
        ["isNotSwimming"]
] call ace_common_fnc_progressBar;
