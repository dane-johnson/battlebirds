extends Spatial

var levels = {"Demo": preload("res://Demo/Demo.tscn")}
var level = null

func load(levelname):
	if level:
		remove_child(level)
		level.queue_free()
	level = levels[levelname].instance()
	add_child(level)
