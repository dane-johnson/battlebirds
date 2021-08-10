extends Node

class_name MovementController

export(NodePath) var body_node
onready var body: KinematicBody = get_node(body_node)

export(float) var move_speed = 1.0
export(float) var jump_power = 30.0

## Set by this script
var velocity = Vector3.ZERO
var on_ground = false
## Set by parent script
var jump = false
var move_vec = Vector3.ZERO

const gravity = ProjectSettings["physics/3d/default_gravity"] * Vector3.DOWN
const dampening = ProjectSettings["physics/3d/default_linear_damp"]

func _physics_process(delta):
	if jump:
		if on_ground:
			move_vec.y = jump_power
		jump = false
	
	velocity = body.move_and_slide(velocity + gravity + move_vec * move_speed, Vector3.UP)
	if on_ground:
		velocity *= 0.9 ## Friction
	
	on_ground = body.is_on_floor()
