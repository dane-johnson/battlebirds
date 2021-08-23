extends MovementController

const jet_speed = 300.0

remotesync var look_direction

func _ready():
	._ready()
	look_direction = body.global_transform.basis


func run_physics(delta):
	if body.flight_mode == "empty":
		return
	var euler = body.transform.basis.get_euler()
	## Always roll towards level
	var roll_torque_strength = $RollPIDController.update(euler.z, delta)
	body.add_torque(body.transform.basis.z * roll_torque_strength)
	## Always yaw towards look direction
	$YawPIDController.setpoint = look_direction.get_euler().y
	var yaw_torque_strength = $YawPIDController.update(euler.y, delta)
	body.add_torque(body.transform.basis.y * yaw_torque_strength)

	if body.flight_mode == "hover":
		## Position
		var flat_vel = Vector3(velocity.x, 0, velocity.y)
		if flat_vel.length_squared() < 0.25:
			velocity.x = 0
			velocity.z = 0
		body.add_central_force(move_vec * move_accel)
		## Rotation
		$PitchPIDController.setpoint = 0
		var pitch_torque_strength = $PitchPIDController.update(euler.x, delta)
		body.add_torque(body.transform.basis.x * pitch_torque_strength)
	if body.flight_mode == "jet":
		## Position
		body.add_central_force(-body.transform.basis.z * jet_speed)
		$PitchPIDController.setpoint = look_direction.get_euler().x
		var pitch_torque_strength = $PitchPIDController.update(euler.x, delta)
		body.add_torque(body.transform.basis.x * pitch_torque_strength)

#	if body.flight_mode == "empty":
#		var flat_vel = Vector3(velocity.x, 0, velocity.y)
#		if flat_vel.length_squared() < 0.25:
#			velocity.x = 0
#			velocity.z = 0
#		velocity = body.move_and_slide(velocity + gravity * delta, Vector3.UP)
#	if body.flight_mode == "hover":
#		body.move_and_slide(move_vec * move_accel, Vector3.UP)
#	if body.flight_mode == "jet":
#		body.move_and_slide(-body.transform.basis.z * jet_speed, Vector3.UP)

func do_sync():
	rpc_unreliable("sync_movement", body.transform)

remote func sync_movement(transform):
	body.transform.basis = transform.basis
	if not last_pos:
		body.transform.origin = transform.origin
	last_pos = transform.origin
