extends Spatial

class_name Weapon

export(float) var damage = 1.0
export(float) var spread_angle = 0.01 * PI
export(bool) var unlimited_ammo = false
export(int) var max_ammo = 100
export(int) var shots_per_clip = 10
export(int) var crosshair_frame = 11

signal fired

func fire():
	push_error(self.name + " does not implement `fire()`!")
	
func unfire():
	pass

func signal_fired():
	emit_signal("fired", damage, spread_angle)
