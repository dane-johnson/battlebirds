extends Control

onready var crosshair = $Center/Crosshair
onready var counter = $Counter

func set_crosshair_frame(frame):
	crosshair.frame = frame

func update_weapon(weapon):
	if weapon.reloading:
		counter.text = "Reloading..."
	else:
		var reserve = "∞" if weapon.unlimited_ammo else str(weapon.ammo_in_reserve)
		counter.text = "%s %d/%s" % [weapon.name, weapon.ammo_in_clip, reserve]
