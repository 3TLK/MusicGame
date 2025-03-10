extends CharacterBody3D
class_name Walkman

@export_category("Components")
@export var healthComponent : HealthComponent
@export var hitboxComponent : HitboxComponent
@export var grappleComponent : GrappleComponent
@export var movementComponent : PlayerMovementComponent

@export_category("HUD")
@export var HUD : WalkmanHUD

@export_category("Camera Pivots")
@export var pivotY : Node3D
@export var pivotX : Node3D
@export var camera : Camera3D

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
@export var shotgunForce : int = 10
@export var shotgunCast : RayCast3D

@export_category("Grapple Details")
@export var restLength : float = 1.0
@export var stiffness : float = 5.0
@export var damp : float = 1.0

@export_category("FastForward/Rewind & Press Play")
@export var bonusMult : float = 1.5
@export var reducedMult : float = 0.5
@export var normalMult : float = 1.0

#movement direction
var inputDirection : Vector2
var direction : Vector3

#acceleration defaults
var defaultaccel : float = 5
var defaultdecel : float = 8

#toggle cursor trap
var cameraLock : int = -1

#fastforward rewind and play
var multStatus : int = 0
var appliedMult : float = 1.0

#shotgun spread
var yaw : int
var pitch : int
var randomSpread : Vector3

#shotgun knockback
var shotgunShootDirection : Vector3
var shotgunJump : bool

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

#handles grapple hook
func grappleManager(delta : float) -> void:
	grappleComponent.tapeGrapple(delta, restLength, stiffness, damp, appliedMult)
	HUD.grappleIsColliding()

#handles the speedup, slowdown
func fastForwardRewind() -> void:
	if Input.is_action_just_pressed("Shift"):
		match multStatus:
			0:
				multStatus = 1
				camera.fov = 90.0
				appliedMult = bonusMult
			1:
				multStatus = 0
				camera.fov = 60.0
				appliedMult = reducedMult

#handles changing the speed back to normal
func pressPlay() -> void:
	if !HUD.pressPlayOnCooldown:
		if Input.is_action_just_pressed("R"):
			HUD.startPressPlayCooldown(8.0)
			HUD.pressPlayProgressBar.visible = true
			HUD.pressPlayProgressBar.value = 0
			camera.fov = 75
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
	if is_on_floor():
		shotgunJump = true
	if Input.is_action_just_pressed("LMB"):
		shotgunKnockback()
		for i in range(numberOfPellets):
			pitch = randi_range(-spreadRange, spreadRange)
			yaw = randi_range(-spreadRange, spreadRange)
			randomSpread = Vector3(pitch, yaw, 0)
			shotgunCast.rotation_degrees = randomSpread
			shotgunCast.force_raycast_update()

#handles shotgun knockback
func shotgunKnockback() -> void:
	if !is_on_floor() && shotgunJump:
		shotgunJump = false
		shotgunShootDirection = pivotX.global_transform.basis.z
		velocity = Vector3(velocity.x, 0, velocity.z)
		velocity += shotgunShootDirection * (shotgunForce * appliedMult)

#handles player movement
func characterMove(delta: float) -> void:
	movementComponent.characterMove(delta, moveSpeed * appliedMult, jumpForce * appliedMult)

#runs all the scripts
func _physics_process(delta: float) -> void:
	shotgunShoot()
	grappleManager(delta)
	speedManager()
	characterMove(delta)
