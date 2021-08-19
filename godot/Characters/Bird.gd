extends KinematicBody

onready var movement_controller = $MovementController
onready var health_manager = $HealthManager
onready var spawn_transform = global_transform
onready var look_direction = spawn_transform.basis

var flight_mode = "empty"
var seats = {"pilot": null}

var aiming = false
var exploded = false

func _ready():
	health_manager.connect("dead", self, "on_dead")
	## Change parent to the vehicle manager
	call_deferred("reparent_to_vehicle_manager")
	## This is nice, we can just place them in the map
	## No need for an extra node to track spawns

func _process(delta):
	if flight_mode == "jet":
		transform.basis = look_direction
	else:
		transform.basis = Util.level(look_direction)
	if Util.is_local(self):
		rpc_unreliable("sync_variables", aiming, look_direction)

func reparent_to_vehicle_manager():
	get_parent().remove_child(self)
	VehicleManager.add_child(self)
	global_transform = spawn_transform

remotesync func takeoff():
	$AnimationPlayer.play("Takeoff")
	
remotesync func land():
	$AnimationPlayer.play_backwards("Takeoff")

func enter():
	flight_mode = "hover"

func exit():
	flight_mode = "empty"

func start_aiming():
	aiming = true

func stop_aiming():
	aiming = false
	
func toggle_flight_mode():
	if flight_mode == "hover":
		rpc("takeoff")
		flight_mode = "jet"
	elif flight_mode == "jet":
		rpc("land")
		flight_mode = "hover"
		
remote func sync_variables(aiming, look_direction):
	self.aiming = aiming
	self.look_direction = look_direction
	
func on_dead():
	rpc("die")
	
remotesync func die():
	exploded = true
	$Fire.emitting = true
