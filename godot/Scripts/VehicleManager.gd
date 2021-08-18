extends Spatial

## The vehicle manager keeps vehicles as its children, and respawns them when they are destroyed
## It animates and controls vehicles that are not occupied

func player_can_enter(vehicle):
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
