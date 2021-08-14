extends Spatial

var tgt : Vector3

onready var camera = $Camera

const horiz_sensitivity = 1.0/100.0
const vert_sensitivity = 1.0/100.0
const speed = 10.0

func _process(delta):
	var src = transform.basis.get_rotation_quat()
	var dest = src.slerp(Quat(tgt), delta * speed)
	transform.basis = Basis(dest)

func add_to_tgt(vec):
	tgt.y += vec.y
	tgt.x = clamp(tgt.x + vec.x, -PI/4, PI/4)

func snap_to(basis):
	tgt = basis.get_euler()
