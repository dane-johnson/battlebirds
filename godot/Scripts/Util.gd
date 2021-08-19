class_name Util

extends Object

static func is_local(node: Node) -> bool:
	return node.get_network_master() == NetworkManager.id

static func level(basis: Basis) -> Basis:
	var euler = basis.get_euler()
	euler.x = 0
	return Basis(euler).orthonormalized()

static func flat_vector(vec: Vector3):
	var proj = vec.project(Vector3.UP)
	return (vec - proj) * vec.length()
