params ["_veh"];
_action = ["Load Bodybag", "Load Bodybag", "\A3\Data_F_AoW\Logos\arma3_aow_logo_ca.paa", {
    params ["", "", "_params"];
    _veh = _params select 0;
    
    _coffin_class = "Coffin_02_US_F";
    
    private _array = nearestObjects [_veh, ["ACE_bodyBagObject"], 10];
    _array = _array select {
        alive _x && (
            _x isKindOf "ACE_bodyBagObject"
        )
    };
    if (_array isEqualTo []) exitWith {
        localize "STR_BTC_HAM_O_BODYBAG_NO" call CBA_fnc_notify;
    };
    
    if (!(_array isEqualTo [])) then {
        [_array select 0, player] remoteExecCall ["btc_body_fnc_bagRecover_s", 2];

        _newCoffin = _coffin_class createVehicle [0, 0, 0];
        if (!(_veh setVehicleCargo _newCoffin)) then {
            deleteVehicle _newCoffin;
        };    
    };
}, {true}, {}, [_veh], [0, 0, 0], 5] call ace_interact_menu_fnc_createAction;
[_veh, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;