extends KinematicBody

onready var movement_controller = $MovementController
onready var health_manager = $HealthManager
onready var weapon_manager = $WeaponManager
onready var spawn_transform = global_transform

remotesync var look_direction
remotesync var flight_mode = "empty"
var seats = {"pilot": null}

remotesync var aiming = false
var exploded = false

func _ready():
	look_direction = spawn_transform.basis
	health_manager.connect("dead", self, "on_dead")
	$RespawnTimer.connect("timeout", self, "on_respawn")
	## Change parent to the vehicle manager
	call_deferred("reparent_to_vehicle_manager")
	## This is nice, we can just place them in the map
	## No need for an extra node to track spawns

func _process(delta):
	if flight_mode == "jet":
		transform.basis = look_direction
	else:
		transform.basis = Util.level(look_direction)

func reparent_to_vehicle_manager():
	get_parent().remove_child(self)
	VehicleManager.add_child(self)
	global_transform = spawn_transform

remotesync func takeoff():
	$AnimationPlayer.play("Takeoff")

remotesync func land():
	$AnimationPlayer.play_backwards("Takeoff")

func enter():
	rset("flight_mode", "hover")

func exit():
	rset("flight_mode", "empty")

func start_aiming():
	rset("aiming", true)

func stop_aiming():
	rset("aiming", false)

func toggle_flight_mode():
	if flight_mode == "hover":
		rpc("takeoff")
		rset("flight_mode", "jet")
	elif flight_mode == "jet":
		rpc("land")
		rset("flight_mode", "hover")

func on_respawn():
	exploded = false
	$Fire.emitting = false
	$Fire.hide()
	transform = spawn_transform
	health_manager.revive()

func on_dead():
	rpc("die")

remotesync func die():
	exploded = true
	$Fire.emitting = true
	$Fire.show()
	$RespawnTimer.start()
