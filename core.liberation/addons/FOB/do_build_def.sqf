// LRX FOB Defense
// by pSiKO

private _fob = (player nearObjects [FOB_typename, 20] select 0);
if (isNil "_fob") exitWith {};
private _fob_pos = getPosATL _fob;
private _fob_dir = getDir _fob;

createDialog "FOB_Defense";
waitUntil { dialog };

private _input_controls = [521,522,523,524,525,526,527];
{ ctrlShow [_x, false] } foreach _input_controls;

private _display = findDisplay 2309;
private _icon = getMissionPath "res\ui_build.paa";
private ["_selected_item", "_entrytext", "_defense_template", "_defense_name", "_defense_price"];

lbClear 110;
{
    _entrytext = (_x select 0);
    _defense_price = (_x select 2);
    if (count _entrytext > 25) then { _entrytext = _entrytext select [0,25] };
    (_display displayCtrl (110)) lnbAddRow [_entrytext, str _defense_price];
    lnbSetPicture  [110, [((lnbSize 110) select 0) - 1, 0], _icon];
} foreach GRLIB_FOB_Defense;
lbSetCurSel [110, -1];

build_action = 0;
private _objects_to_build = [];

while { dialog && alive player } do {
    if (build_action != 0) then {
        _selected_item = lbCurSel 110;
        _defense_name = (_display displayCtrl (110)) lnbText [_selected_item, 0];
        _defense_price = (_display displayCtrl (110)) lnbText [_selected_item, 1];
        if (_selected_item > 0) then {
            _defense_template = GRLIB_FOB_Defense select _selected_item select 1;
            _objects_to_build = ([] call compile preprocessFileLineNumbers _defense_template);
        } else {
            { ctrlShow [_x, true] } foreach _input_controls;	
            input_save = "";
            waitUntil {uiSleep 0.3; ((input_save != "") || !(dialog) || !(alive player))};
            if ( input_save select [0,1] == "[" && input_save select [(count input_save)-1,(count input_save)] == "]") then {
                _objects_to_build = (parseSimpleArray input_save);
            } else { systemchat "Error: Invalid data!" };
            { ctrlShow [_x, false] } foreach _input_controls;
        };
        closeDialog 0;
    };
    sleep 0.2;
};

if (build_action == 0) exitWith {};
if (count _objects_to_build == 0) exitWith {};
if (!([parseNumber _defense_price] call F_pay)) exitWith {};
gamelogic globalChat format ["Build %1 (%2 objects) on FOB %3 ", _defense_name, count _objects_to_build, ([_fob_pos] call F_getFobName)];

// Build defense in FOB direction
private ["_nextclass", "_nextobject", "_nextpos", "_nextdir"];
_fob_pos set [2, 0];
{
    if (_forEachIndex % 12 == 0) then {
        [player, "Land_Carrier_01_blast_deflector_up_sound"] remoteExec ["sound_range_remote_call", 2];
    };
	_nextclass = (_x select 0);
	_nextpos = (_x select 1);
	_nextdir = (_x select 2) + _fob_dir;
    _nextpos = _fob_pos vectorAdd ([_nextpos, -_fob_dir] call BIS_fnc_rotateVector2D);

    if (!surfaceIsWater _nextpos && !isOnRoad _nextpos) then {
        _nextobject = _nextclass createVehicle _nextpos;
        _nextobject allowDamage false;
        _nextobject setPosATL _nextpos;
        if ([_nextclass, ["Wall_F", "HBarrier_base_F"]] call F_itemIsInClass)  then {
            _nextobject setVectorDirAndUp [[-cos _nextdir, sin _nextdir, 0] vectorCrossProduct surfaceNormal _nextpos, surfaceNormal _nextpos];
        } else {
            _nextobject setVectorDirAndUp [[_nextdir, _nextdir, 0], [0,0,1]];
        };
        sleep 0.3;
    };
} foreach _objects_to_build;