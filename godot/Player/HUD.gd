extends Control

enum {
	SOLDIER, DEAD
}

var mode = DEAD

onready var crosshair = $Center/Crosshair
onready var counter = $Counter
onready var respawn_timer = $Center/RespawnTimer

func _ready():
	crosshair.hide()
	counter.hide()

func change_mode(new_mode):
	## Disable the old mode
	match mode:
		DEAD:
			respawn_timer.hide()
		SOLDIER:
			crosshair.hide()
			counter.hide()
	## Enable the new mode
	mode = new_mode
	match mode:
		DEAD:
			respawn_timer.show()
		SOLDIER:
			crosshair.show()
			counter.show()

func set_crosshair_frame(frame):
	crosshair.frame = frame

func update_respawn(time_left):
	respawn_timer.text = "Respawn\n%d" % time_left

func update_weapon(weapon):
	if weapon.reloading:
		counter.text = "Reloading..."
	else:
		var reserve = "∞" if weapon.unlimited_ammo else str(weapon.ammo_in_reserve)
		counter.text = "%s %d/%s" % [weapon.name, weapon.ammo_in_clip, reserve]
