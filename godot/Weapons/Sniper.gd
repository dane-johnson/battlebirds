extends Weapon

func _ready():
	$ReloadTimer.connect("timeout", self, "on_reload")

func fire():
	if reloading: return
	if ammo_in_clip > 0:
		$AnimationPlayer.play("Fire")
		ammo_in_clip = 0
		if ammo_in_reserve > 0:
			reloading = true
			$ReloadTimer.start()

func on_reload():
	reloading = false
	if ammo_in_reserve > 0:
		ammo_in_reserve -= 1
		ammo_in_clip = 1
