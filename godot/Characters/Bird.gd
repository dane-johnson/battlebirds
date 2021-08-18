extends KinematicBody

onready var movement_controller = $MovementController
onready var spawn_transform = global_transform

var flight_mode = "empty"
var seats = {"pilot": null}

func _ready():
	## Change parent to the vehicle manager
	call_deferred("reparent_to_vehicle_manager")

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
