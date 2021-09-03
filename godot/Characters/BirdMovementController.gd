extends MovementController

const jet_speed = 100.0

func run_physics(delta):
	if body.flight_mode == "empty":
		body.move_and_collide(gravity * jet_speed * delta * delta)
	if body.flight_mode == "hover":
		body.move_and_slide(move_vec * move_accel, Vector3.UP)
	if body.flight_mode == "jet":
		body.move_and_slide(-body.transform.basis.z * jet_speed, Vector3.UP)

func do_sync():
	rpc_unreliable("sync_movement", body.transform)

remote func sync_movement(transform):
	body.transform.basis = transform.basis
	if not last_pos:
		body.transform.origin = transform.origin
	last_pos = transform.origin
