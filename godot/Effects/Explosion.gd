extends Spatial

const splash_damage = 150.0

func _ready():
	$Particles.emitting = true
	$DamageTimer.connect("timeout", self, "on_damage_timer")

func on_damage_timer():
	if is_network_master():
		do_damage()
	
func do_damage():
	for body in $BlastZone.get_overlapping_bodies():
		var health_manager = body.get_node_or_null("HealthManager")
		if health_manager:
			var com = body.get_node("CenterOfMass")
			var dist = transform.origin.distance_to(com.global_transform.origin)
			var amt = max(inverse_lerp(4.0, 0.0, dist), 0.0)
			health_manager.rpc("hurt", splash_damage * amt)
			body.rpc("impact", transform.origin.direction_to(com.global_transform.origin) * amt)
