params ["_unit", "_selection", "_amountOfDamage", "_killer", "_projectile", "_hitPartIndex", "_instigator"];

if (isNull _unit) exitWith {};
if (!alive _unit) exitWith {};

if (!isNull _instigator) then {
	if (isNull (getAssignedCuratorLogic _instigator)) then {
	   	_killer = _instigator;
	};
} else {
	if (!(_killer isKindOf "CAManBase")) then {
		_killer = effectiveCommander _killer;
	};
};

if (_unit isKindOf "AllVehicles") then {
	if (isPlayer _killer) then {
		_unit setVariable ["GRLIB_last_killer", _killer, true];
	};

	if (damage _unit >= 0.75) then {
		private _evac_in_progress = (_unit getVariable ["GRLIB_vehicle_evac", false]);
		if (!_evac_in_progress) then {
			_unit setVariable ["GRLIB_vehicle_evac", true];
			{ [_x, false] spawn F_ejectUnit} forEach (crew _unit);
		};
	};
};

private _ret = _amountOfDamage;

if (isPlayer _killer && _unit != _killer) then {
	private _veh_unit = vehicle _unit;
	private _veh_killer = vehicle _killer;
	// OpFor in vehicle
	if (_veh_unit != _unit && _veh_killer == _killer && round (_killer distance2D _unit) <= 2) then {
		if ( _unit getVariable ["GRLIB_isProtected", 0] < time ) then {
			private _msg = format ["%1 Stop Cheating !!", name _killer];
			[gamelogic, _msg] remoteExec ["globalChat", owner _killer];
			(group _unit) reveal _killer;
			(gunner _veh_unit) doTarget _killer;
			_veh_unit fireAtTarget [_killer];
			_unit setVariable ["GRLIB_isProtected", round(time + 3), true];
		};
		_ret = 0;
	};
};

_ret;
