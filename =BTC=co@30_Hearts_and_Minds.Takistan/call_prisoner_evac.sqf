if (helicall getVariable ["calledPickup", false]) exitWith {
    "Pickup already called!" call CBA_fnc_notify;
};

helicall setVariable ["calledPickup", true, true];

_chinook_class = "CFP_B_USCIA_Mi_8MT_01";

_min_spawn_dist = (dynamicSimulationDistance "Group") * (dynamicSimulationDistanceCoef "IsMoving");

_helipad_pos = getPos npc_helipad;

_spawnpos = objNull;     
_iterator = 0;     
_max_tries = 50;     
while { (_spawnpos isEqualTo objNull) ||  (([allPlayers, _spawnpos] call Bis_fnc_nearestPosition distance2D _spawnpos) < _min_spawn_dist)} do {     
    _spawnpos = [_helipad_pos, _min_spawn_dist, _min_spawn_dist + 1000, 0, 0, 20, 0, [], [[0, 0, 0], [0, 0, 0]]] call BIS_fnc_findSafePos;     
    _iterator = _iterator + 1;     
    if (_iterator > _max_tries) then {     
        _spawnpos = [0, 0, 0];     
        break;     
    };     
    sleep 0.1;     
};

_veh = createVehicle [_chinook_class, [_spawnpos select 0, _spawnpos select 1, 50], [], 0, "FLY"];
createVehicleCrew _veh;     
_grp = group driver _veh;     
_veh allowDamage false;     
{ _x allowDamage false; _x setCaptive true; } forEach units _grp;     
_grp setCombatMode "BLUE";        
_grp setBehaviour "CARELESS";


_veh setVariable ["canTakeOff", false, true];
_veh addAction ["Clear for takeoff", {(_this select 0) setVariable ["canTakeOff", true, true]; helicall setVariable ["calledPickup", false, true];}];  

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

_midpoint = [((_spawnpos select 0) + (_helipad_pos select 0))/2, ((_spawnpos select 1) + (_helipad_pos select 1))/2, 0];

_midpoint2 = [((_spawnpos select 0) + (_midpoint select 0))/2, ((_spawnpos select 1) + (_midpoint select 1))/2, 0];

_wp1 = _grp addWaypoint [_midpoint2, 0];     
_wp1 setWaypointType "MOVE";     

_wp2 = _grp addWaypoint [npc_helipad, 0];     
_wp2 setWaypointType "SCRIPTED";
_wp2 setWaypointScript "A3\functions_f\waypoints\fn_wpLand.sqf";
_wp2 setWaypointStatements ["true", "(vehicle leader this) spawn {_this setFuel 0;}"];

_wp3 = _grp addWaypoint [_helipad_pos, 0];
_wp3 setWaypointType "MOVE";
_wp3 setWaypointStatements ["(vehicle leader this) getVariable ['canTakeOff', false]", "(vehicle leader this) spawn {_this setFuel 1;}"];

_exit_pos = [nil, ["btc_base"]] call BIS_fnc_randomPos;     
_wp4 = _grp addWaypoint [_exit_pos, 0];
_wp4 setWaypointType "MOVE";     
_wp4 setWaypointStatements ["true", "_veh_cargo = getVehicleCargo (vehicle leader this); {deleteVehicle _x} forEach _veh_cargo; {if (!(_x isEqualTo (leader this))) then {deleteVehicle _x}; } forEach crew (vehicle leader this); deleteVehicle (vehicle leader this); deleteVehicle leader this;"];
