params ["_veh"];
_action = ["Load Prisoner", "Load Prisoner", "\A3\Data_F_AoW\Logos\arma3_aow_logo_ca.paa", {
    params ["", "", "_params"];
    _veh = _params select 0;
        
    private _array = nearestObjects [_veh, ["CAManBase"], 10];
    _array = _array select {
        alive _x && (
            (_x isKindOf "CAManBase" &&
            side group _x isEqualTo btc_enemy_side))
    };
    if (_array isEqualTo []) exitWith {
        localize "STR_BTC_HAM_O_BODYBAG_NO" call CBA_fnc_notify;
    };
    
    if (!(_array isEqualTo [])) then {
        [_array select 0, player] remoteExecCall ["btc_body_fnc_bagRecover_s", 2];
        
        if ((_veh emptyPositions "Cargo") > 0) then {
            (_array select 0) moveInCargo _veh;
        } else {
            (_array select 0) spawn {
                sleep 5;
                deleteVehicle _this;
            };
        };
    };
}, {true}, {}, [_veh], [0, 0, 0], 5] call ace_interact_menu_fnc_createAction;
[_veh, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;