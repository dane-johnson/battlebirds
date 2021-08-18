extends MovementController

func run_physics(delta):
	if body.flight_mode == "empty":
		if velocity.length_squared() < 0.25:
			velocity = Vector3.ZERO
		velocity = body.move_and_slide(velocity + gravity * delta, Vector3.UP)
	if body.flight_mode == "hover":
		body.move_and_slide(move_vec * move_accel, Vector3.UP)

func do_sync():
	rpc_unreliable("sync_movement", body.transform)

remote func sync_movement(transform):
	body.transform.basis = transform.basis
	if not last_pos:
		body.transform.origin = transform.origin
	last_pos = transform.origin
	
