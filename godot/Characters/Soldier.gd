extends KinematicBody

onready var movement_controller = $MovementController
onready var anim_tree = $AnimationTree

var aiming
var look_direction
var was_falling
var camera_rig
onready var player = get_parent()

func _process(_delta):
	if player.local:
		## Rotation
		if aiming:
			transform.basis = camera_rig.transform.basis
		else:
			## TODO change this, I hate this
			var vel = movement_controller.velocity
			vel.y = 0
			look_at(transform.origin + vel, Vector3.UP)

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
		rpc_unreliable("sync_variables", aiming, was_falling)

func _input(event):
	if not player.local: return
	if event is InputEventMouseButton:
		if event.button_index == 2:
			aiming = event.pressed
	if event is InputEventKey:
		if event.scancode == KEY_SPACE and event.pressed and not event.echo:
			movement_controller.jump = true
			if movement_controller.on_ground:
				anim_tree["parameters/Jumping/active"] = true

remote func sync_variables(aiming, was_falling):
	self.aiming = aiming
	self.was_falling = was_falling
