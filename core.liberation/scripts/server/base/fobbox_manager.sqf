waitUntil {sleep 1; !isNil "GRLIB_all_fobs" };
waitUntil {sleep 1; !isNil "save_is_loaded" };

private [ "_fobbox", "_foblist" ];

_fob_type = FOB_box_typename;
if ( GRLIB_fob_type == 1 ) then {
	_fob_type = FOB_truck_typename;
};

if ( GRLIB_fob_type == 2 ) then {
	_fob_type = FOB_boat_typename;
};

while { true } do {

	_foblist = {[_x] call is_public} count (entities _fob_type);

	if ( _foblist == 0 && count GRLIB_all_fobs == 0 ) then {
		_fobbox = _fob_type createVehicle (getPosATL base_boxspawn);
		_fobbox allowdamage false;
		_fobbox setPosATL (getPosATL base_boxspawn);
		_fobbox setdir (getdir base_boxspawn);
		[_fobbox] call F_clearCargo;
		_fobbox enableSimulationGlobal true;
		_fobbox setVariable ["GRLIB_vehicle_owner", "public", true];
		sleep 3;
		_fobbox setDamage 0;
		_fobbox allowdamage true;
		if (GRLIB_ACE_enabled) then {
			[_fobbox] call F_aceInitVehicle;
		};
		waitUntil {
			sleep 1;
			!(alive _fobbox) || count GRLIB_all_fobs > 0
		};
		deleteVehicle _fobbox;
		sleep 30;
	};
	sleep 18;
};