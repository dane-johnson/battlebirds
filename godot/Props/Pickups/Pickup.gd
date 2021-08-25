extends Spatial

tool

export(Color) var color = Color(1.0, 1.0, 1.0)

onready var light = $SpotLight
onready var material = $Cube.get_active_material(0)

func _process(_delta):
	light.light_color = color
	material.albedo_color = color
