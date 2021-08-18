class_name Util

extends Object

static func is_local(node: Node) -> bool:
	return node.get_network_master() == NetworkManager.id
