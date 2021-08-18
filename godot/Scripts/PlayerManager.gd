extends Spatial

var spawn_list = []

master func add_to_spawnlist(peer_id):
	spawn_list.append(peer_id)

func _process(_delta):
	if len(spawn_list) == 0:
		return
	var safe_spawns = LevelSelector.get_safe_spawns()
	safe_spawns.shuffle()
	var safe_spawn = safe_spawns.pop_front()
	if safe_spawn:
		var peer_id = spawn_list.pop_front()
		spawn_id(safe_spawn, peer_id)

func get_player_by_name(name):
	return NetworkManager.get_node(name)

func get_player(peer_id):
	return NetworkManager.get_node("Player-" + str(peer_id))

func spawn_id(spawn_point, peer_id):
	get_player(peer_id).rpc("spawn", spawn_point)
