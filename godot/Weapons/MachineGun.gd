extends Weapon

func fire():
	if ammo_in_clip > 0:
		$AnimationPlayer.play("fire")

func on_shot():
	if ammo_in_clip > 1:
		ammo_in_clip -= 1
	else:
		ammo_in_clip = 0
		unfire()
	
func unfire():
	$AnimationPlayer.stop()
	$muzzleflash.hide()

func rotate_flash():
	$muzzleflash.rotate_z(randf() * TAU)
