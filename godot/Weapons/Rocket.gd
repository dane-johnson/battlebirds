extends KinematicBody

const speed = 20.0

func _physics_process(delta):
	move_and_collide(-transform.basis.z * speed * delta)
