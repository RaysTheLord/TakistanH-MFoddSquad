
/* ----------------------------------------------------------------------------
Function: btc_chem_fnc_propagate

Description:
    Propagate from the item or vehicle contaminated to the item or vehicle not contaminated.

Parameters:
    _item - Item. [Object]
    _vehicle - Vehicle. [Object]

Returns:

Examples:
    (begin example)
        [cursorObject, vehicle player] call btc_chem_fnc_propagate;
    (end)

Author:
    Vdauphin

---------------------------------------------------------------------------- */

params [
    ["_item", objNull, [objNull, ""]],
    ["_vehicle", objNull, [objNull]]
];

if (_item isEqualType "") exitWith {_this};

//Blacklisted layers that won't get contaminated
_objects_cop = ((getMissionLayerEntities "COP") select 0) + ((getMissionLayerEntities "Vic Paths") select 0);

_groups_cop = ((getMissionLayerEntities "COP Ambient Persistent") select 2) + ((getMissionLayerEntities "COP Ambient Random") select 2) + ((getMissionLayerEntities "COP Ambient TOC") select 2) + + ((getMissionLayerEntities "Virtual Cam") select 2);

_blacklisted_units = [];
{
    _blacklisted_units append (units _x);
} forEach _groups_cop;

_final_blacklist = _objects_cop + _blacklisted_units;

if (_item in _final_blacklist || _vehicle in _final_blacklist) exitWith {""};

//Return to normal code
if (_item in btc_chem_contaminated) then {
    if ((btc_chem_contaminated pushBackUnique _vehicle) > -1) then {
        publicVariable "btc_chem_contaminated";
    };
} else {
    if (_vehicle in btc_chem_contaminated) then {
        if ((btc_chem_contaminated pushBackUnique _item) > -1) then {
            publicVariable "btc_chem_contaminated";
        };
    };
};

_this
