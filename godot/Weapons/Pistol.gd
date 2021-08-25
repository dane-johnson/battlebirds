extends Weapon

func _ready():
	ammo_in_clip = shots_per_clip
	ammo_in_reserve = max_ammo - shots_per_clip
	$ReloadTimer.connect("timeout", self, "on_reload_complete")

func fire():
	if reloading: return
	if ammo_in_clip > 0:
		$AnimationPlayer.stop()
		$AnimationPlayer.play("fire")
		rset_unreliable("ammo_in_clip", ammo_in_clip - 1)
	else:
		reload()

func rotate_flash():
	$MuzzleFlash.rotate_z(randf() * TAU)

func reload():
	if $ReloadTimer.is_stopped() and ammo_in_clip < shots_per_clip:
		reloading = true
		$ReloadTimer.start()
		$Sounds/ReloadSound.play()

func on_reload_complete():
	reloading = false
	rset_unreliable("ammo_in_clip", shots_per_clip)
