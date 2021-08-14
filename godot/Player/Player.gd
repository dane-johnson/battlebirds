extends Spatial

const soldier_prefab = preload("res://Characters/Soldier.tscn")

onready var camera_rig = $CameraRig
onready var respawn_timer = $RespawnTimer
onready var hud = $HUD

var local = true
var alive = false

var soldier
var weapon_manager
var active_weapon
var health_manager

func _ready():
	if local:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		respawn_timer.connect("timeout", self, "on_respawn")
		respawn_timer.start()
	else:
		remove_child(camera_rig)
		camera_rig.queue_free()
		hud.hide()

func _process(_delta):
	if not local: return
	## Update HUD
	if alive:
		hud.update_weapon(active_weapon)
		hud.update_health(health_manager)
	else:
		hud.update_respawn(int(ceil(respawn_timer.time_left)))

	## Update soldier stuff
	if not alive: return
	## Polling Inputs
	var move_vec = Vector3.ZERO
	move_vec.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_vec.z = Input.get_action_strength("backwards") - Input.get_action_strength("forwards")
	soldier.movement_controller.move_vec = camera_rig.transform.basis.xform(move_vec)
	if Input.is_action_just_pressed("fire"):
		weapon_manager.rpc("fire")
		soldier.start_aiming()
	if Input.is_action_just_released("fire"):
		weapon_manager.rpc("unfire")
		soldier.stop_aiming()
	## Rotation
	if soldier.aiming:
		soldier.look_direction = camera_rig.transform.basis
	else:
		var vel = soldier.movement_controller.velocity
		vel.y = 0
		if vel.length_squared() > 0.2:
			vel = vel.normalized()
			## Look in the direction of vel
			var phi = atan2(-vel.x, -vel.z)
			soldier.look_direction = Basis(Vector3.UP, phi)
			
func _input(event):
	if not local or not alive: return
	if event is InputEventMouseMotion:
		var euler = Vector3(-event.relative.y * camera_rig.vert_sensitivity, -event.relative.x * camera_rig.horiz_sensitivity, 0.0)
		camera_rig.add_to_tgt(euler)
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		match event.scancode:
			KEY_1:
				weapon_manager.rpc("set_active_weapon", 0)
			KEY_2:
				weapon_manager.rpc("set_active_weapon", 1)
			KEY_3:
				weapon_manager.rpc("set_active_weapon", 2)
			KEY_R:
				active_weapon.reload()
			KEY_P:
				die()
				
func on_respawn():
	PlayerManager.rpc("add_to_spawnlist", NetworkManager.id)

remotesync func spawn(spawn_point = Transform()):
	## Instance soldier
	soldier = soldier_prefab.instance()
	soldier.set_network_master(get_network_master())
	add_child(soldier)
	soldier.transform = spawn_point
	## Setup weapons
	weapon_manager = soldier.weapon_manager
	weapon_manager.camera_rig = camera_rig
	## Set correct look direction
	camera_rig.snap_to(soldier.transform.basis)
	weapon_manager.raycast_ignores.append(soldier)
	## Setup health
	health_manager = soldier.health_manager
	if local:
		health_manager.connect("dead", self, "die", [], CONNECT_ONESHOT)
	## Setup movement
	soldier.movement_controller.local = local


	hud.change_mode(hud.SOLDIER)
	if local:
		soldier.get_node("CameraRemote").remote_path = camera_rig.get_path()
		weapon_manager.connect("active_weapon_changed", self, "active_weapon_changed")
		active_weapon_changed(weapon_manager.weapons.get_child(0))

	alive = true

func die():
	soldier.rpc("die")
	alive = false
	respawn_timer.start()
	hud.change_mode(hud.DEAD)

func active_weapon_changed(weapon):
	active_weapon = weapon
	hud.set_crosshair_frame(weapon.crosshair_frame)
