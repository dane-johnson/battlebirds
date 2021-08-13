extends Spatial

onready var camera_rig = $CameraRig
onready var soldier = $Soldier
onready var hud = $HUD
onready var weapon_manager = soldier.weapon_manager

var id
var local = true

var active_weapon

func _ready():
	if local:
		soldier.get_node("CameraRemote").remote_path = camera_rig.get_path()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		weapon_manager.connect("active_weapon_changed", self, "active_weapon_changed")
		active_weapon_changed(weapon_manager.weapons.get_child(0))
	else:
		## TODO ADD a camera rig if we are local
		remove_child(camera_rig)
		camera_rig.queue_free()
		hud.hide()
	soldier.movement_controller.local = local
	weapon_manager.camera_rig = camera_rig
	weapon_manager.raycast_ignores.append(soldier)
	
func _process(_delta):
	if not local: return
	## Update HUD
	hud.update_counter(active_weapon)
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
	if not local: return
	if event is InputEventMouseMotion:
		var euler = Vector3(-event.relative.y * camera_rig.vert_sensitivity, -event.relative.x * camera_rig.horiz_sensitivity, 0.0)
		camera_rig.add_to_tgt(euler)
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		match event.scancode:
			KEY_1:
				weapon_manager.rpc("set_active_weapon", 0)
			KEY_2:
				weapon_manager.rpc("set_active_weapon", 1)

func active_weapon_changed(weapon):
	active_weapon = weapon
	hud.set_crosshair_frame(weapon.crosshair_frame)
