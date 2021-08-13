extends Spatial

signal active_weapon_changed

const dirt_prefab = preload("res://Effects/DirtHit.tscn")

var active_weapon = 0

onready var weapons = $Weapons

var hitscans = []
var camera_rig
var raycast_ignores = []

func _ready():
	set_active_weapon(0)
	for weapon in weapons.get_children():
		weapon.connect("fired", self, "on_weapon_fired")

remotesync func set_active_weapon(new_active_weapon):
	weapons.get_child(active_weapon).hide()
	weapons.get_child(new_active_weapon).show()
	active_weapon = new_active_weapon
	emit_signal("active_weapon_changed", weapons.get_child(new_active_weapon))

remotesync func fire():
	weapons.get_child(active_weapon).fire()

remotesync func unfire():
	weapons.get_child(active_weapon).unfire()

func on_weapon_fired(damage, spread_angle):
	if not is_network_master():
		return
	hitscans.append({"damage": damage, "spread": spread_angle})
	
func _physics_process(_delta):
	if not is_network_master():
		return
	var space_state = get_world().direct_space_state
	for hitscan in hitscans:
		var camera = camera_rig.camera.global_transform
		var src = camera.origin - camera.basis.z * 2.5 ## Go out in front of the camera
		var ray = Vector3.FORWARD * 1000
		ray = ray.rotated(Vector3.UP, randf() * hitscan["spread"])
		ray = ray.rotated(Vector3.FORWARD, randf() * TAU)
		ray = camera.xform(ray)
		var dest = src + ray
		var result = space_state.intersect_ray(src, dest, raycast_ignores)
		if result.has("collider"):
			rpc("do_hit", hitscan, result)
	hitscans = []

remotesync func do_hit(hitscan, result):
	var dirt = dirt_prefab.instance()
	get_tree().get_root().add_child(dirt)
	dirt.transform.origin = result["position"]
	if result["normal"] == Vector3.FORWARD:
		pass ## Already facing the right way
	elif result["normal"] == Vector3.BACK:
		dirt.rotate_x(PI) ## Turn totally around
	else:
		dirt.look_at(result["normal"] + result["position"], Vector3.FORWARD)
