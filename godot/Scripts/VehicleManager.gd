extends Spatial

## The vehicle manager keeps vehicles as its children, and respawns them when they are destroyed
## It animates and controls vechicles that are not occupied

func player_can_enter(vehicle):
	for occupant in vehicle.seats.values():
		if !occupant:
			return true
	return false

func player_enters(player, vehicle):
	## TODO update this with multiple seat options
	vehicle.seats["pilot"] = player
	player.vehicle = vehicle
	vehicle.enter()
