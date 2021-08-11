extends Spatial

onready var camera_rig = $CameraRig
onready var soldier = $Soldier

var id
var local = true

func _ready():
	if local:
		soldier.get_node("CameraRemote").remote_path = camera_rig.get_path()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		## TODO ADD a camera rig if we are local
		remove_child(camera_rig)
		camera_rig.queue_free()
	soldier.movement_controller.local = local
	
func _process(_delta):
	if not local: return
	## Polling Inputs
	var move_vec = Vector3.ZERO
	move_vec.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_vec.z = Input.get_action_strength("backwards") - Input.get_action_strength("forwards")
	soldier.movement_controller.move_vec = camera_rig.transform.basis.xform(move_vec)

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
		var euler = Vector3(0, -event.relative.x * camera_rig.horiz_sensitivity, 0)
		camera_rig.tgt *= Quat(euler)
