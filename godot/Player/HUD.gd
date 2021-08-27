extends Control

enum {
	SOLDIER, DEAD
}

var mode = DEAD

var lock_on_tgt

onready var crosshair = $Center/Crosshair
onready var ammo_counter = $AmmoCounter
onready var health_counter = $HealthCounter
onready var respawn_timer = $Center/RespawnTimer
onready var lock_on = $LockOn

func _ready():
	crosshair.hide()
	ammo_counter.hide()
	health_counter.hide()

func _process(_delta):
	if lock_on_tgt:
		lock_on.position = get_parent().camera_rig.camera.unproject_position(lock_on_tgt.transform.origin)

func change_mode(new_mode):
	## Disable the old mode
	match mode:
		DEAD:
			respawn_timer.hide()
		SOLDIER:
			crosshair.hide()
			ammo_counter.hide()
			health_counter.hide()
	## Enable the new mode
	mode = new_mode
	match mode:
		DEAD:
			respawn_timer.show()
		SOLDIER:
			crosshair.show()
			ammo_counter.show()
			health_counter.show()

func set_crosshair_frame(frame):
	crosshair.frame = frame

func update_respawn(time_left):
	if time_left == 0:
		respawn_timer.text = "Waiting for a safe spawn..."
	else:
		respawn_timer.text = "Respawn\n%d" % time_left

func update_health(health_manager):
	health_counter.text = "Health: %d/%d" % [health_manager.current_health, health_manager.max_health]

func update_weapon(weapon):
	if weapon.reloading:
		ammo_counter.text = "Reloading..."
	else:
		var reserve = "∞" if weapon.unlimited_ammo else str(weapon.ammo_in_reserve)
		ammo_counter.text = "%s %d/%s" % [weapon.name, weapon.ammo_in_clip, reserve]
