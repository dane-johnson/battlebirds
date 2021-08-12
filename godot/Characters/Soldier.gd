extends KinematicBody

onready var movement_controller = $MovementController
onready var anim_tree = $AnimationTree
onready var weapon_manager = $Skeleton2/Skeleton/RightHand/WeaponManager

var aiming
var look_direction : Basis
var was_falling
onready var player = get_parent()

func _ready():
	if not player.local: return
	$AimTimer.connect("timeout", self, "unaim")

func _process(_delta):
	
	transform.basis = look_direction

	## Animation updates
	var rel_velocity = transform.basis.xform_inv(movement_controller.velocity)
	anim_tree["parameters/Movement/blend_position"].y = -rel_velocity.z
	anim_tree["parameters/Movement/blend_position"].x = rel_velocity.x
	var aim_amount = 1 if aiming else 0
	anim_tree["parameters/Aiming/blend_amount"] = aim_amount
	var fall_amount = 0 if movement_controller.on_ground else 1
	anim_tree["parameters/Falling/blend_amount"] = fall_amount
	if movement_controller.on_ground and was_falling:
		anim_tree["parameters/Landing/active"] = true
	was_falling = not movement_controller.on_ground

	if player.local:
		## Update script variables
		rpc_unreliable("sync_variables", aiming, was_falling, look_direction)

func _input(event):
	if not player.local: return
	if event is InputEventKey:
		if event.scancode == KEY_SPACE and event.pressed and not event.echo:
			movement_controller.jump = true
			if movement_controller.on_ground:
				anim_tree["parameters/Jumping/active"] = true

func start_aiming():
	aiming = true
	$AimTimer.stop()

func stop_aiming():
	$AimTimer.start()

func unaim():
	aiming = false
		

remote func sync_variables(aiming, was_falling, look_direction):
	self.aiming = aiming
	self.was_falling = was_falling
	self.look_direction = look_direction
