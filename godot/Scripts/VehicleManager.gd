extends Spatial

## The vehicle manager keeps vehicles as its children, and respawns them when they are destroyed
## It animates and controls vehicles that are not occupied

func player_can_enter(vehicle):
	if vehicle.exploded:
		return false
	for occupant in vehicle.seats.values():
		if !occupant:
			return true
	return false

remotesync func player_enters(player_name, vehicle_name):
	## TODO update this with multiple seat options
	var player = PlayerManager.get_player_by_name(player_name)
	var vehicle = get_node(vehicle_name)
	vehicle.seats["pilot"] = player
	player.vehicle = vehicle
	vehicle.enter()
	vehicle.set_network_master(player.get_network_master())

remotesync func player_exits(player_name, vehicle_name):
	var player = PlayerManager.get_player_by_name(player_name)
	var vehicle = get_node(vehicle_name)
	for seat in vehicle.seats.keys():
		if vehicle.seats[seat] == player:
			vehicle.seats[seat] = null
			break
	vehicle.exit()
	vehicle.set_network_master(get_network_master()) ## Should be 1
		
