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

	soldier_physics(delta)
	
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

func soldier_physics(delta):
	## Falling and jumping
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

	## Input driven movement
	## Only concerned with xz axes
	var flat_vel = Vector3(velocity.x, 0, velocity.z)

	## Add move vec
	if move_vec.length_squared() > 0.25:
		flat_vel += move_vec * move_accel
		if flat_vel.length_squared() > max_speed * max_speed:
			flat_vel = flat_vel.normalized() * max_speed
	## If there is no movement we do deacceleration instead
	else:
		flat_vel -= flat_vel.normalized() * move_accel

	## If we're very close to stopping, just stop
	if abs(flat_vel.x) < 0.5:
		flat_vel.x = 0
	if abs(flat_vel.z) < 0.5:
		flat_vel.z = 0

	## Restore 3d velocity
	velocity.x = flat_vel.x
	velocity.z = flat_vel.z

	velocity = body.move_and_slide_with_snap(velocity + gravity * delta, snap, Vector3.UP, true)

	on_ground = body.is_on_floor()
