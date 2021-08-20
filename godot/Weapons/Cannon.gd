extends Weapon

func fire():
	$AnimationPlayer.play("Firing")

func unfire():
	$AnimationPlayer.stop()
