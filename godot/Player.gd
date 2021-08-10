extends Spatial

onready var camera_rig = $CameraRig
onready var soldier = $Soldier

func _ready():
	soldier.get_node("CameraRemote").remote_path = camera_rig.get_path()
	soldier.camera_rig = camera_rig
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _process(_delta):
	## Polling Inputs
	var move_vec = Vector3.ZERO
	move_vec.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_vec.z = Input.get_action_strength("backwards") - Input.get_action_strength("forwards")
	soldier.movement_controller.move_vec = camera_rig.transform.basis.xform(move_vec)

func _input(event):
	if event is InputEventMouseMotion:
		var euler = Vector3(0, -event.relative.x * camera_rig.horiz_sensitivity, 0)
		camera_rig.tgt *= Quat(euler)
