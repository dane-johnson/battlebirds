extends Weapon

func _ready():
	._ready() ## Call super
	$ReloadTimer.connect("timeout", self, "on_reload_complete")

func fire():
	if reloading: return
	if ammo_in_clip > 0:
		$AnimationPlayer.play("Firing")
	else:
		reload()

func on_shot():
	if ammo_in_clip > 0:
		ammo_in_clip -= 1
	else:
		unfire()

func reload():
	if $ReloadTimer.is_stopped() and ammo_in_clip < shots_per_clip:
		reloading = true
		$ReloadTimer.start()
		$ReloadSound.play()

func unfire():
	$AnimationPlayer.stop()

func on_reload_complete():
	reloading = false
	ammo_in_clip = shots_per_clip
