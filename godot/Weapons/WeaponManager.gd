extends Spatial

var active_weapon = 0

onready var weapons = $Weapons
onready var crosshair = $Centering/Crosshair

signal weapon_fired

func _ready():
	set_active_weapon(0)
	for weapon in weapons.get_children():
		weapon.connect("fired", self, "on_weapon_fired")
	if not is_network_master():
		crosshair.hide()

remotesync func set_active_weapon(new_active_weapon):
	weapons.get_child(active_weapon).hide()
	weapons.get_child(new_active_weapon).show()
	crosshair.frame = weapons.get_child(new_active_weapon).crosshair_frame
	active_weapon = new_active_weapon

remotesync func fire():
	weapons.get_child(active_weapon).fire()

remotesync func unfire():
	weapons.get_child(active_weapon).unfire()

func on_weapon_fired(damage, spread_angle):
	if not is_network_master():
		return
	emit_signal("weapon_fired", damage, spread_angle)
