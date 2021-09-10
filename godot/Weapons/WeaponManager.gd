extends Spatial

signal active_weapon_changed
signal lock_on_tgt

const dirt_prefab = preload("res://Effects/DirtHit.tscn")
const decal_prefab = preload("res://Effects/BulletDecal.tscn")

const projectile_names = {
	"rocket": preload("res://Weapons/Rocket.tscn")
}

export(float) var out_front = 3.0

var active_weapon = 0

onready var weapons = $Weapons

var hitscans = []
var projectiles = []
var camera_rig
var raycast_ignores = []

var lock_on_tgt = null

func _ready():
	set_active_weapon(0)
	for weapon in weapons.get_children():
		weapon.connect("fired", self, "on_weapon_fired")
		weapon.connect("fired_projectile", self, "on_weapon_fired_projectile")

remotesync func set_active_weapon(new_active_weapon):
	var prev = weapons.get_child(active_weapon)
	var next = weapons.get_child(new_active_weapon)
	if next.unlimited_ammo or next.ammo_in_reserve > 0 or next.ammo_in_clip > 0:
		prev.hide()
		next.show()
		active_weapon = new_active_weapon
		emit_signal("active_weapon_changed", next)

remotesync func fire():
	weapons.get_child(active_weapon).fire()

remotesync func unfire():
	weapons.get_child(active_weapon).unfire()

func on_weapon_fired(damage, spread_angle):
	if not is_network_master():
		return
	hitscans.append({"damage": damage, "spread": spread_angle})

func weapon_can_accept_ammo(weapon_number):
	var weapon = weapons.get_child(weapon_number)
	return not weapon.unlimited_ammo and weapon.ammo_in_reserve + weapon.ammo_in_clip < weapon.max_ammo

func give_ammo(weapon_number, amount):
	var weapon = weapons.get_child(weapon_number)
	weapon.rpc("give_ammo", amount)

func on_weapon_fired_projectile(projectile_name):
	projectiles.append(projectile_name)

func _process(_delta):
	if not Util.is_local(self):
		return
	var weapon = weapons.get_child(active_weapon)
	var new_lock_on_tgt = null
	if weapon.lock_on:
		for vehicle in VehicleManager.get_children():
			if vehicle.flight_mode != "empty" and vehicle != get_parent():
				var direction = camera_rig.camera.global_transform.origin.direction_to(vehicle.transform.origin)
				var angle = direction.dot(-camera_rig.camera.global_transform.basis.z)
				if direction.dot(-camera_rig.camera.global_transform.basis.z) > 0.95:
					new_lock_on_tgt = vehicle
					break
	if new_lock_on_tgt != lock_on_tgt:
		emit_signal("lock_on_tgt", new_lock_on_tgt)
		lock_on_tgt = new_lock_on_tgt


func _physics_process(_delta):
	if not is_network_master() or not camera_rig:
		return
	var camera = camera_rig.camera.global_transform
	var src = camera.origin - camera.basis.z * out_front ## Go out in front of the camera and player
	## Fire projectile weapons
	for projectile_name in projectiles:
		var projectile_transform = Transform()
		projectile_transform.basis = camera.basis
		projectile_transform.origin = src
		rpc("fire_projectile", projectile_name, projectile_transform, lock_on_tgt.name if lock_on_tgt else null)
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
	var decal = decal_prefab.instance()
	get_tree().get_root().add_child(decal)
	decal.transform = dirt.transform

remotesync func fire_projectile(projectile_name, projectile_transform, projectile_tgt):
	var projectile = projectile_names[projectile_name].instance()
	get_tree().get_root().add_child(projectile)
	projectile.transform = projectile_transform
	if projectile_tgt:
		var tgt = VehicleManager.get_node(projectile_tgt)
		projectile.tgt = tgt
