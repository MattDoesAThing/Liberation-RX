params ["_unit", "_uid"];

if (isNull _unit) exitWith {};

private _name = name _unit;

if (_name in ["HC1","HC2","HC3" ]) exitWith {
	deleteMarker "fpsmarkerHC1";
	deleteMarker "fpsmarkerHC2";
	deleteMarker "fpsmarkerHC3";
	false;
};

diag_log format ["--- LRX Cleanup player %1 (%2)", _name, _uid];

// Untow vehicle near FOB
// Abandon Car too Far
private _my_veh = vehicles select { _x getVariable ["GRLIB_vehicle_owner", ""] == _uid };
{ 
	if ([_x, "FOB", GRLIB_fob_range] call F_check_near) then {
		[_x] call untow_vehicle;
	} else {
		[_x, "abandon"] call F_vehicleLock;
	};
} forEach _my_veh;

// Remove tents too far
private _my_tent = [];
if (!isNil "GRLIB_mobile_respawn") then {
	_my_tent = GRLIB_mobile_respawn select {
		!([_x, "FOB", GRLIB_fob_range] call F_check_near) &&
		isNil {_x getVariable "R3F_LOG_est_transporte_par"} &&
		(_x getVariable ["GRLIB_vehicle_owner", ""] == _uid)
	};
	{
		GRLIB_mobile_respawn = GRLIB_mobile_respawn - [_x];
		deleteVehicle _x;
	} forEach _my_tent;
	publicVariable "GRLIB_mobile_respawn";
};

// Remove Dog
private _my_dog = _unit getVariable ["my_dog", nil];
if (!isNil "_my_dog") then { deleteVehicle _my_dog };

// Remove Marker
deletemarker format ["PAR_marker_%1", _name];

// Remove Squad
private _my_squad = _unit getVariable ["my_squad", nil];
if (!isNil "_my_squad") then { {deleteVehicle _x} forEach units _my_squad };

// remove Grave Box
private _grave_box = _unit getVariable ["PAR_grave_box", nil];
if (!isNil "_grave_box") then { deleteVehicle _grave_box };

// Remove Taxi
private _taxi = _unit getVariable ["GRLIB_taxi_called", nil];
if (!isNil "_taxi") then {
	if (getMarkerColor "taxi_lz" != "") then {
		deleteVehicle (nearestObjects [markerPos "taxi_lz", [taxi_helipad_type], 50] select 0);
		deleteMarkerLocal "taxi_lz";
	};
	if (getMarkerColor "taxi_dz" != "") then {
		deleteVehicle (nearestObjects [markerPos "taxi_dz", [taxi_helipad_type], 50] select 0);
		deleteMarkerLocal "taxi_dz";
	};
	{ deletevehicle _x } forEach (crew _taxi);
	deleteVehicle _taxi;
};

// Delete Body
removeAllWeapons _unit;
removeAllAssignedItems _unit;
removeUniform _unit;
removeVest _unit;
removeBackpack _unit;
removeHeadgear _unit;
removeGoggles _unit;
deleteVehicle _unit;

private _text = format ["Bye bye %1, see you soon...", _name];
[gamelogic, _text] remoteExec ["globalChat", -2];
