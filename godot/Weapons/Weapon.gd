extends Spatial

class_name Weapon

export(float) var damage = 1.0
export(int) var max_ammo = 100
export(int) var shots_per_clip = 10
export(int) var crosshair_frame = 11

func fire():
	push_error(self.name + " does not implement `fire()`!")
	
func unfire():
	pass
