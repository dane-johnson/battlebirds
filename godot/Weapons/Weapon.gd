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


var ammo_in_clip = 0
var ammo_in_reserve = 0
var reloading = false

signal fired
signal fired_projectile

func _ready():
	ammo_in_clip = shots_per_clip
	ammo_in_reserve = max_ammo - shots_per_clip

func fire():
	## All weapons should implement `fire' (right?)
	push_error(self.name + " does not implement `fire()`!")

func unfire():
	pass

func reload():
	pass

func signal_fired():
	emit_signal("fired", damage, spread_angle)

func signal_fired_projectile():
	emit_signal("fired_projectile", projectile_name)
