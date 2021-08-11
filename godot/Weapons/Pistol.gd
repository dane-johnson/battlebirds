extends Weapon

func fire():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("fire")

func rotate_flash():
	$MuzzleFlash.rotate_z(randf() * TAU)
