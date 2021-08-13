extends KinematicBody

const explosion_prefab = preload("res://Effects/Explosion.tscn")

const speed = 20.0
var ignores = []

func _physics_process(delta):
	var collision = move_and_collide(-transform.basis.z * speed * delta)
	if collision:
		var should_explode = true
		for ignore in ignores:
			if ignore == collision.collider:
				should_explode = false
				break
		if should_explode:
			var explosion = explosion_prefab.instance()
			get_tree().get_root().add_child(explosion)
			explosion.global_transform.origin = global_transform.origin
			queue_free()
			
