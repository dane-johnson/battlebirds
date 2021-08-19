extends KinematicBody

onready var movement_controller = $MovementController
onready var spawn_transform = global_transform

var flight_mode = "empty"
var seats = {"pilot": null}

var aiming = false
var look_direction = transform.basis

func _ready():
	## Change parent to the vehicle manager
	call_deferred("reparent_to_vehicle_manager")
	## This is nice, we can just place them in the map
	## No need for an extra node to track spawns

func _process(delta):
	transform.basis = Util.level(look_direction)
	if Util.is_local(self):
		rpc_unreliable("sync_variables", aiming, look_direction)

func reparent_to_vehicle_manager():
	get_parent().remove_child(self)
	VehicleManager.add_child(self)
	global_transform = spawn_transform

func takeoff():
	$AnimationPlayer.play("Takeoff")
	
func land():
	$AnimationPlayer.play_backwards("Takeoff")

func enter():
	flight_mode = "hover"

func exit():
	flight_mode = "empty"

func start_aiming():
	aiming = true

func stop_aiming():
	aiming = false

remote func sync_variables(aiming, look_direction):
	self.aiming = aiming
	self.look_direction = look_direction
