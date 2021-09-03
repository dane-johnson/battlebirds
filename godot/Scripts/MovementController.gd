class_name MovementController

extends Node

export(NodePath) var body_node
onready var body: KinematicBody = get_node(body_node)

export(float) var move_accel = 1.0
export(float) var max_speed = 10.0

export(float) var lerp_speed = 30.0

var synchronized = true

var move_vec = Vector3.ZERO

var velocity = Vector3.ZERO
var last_pos = null

const gravity = ProjectSettings["physics/3d/default_gravity"] * Vector3.DOWN
const dampening = ProjectSettings["physics/3d/default_linear_damp"]

func _physics_process(delta):
	if not Util.is_local(self):
		if last_pos:
			body.transform.origin = lerp(body.transform.origin, last_pos, delta * lerp_speed)
		return
	run_physics(delta)

func _process(_delta):
	if not Util.is_local(self):
		return
	## Sync member variables
	if synchronized:
		do_sync()

func run_physics(_delta):
	pass

func do_sync():
	pass
