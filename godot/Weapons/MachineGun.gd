extends Weapon

func _ready():
	$ReloadTimer.connect("timeout", self, "on_reload_complete")

func fire():
	if reloading: return
	if ammo_in_clip > 0:
		$AnimationPlayer.play("fire")
	elif ammo_in_reserve > 0:
		reload()

func on_shot():
	if ammo_in_clip > 1:
		ammo_in_clip -= 1
	elif ammo_in_clip == 1:
		ammo_in_clip = 0
	else:
		unfire()

func reload():
	if $ReloadTimer.is_stopped() and ammo_in_clip < shots_per_clip:
		reloading = true
		$ReloadTimer.start()
		$ReloadSound.play()

func unfire():
	$AnimationPlayer.stop()
	$muzzleflash.hide()

func rotate_flash():
	$muzzleflash.rotate_z(randf() * TAU)

func on_reload_complete():
	reloading = false
	var bullets_required = shots_per_clip - ammo_in_clip
	var bullets = min(bullets_required, ammo_in_reserve)
	ammo_in_clip += bullets
	ammo_in_reserve -= bullets
