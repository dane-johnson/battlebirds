extends MovementController

export(float) var jump_power = 10.0

var on_ground = false

var jump = false

func run_physics(delta):
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
	move_vec = Util.flat_vector(move_vec)
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

	velocity = body.move_and_slide_with_snap(velocity + gravity * delta, snap, Vector3.UP, true, 4, PI/4, false)

	on_ground = body.is_on_floor()

func do_sync():
	rpc_unreliable("sync_movement", velocity, on_ground, jump, body.transform)

remote func sync_movement(velocity, on_ground, jump, transform):
	self.velocity = velocity
	self.on_ground = on_ground
	self.jump = jump
	body.transform.basis = transform.basis
	if not last_pos:
		body.transform.origin = transform.origin
	last_pos = transform.origin
