extends CharacterBody3D

@export_category("Components")
@export var healthComponent : HealthComponent
@export var hitboxComponent : HitboxComponent

@export_category("HUD")
@export var HUD : WalkmanHUD

@export_category("Camera Pivots")
@export var pivotY : Node3D
@export var pivotX : Node3D

@export_category("Character Movement")
@export var moveSpeed : float = 7
@export var accel : float = 5
@export var decel : float = 8
@export var jumpForce : float = 5
@export var gravity : float = 9.8

@export_category("Weapon Details")
@export var spreadRange : int = 3
@export var numberOfPellets : int = 5
@export var pelletDamage : int = 15
@export var shotgunCast : RayCast3D

@export_category("Grapple Details")
@export var restLength : float = 1.0
@export var stiffness : float = 5.0
@export var damp : float = 1.0
@export var grappleCast : RayCast3D
@export var tape : Node3D

@export_category("FastForward/Rewind & Press Play")
@export var bonusMult : float = 1.5
@export var reducedMult : float = 0.5
@export var normalMult : float = 1.0

#movement direction
var inputDirection : Vector2
var direction : Vector3

#toggle cursor trap
var cameraLock : int = -1

#fastforward rewind and play
var multStatus : int = 0
var appliedMult : float = 1.0

#grapple Misc
var launched : bool
var grappledOn : Vector3
var targetDirection : Vector3
var force : Vector3
var grappleForce : Vector3
var damping : Vector3
var velocityDot : float
var targetDistance : float
var displacement : float
var grappleForceMagnitude : float

#shotgun spread
var yaw : int
var pitch : int
var randomSpread : Vector3

#Handling Camera movement
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && cameraLock == 1:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif Input.is_action_just_pressed("Escape"):
		cameraLock *= -1
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			pivotY.rotate_y(-event.relative.x * 0.01)
			pivotX.rotate_x(-event.relative.y * 0.01)
			pivotX.rotation.x = clamp(pivotX.rotation.x, deg_to_rad(-80), deg_to_rad(80))

#handles the grapple hook
func grappleLaunched() -> void:
	if grappleCast.is_colliding():
		grappledOn = grappleCast.get_collision_point()
		launched = true

#handles the grapple hook
func grappleRetracted() -> void:
	launched = false

#handles the grapple hook
func handleGrapple(delta : float) -> void:
	targetDirection = global_position.direction_to(grappledOn)
	targetDistance = global_position.distance_to(grappledOn)
	
	displacement = targetDistance - restLength
	
	if displacement > 0:
		grappleForceMagnitude = stiffness * displacement
		grappleForce = targetDirection * grappleForceMagnitude
		
		velocityDot = velocity.dot(targetDirection)
		damping = -damp * velocityDot * targetDirection
		
		force = grappleForce + damping
	
	velocity += force * delta

#handles the grapple hook
func tapeGrapple(delta) -> void:
	if Input.is_action_just_pressed("RMB"):
		grappleLaunched()
		
	if Input.is_action_just_released("RMB"):
		grappleRetracted()
	
	if launched:
		handleGrapple(delta)
	
	updateTape()

#this handles the tape
func updateTape() -> void:
	if !launched:
		tape.visible = false
		return
	
	tape.visible = true
	var distance : float = global_position.distance_to(grappledOn)
	tape.look_at(grappledOn)
	tape.scale = Vector3(1, 1, distance)

#handles the speedup, slowdown
func fastForwardRewind() -> void:
	if Input.is_action_just_pressed("Shift"):
		match multStatus:
			0:
				multStatus = 1
				appliedMult = bonusMult
			1:
				multStatus = 0
				appliedMult = reducedMult

#handles changing the speed back to normal
func pressPlay() -> void:
	if !HUD.pressPlayOnCooldown:
		if Input.is_action_just_pressed("R"):
			HUD.startPressPlayCooldown(8.0)
			HUD.pressPlayProgressBar.visible = true
			HUD.pressPlayProgressBar.value = 0
			multStatus = 0
			appliedMult = normalMult
	if HUD.pressPlayProgressBar.value >= 100.0:
		HUD.pressPlayProgressBar.visible = false
	elif HUD.pressPlayOnCooldown:
		HUD.pressPlayProgressBar.value = ((8.1 - HUD.pressPlayCooldownTimer.time_left) / 8.0) * 100

#handles all speedup functions
func speedManager() -> void:
	fastForwardRewind()
	pressPlay()

#handles shotgun shooting
func shotgunShoot() -> void:
	#handles shotgun shooting
	if Input.is_action_just_pressed("LMB"):
		for i in range(numberOfPellets):
			pitch = randi_range(-spreadRange, spreadRange)
			yaw = randi_range(-spreadRange, spreadRange)
			randomSpread = Vector3(pitch, yaw, 0)
			shotgunCast.rotation_degrees = randomSpread
			shotgunCast.force_raycast_update()

#Handling player Movement
func characterMove(delta: float) -> void:
	if is_on_floor():
		decel = 8.0
		if Input.is_action_just_pressed("Space"):
			velocity.y = jumpForce * appliedMult
	else:
		decel = 0.5
		velocity.y -= gravity * delta
	
	inputDirection = Input.get_vector("A", "D", "W", "S")
	direction = (pivotY.transform.basis * Vector3(inputDirection.x, 0, inputDirection.y)).normalized()
	if inputDirection.length() != 0:
		velocity.x = lerpf(velocity.x, direction.x * (moveSpeed * appliedMult), accel * delta)
		velocity.z = lerpf(velocity.z, direction.z * (moveSpeed * appliedMult), accel * delta)
	else:
		velocity.x = lerpf(velocity.x, 0.0, decel * delta)
		velocity.z = lerpf(velocity.z, 0.0, decel * delta)
	
	move_and_slide()

#runs all the scripts
func _physics_process(delta: float) -> void:
	characterMove(delta)
	shotgunShoot()
	tapeGrapple(delta)
	speedManager()
