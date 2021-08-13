extends Spatial

signal active_weapon_changed

const dirt_prefab = preload("res://Effects/DirtHit.tscn")

const projectile_names = {
	"rocket": preload("res://Weapons/Rocket.tscn")
}

var active_weapon = 0

onready var weapons = $Weapons

var hitscans = []
var projectiles = []
var camera_rig
var raycast_ignores = []

func _ready():
	set_active_weapon(0)
	for weapon in weapons.get_children():
		weapon.connect("fired", self, "on_weapon_fired")
		weapon.connect("fired_projectile", self, "on_weapon_fired_projectile")

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

func on_weapon_fired_projectile(projectile_name):
	projectiles.append(projectile_name)
	
func _physics_process(_delta):
	if not is_network_master():
		return
	var camera = camera_rig.camera.global_transform
	var src = camera.origin - camera.basis.z * 3.0 ## Go out in front of the camera and player
	## Fire projectile weapons
	for projectile_name in projectiles:
		var projectile_transform = Transform()
		projectile_transform.basis = camera.basis
		projectile_transform.origin = src
		rpc("fire_projectile", projectile_name, projectile_transform)
	projectiles = []
	## Fire hitscan weapons
	var space_state = get_world().direct_space_state
	for hitscan in hitscans:
		var ray = Vector3.FORWARD * 1000
		ray = ray.rotated(Vector3.UP, randf() * hitscan["spread"])
		ray = ray.rotated(Vector3.FORWARD, randf() * TAU)
		ray = camera.xform(ray)
		var dest = src + ray
		var result = space_state.intersect_ray(src, dest, raycast_ignores)
		if result.has("collider"):
			rpc("do_hit", hitscan, result)
			var health_manager = result["collider"].get_node_or_null("HealthManager")
			if health_manager:
				health_manager.rpc("hurt", hitscan["damage"])

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

remotesync func fire_projectile(projectile_name, projectile_transform):
	var projectile = projectile_names[projectile_name].instance()
	get_tree().get_root().add_child(projectile)
	projectile.transform = projectile_transform
