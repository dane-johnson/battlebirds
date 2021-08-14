extends Spatial

var levels = {"Demo": preload("res://Demo/Demo.tscn")}
var level = null

func load(levelname):
	if level:
		remove_child(level)
		level.queue_free()
	level = levels[levelname].instance()
	add_child(level)

func get_safe_spawns():
	var spawn_points = level.get_node_or_null("SpawnPoints")
	if not spawn_points:
		return []
	var safe_spawns = []
	for spawn_point in spawn_points.get_children():
		if len(spawn_point.get_overlapping_bodies()) == 0:
			safe_spawns.append(spawn_point.global_transform)
	return safe_spawns
