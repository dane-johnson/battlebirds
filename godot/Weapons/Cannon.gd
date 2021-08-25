extends Weapon

var active_flash

func _ready():
	active_flash = 0
	for i in range(1, 4):
		$MuzzleFlashes.get_child(i).hide()
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
		rotate_and_swap_flashes()
	else:
		unfire()

func reload():
	if $ReloadTimer.is_stopped() and ammo_in_clip < shots_per_clip:
		reloading = true
		$ReloadTimer.start()
		$ReloadSound.play()

func unfire():
	$AnimationPlayer.stop()
	$MuzzleFlashes.hide()

func on_reload_complete():
	reloading = false
	ammo_in_clip = shots_per_clip

func rotate_and_swap_flashes():
	$MuzzleFlashes.get_child(active_flash).hide()
	active_flash = (active_flash + 1) % 4
	$MuzzleFlashes.get_child(active_flash).rotate_z(randf() * TAU)
	$MuzzleFlashes.get_child(active_flash).show()
