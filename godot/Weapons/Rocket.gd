extends KinematicBody

const explosion_prefab = preload("res://Effects/Explosion.tscn")

const speed = 20.0

func _physics_process(delta):
	var collision = move_and_collide(-transform.basis.z * speed * delta)
	if collision:
		var explosion = explosion_prefab.instance()
		get_tree().get_root().add_child(explosion)
		explosion.global_transform.origin = global_transform.origin
		var health_manager = collision["collider"].get_node_or_null("HealthManager")
		if health_manager and Util.is_local(self):
			health_manager.rpc("hurt", 250)
		queue_free()
