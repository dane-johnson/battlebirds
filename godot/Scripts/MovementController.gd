extends Node

class_name MovementController

export(NodePath) var body_node
onready var body: KinematicBody = get_node(body_node)

export(float) var move_accel = 1.0
export(float) var jump_power = 10.0
export(float) var max_speed = 10.0

export(float) var lerp_speed = 30.0

var local = true

## Set by this script
var velocity = Vector3.ZERO
var on_ground = false
## Set by parent script
var jump = false
var move_vec = Vector3.ZERO

var last_pos

const gravity = ProjectSettings["physics/3d/default_gravity"] * Vector3.DOWN
const dampening = ProjectSettings["physics/3d/default_linear_damp"]

func _physics_process(delta):
	if not local:
		if last_pos:
			body.transform.origin = lerp(body.transform.origin, last_pos, delta * lerp_speed)
		return
	
	var snap
	if on_ground:
		snap = Vector3.DOWN * 2.0
	else:
		snap = Vector3.ZERO
	if jump:
		if on_ground:
			velocity.y += jump_power
			snap = Vector3.ZERO
		jump = false

	var flat_vel = Vector2(velocity.x, velocity.z)

	if move_vec.length_squared() > 0.25:
		flat_vel += Vector2(move_vec.x, move_vec.z) * move_accel
	else:
		flat_vel -= flat_vel.normalized() * move_accel
	if flat_vel.length_squared() > max_speed * max_speed:
		flat_vel = flat_vel.normalized() * max_speed;
	if abs(flat_vel.x) < 0.5:
		flat_vel.x = 0
	if abs(flat_vel.y) < 0.5:
		flat_vel.y = 0

	velocity.x = flat_vel.x
	velocity.z = flat_vel.y

	velocity = body.move_and_slide_with_snap(velocity + gravity * delta, snap, Vector3.UP, true)

	on_ground = body.is_on_floor()

func _process(_delta):
	if not local:
		return
	## Sync member variables
	rpc_unreliable("sync_movement", velocity, on_ground, jump, body.transform)

remote func sync_movement(velocity, on_ground, jump, transform):
	self.velocity = velocity
	self.on_ground = on_ground
	self.jump = jump
	body.transform.basis = transform.basis
	if not last_pos:
		body.transform.origin = transform.origin
	last_pos = transform.origin
