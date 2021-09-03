extends KinematicBody

onready var movement_controller = $MovementController
onready var anim_tree = $AnimationTree
onready var weapon_manager = $Armature/Skeleton/HandSocket/SoldierWeaponManager
onready var health_manager = $HealthManager

var aiming
var look_direction : Basis
var was_falling
onready var player = get_parent()

func _ready():
	if not Util.is_local(self): return
	$AimTimer.connect("timeout", self, "unaim")

func _process(_delta):
	transform.basis = Util.level(look_direction)

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

	if Util.is_local(self):
		## Update script variables
		rpc_unreliable("sync_variables", aiming, was_falling, look_direction)

func _input(event):
	if not Util.is_local(self): return
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


master func impact(force):
	movement_controller.velocity += force * 100.0

remotesync func die():
	$CameraRemote.remote_path = ""
	$BodyCollision.queue_free()
	ragdoll()
	anim_tree.active = false
	var root = get_tree().get_root()
	get_parent().remove_child(self)
	root.add_child(self)

remotesync func disable():
	hide()
	$BodyCollision.disabled = true

remotesync func enable():
	show()
	$BodyCollision.disabled = false

func ragdoll():
	movement_controller.synchronized = false
	$Armature/Skeleton.physical_bones_start_simulation()

remote func sync_variables(aiming, was_falling, look_direction):
	self.aiming = aiming
	self.was_falling = was_falling
	self.look_direction = look_direction

func will_accept_ammo(ammo_type, weapon_number):
	return ammo_type == Pickup.ammo_type.SOLDIER and weapon_manager.weapon_can_accept_ammo(weapon_number)

func give_ammo(weapon_number, amount):
	weapon_manager.give_ammo(weapon_number, amount)
