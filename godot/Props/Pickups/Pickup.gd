class_name Pickup

extends Spatial

enum ammo_type {SOLDIER, BIRD}

tool

export(Color) var color = Color(1.0, 1.0, 1.0)
export(int) var weapon_number
export(int) var amount
export(ammo_type) var type = ammo_type.SOLDIER

onready var light = $SpotLight
onready var material = $Cube.get_active_material(0)

func _ready():
	$Area.connect("body_entered", self, "on_player_entered")
	$Timer.connect("timeout", self, "reactivate")

func _process(_delta):
	if is_inside_tree():
		light.light_color = color
		material.albedo_color = color

func on_player_entered(body):
	if Util.is_local(self) and body.will_accept_ammo(type, weapon_number):
		body.give_ammo(weapon_number, amount)
		rpc("on_collected")

remotesync func on_collected():
	hide()
	$Area.monitoring = false
	$Timer.start()

func reactivate():
	show()
	$Area.monitoring = true
