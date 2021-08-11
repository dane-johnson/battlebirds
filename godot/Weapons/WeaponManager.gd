extends Spatial

var active_weapon = 0

onready var weapons = $Weapons
onready var crosshair = $Centering/Crosshair

func _ready():
	set_active_weapon(0)
	if not NetworkManager.is_local(self):
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
