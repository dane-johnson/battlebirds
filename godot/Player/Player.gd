extends Spatial

var dirt_prefab = preload("res://Effects/DirtHit.tscn")

onready var camera_rig = $CameraRig
onready var soldier = $Soldier

var id
var local = true

var hitscans = []

func _ready():
	if local:
		soldier.get_node("CameraRemote").remote_path = camera_rig.get_path()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		## TODO ADD a camera rig if we are local
		remove_child(camera_rig)
		camera_rig.queue_free()
	soldier.movement_controller.local = local
	soldier.weapon_manager.connect("weapon_fired", self, "add_hitscan")
	
func _process(_delta):
	if not local: return
	## Polling Inputs
	var move_vec = Vector3.ZERO
	move_vec.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_vec.z = Input.get_action_strength("backwards") - Input.get_action_strength("forwards")
	soldier.movement_controller.move_vec = camera_rig.transform.basis.xform(move_vec)
	if soldier.aiming:
		if Input.is_action_just_pressed("fire"):
			soldier.weapon_manager.rpc("fire")
		if Input.is_action_just_released("fire"):
			soldier.weapon_manager.rpc("unfire")
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
			
func _physics_process(_delta):
	var space_state = get_world().direct_space_state
	for hitscan in hitscans:
		var camera = camera_rig.camera.global_transform
		var src = camera.origin
		var ray = Vector3.FORWARD * 1000
		ray = ray.rotated(Vector3.UP, randf() * hitscan["spread"])
		ray = ray.rotated(Vector3.FORWARD, randf() * TAU)
		ray = camera.xform(ray)
		var dest = src + ray
		var result = space_state.intersect_ray(src, dest, [soldier])
		if result.has("collider"):
			rpc("do_hit", hitscan, result)
	hitscans = []
		

func _input(event):
	if not local: return
	if event is InputEventMouseMotion:
		var euler = Vector3(-event.relative.y * camera_rig.vert_sensitivity, -event.relative.x * camera_rig.horiz_sensitivity, 0.0)
		camera_rig.add_to_tgt(euler)
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		match event.scancode:
			KEY_1:
				soldier.weapon_manager.rpc("set_active_weapon", 0)
			KEY_2:
				soldier.weapon_manager.rpc("set_active_weapon", 1)

func add_hitscan(damage, spread_angle):
	hitscans.append({"damage": damage, "spread": spread_angle})

remotesync func do_hit(hitscan, result):
	var dirt = dirt_prefab.instance()
	get_tree().get_root().add_child(dirt)
	dirt.transform.origin = result["position"]
	if result["normal"] != Vector3.FORWARD:
		dirt.look_at(result["normal"] + result["position"], Vector3.FORWARD)
