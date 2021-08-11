extends Weapon

func fire():
	$AnimationPlayer.play("fire")
	
func unfire():
	$AnimationPlayer.stop()
	$muzzleflash.hide()

func rotate_flash():
	$muzzleflash.rotate_z(randf() * TAU)
