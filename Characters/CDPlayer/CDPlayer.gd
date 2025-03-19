extends CharacterBody3D
class_name CDPlayer

@onready var laser : PackedScene = load("res://Characters/CDPlayer/Laser/laser.tscn")

@export_category("Components")
@export_subgroup("Components")
@export var healthComponent : HealthComponent
@export var hitboxComponent : HitboxComponent
@export var movementComponent : PlayerMovementComponent
@export var HUD : CDPlayerHUD
@export var FOV : FOVManager

@export_category("Camera")
@export var camera : Camera3D
@export_subgroup("Pivots")
@export var pivotY : Node3D
@export var pivotX : Node3D
@export_subgroup("FOV")
@export var FovNorm : float = 90
@export var FovHigh : float = 105
@export var FovLow : float = 75

@export_category("Character Movement")
@export_subgroup("Movement")
@export var moveSpeed : float = 5.0
@export var accel : float = 5.0
@export var decel : float = 8.0
@export_subgroup("Jumping")
@export var jumpForce : float = 5.0
@export var gravity : float = 9.8

@export_category("Saw")
@export_subgroup("Saw Timers")
@export var sawDuration : Timer
@export var sawTimer : Timer

@export_category("Laser Info")
@export_subgroup("Laser")
@export var laserSpawn : Node3D
@export_subgroup("Laser Ammo")
@export var laserAmmoMax : int = 50
@export var laserAmmo : int = 50
@export_subgroup("Laser Timers")
@export var reloadTimer : Timer
@export var reloadCooldown : Timer
@export var shootTimer : Timer

var passiveFloatStrength : float = 9.5
var activeFloatStrength : Vector3 = Vector3(28.0, 18.0, 28.0)

var defaultdecel : float = 8.0
var defaultaccel : float = 5.0

var inputDirection : Vector2
var direction : Vector3

var reloading : bool
var shootCooldownVar : bool = true
var laserBullet : RigidBody3D

var launchOnCooldown : bool

var sawOnCooldown : bool
var sawGoing : bool

var cameraLock : int = -1

#handles camera
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
			pivotX.rotation.x = clamp(pivotX.rotation.x, deg_to_rad(-60), deg_to_rad(60))

#handles passive
func passiveFloat(delta : float) -> void:
	if !is_on_floor():
		if Input.is_action_pressed("Space"):
			if velocity.y <= 0:
				velocity.y += passiveFloatStrength * delta

#handles HUD launch
func HUDLaunch():
	if launchOnCooldown:
		HUD.launchProgress.value = ((4.0 - $Timers/launchCooldown.time_left) / 4) * 100

#handles launch cooldown
func launchCooldown():
	HUD.launchProgress.visible = false
	launchOnCooldown = false
	HUD.launchProgress.value = 0

#handles launch
func launch() -> void:
	HUDLaunch()
	if Input.is_action_just_pressed("Shift") && !launchOnCooldown:
		$"Timers/launchCooldown".start()
		launchOnCooldown = true
		HUD.launchProgress.visible = true
		velocity = (-pivotX.global_transform.basis.z * activeFloatStrength)

#handles shoot cooldown
func shootCooldown() -> void:
	shootCooldownVar = true

#handles starting reloading
func startReload():
	reloading = true
	reloadTimer.start()

#handles the hud for reloading
func HUDReload():
	if reloading:
		HUD.ammoProgress.value = ((0.5 - reloadTimer.time_left) / 0.5) * 100
		HUD.ammoLabel.text = str(floori(((0.5 - reloadTimer.time_left) / 0.5) * 50))

#handles shooting
func shootLaser() -> void:
	HUDReload()
	if Input.is_action_pressed("LMB") && shootCooldownVar && !reloading && laserAmmo > 0:
		reloadCooldown.start()
		laserAmmo -= 1
		HUD.updateAmmoDisplay(laserAmmo)
		shootTimer.start()
		shootCooldownVar = false
		laserBullet = laser.instantiate()
		add_sibling(laserBullet)
		laserBullet.rotation = pivotX.global_rotation
		laserBullet.global_position = laserSpawn.global_position

#handles reloading
func reloadLasers() -> void:
	laserAmmo = laserAmmoMax
	HUD.updateAmmoDisplay(laserAmmo)
	reloading = false

#handles HUD saw
func HUDsaw():
	if sawOnCooldown:
		HUD.sawProgress.value = ((6.0 - sawTimer.time_left) / 6.0) * 100
	if sawGoing:
		HUD.sawProgress.value = (sawDuration.time_left / 2) * 100

#handles saw on cooldown
func sawCooldown():
	sawOnCooldown = false
	HUD.sawProgress.visible = false
	HUD.sawProgress.value = 0

#handles saw effect ending
func sawEnded():
	sawOnCooldown = true
	sawGoing = false
	sawTimer.start()

#handles saw ability
func saw():
	HUDsaw()
	if Input.is_action_just_pressed("R") && !sawOnCooldown && !sawGoing:
		HUD.sawProgress.visible = true
		sawGoing = true
		sawDuration.start()
	if sawDuration.time_left > 0:
		velocity = -pivotX.global_transform.basis.z * 15

#handles moving
func characterMove(delta: float) -> void:
	movementComponent.characterMove(delta, moveSpeed, jumpForce)

#handles function
func _physics_process(delta: float) -> void:
	characterMove(delta)
	passiveFloat(delta)
	shootLaser()
	launch()
	saw()
