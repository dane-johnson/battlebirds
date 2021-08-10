extends Spatial

var tgt : Quat

const horiz_sensitivity = 1.0/100.0
const horiz_speed = 10.0

func _process(delta):
	var src = transform.basis.get_rotation_quat()
	var dest = src.slerp(tgt, delta * horiz_speed)
	transform.basis = Basis(dest)
