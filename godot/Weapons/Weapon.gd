extends Spatial

class_name Weapon

export(float) var damage = 1.0
export(float) var spread_angle = 0.01 * PI
export(bool) var unlimited_ammo = false
export(int) var max_ammo = 100
export(int) var shots_per_clip = 10
export(int) var crosshair_frame = 11

## For projectile weapons, should be one of the keys from WeaponManager.projectile_names
export(String) var projectile_name


mastersync var ammo_in_clip = 0
mastersync var ammo_in_reserve = 0
var reloading = false

signal fired
signal fired_projectile

func fire():
	## All weapons should implement `fire' (right?)
	push_error(self.name + " does not implement `fire()`!")

func unfire():
	pass

func reload():
	pass

remotesync func give_ammo(amount):
	amount = min(amount, max_ammo - ammo_in_clip - ammo_in_reserve)
	if ammo_in_clip == 0:
		var clip = min(amount, shots_per_clip)
		rset("ammo_in_clip", clip)
		rset("ammo_in_reserve", ammo_in_reserve + (amount - clip))
	else:
		rset("ammo_in_reserve", ammo_in_reserve + amount)

func signal_fired():
	emit_signal("fired", damage, spread_angle)

func signal_fired_projectile():
	emit_signal("fired_projectile", projectile_name)
