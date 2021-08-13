extends Weapon

func fire():
	if ammo_in_clip > 0:
		$AnimationPlayer.stop()
		$AnimationPlayer.play("fire")
		ammo_in_clip -= 1
	else:
		pass ## TODO reloading

func rotate_flash():
	$MuzzleFlash.rotate_z(randf() * TAU)
