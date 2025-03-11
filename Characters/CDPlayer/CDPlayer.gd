extends CharacterBody3D
class_name CDPlayer

@onready var laser : PackedScene = load("res://Characters/CDPlayer/Laser/laser.tscn")

@export_category("Components")
@export var healthComponent : HealthComponent
@export var hitboxComponent : HitboxComponent
@export var movementComponent : PlayerMovementComponent
@export var HUD : CDPlayerHUD

@export_category("Camera Pivots")
@export var pivotY : Node3D
@export var pivotX : Node3D

@export_category("Character Movement")
@export var moveSpeed : float = 5.0
@export var accel : float = 5.0
@export var decel : float = 8.0
@export var jumpForce : float = 5.0
@export var gravity : float = 9.8

@export_category("Saw")
@export var sawDuration : Timer

@export_category("Laser Info")
@export var laserAmmoMax : int = 50
@export var laserAmmo : int = 50
@export var reloadTimer : Timer
@export var reloadCooldown : Timer
@export var laserSpawn : Node3D

var passiveFloatStrength : float = 9.5
var activeFloatStrength : Vector3 = Vector3(28.0, 18.0, 28.0)

var defaultdecel : float = 8.0
var defaultaccel : float = 5.0

var inputDirection : Vector2
var direction : Vector3

var reloading : bool
var shootCooldownVar : bool = true
var laserBullet : RigidBody3D

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

#handles launch
func activeFloat() -> void:
	if Input.is_action_just_pressed("Shift"):
		velocity = (-pivotX.global_transform.basis.z * activeFloatStrength)

#handles shoot cooldown
func shootCooldown() -> void:
	shootCooldownVar = true

#handles shooting
func shootLaser() -> void:
	if Input.is_action_pressed("LMB") && shootCooldownVar && !reloading && laserAmmo > 0:
		reloadCooldown.start()
		laserAmmo -= 1
		HUD.updateAmmoDisplay(laserAmmo)
		$shootCooldown.start()
		shootCooldownVar = false
		laserBullet = laser.instantiate()
		add_sibling(laserBullet)
		laserBullet.rotation = pivotX.global_rotation
		laserBullet.global_position = laserSpawn.global_position

func startReload():
	reloading = true
	reloadTimer.start()
	

#handles reloading
func reloadLasers() -> void:
	laserAmmo = laserAmmoMax
	HUD.updateAmmoDisplay(laserAmmo)
	reloading = false

func saw():
	if Input.is_action_just_pressed("R"):
		sawDuration.start()
	if sawDuration.time_left > 0:
		velocity = -pivotX.global_transform.basis.z * 15

#handles moving
func characterMove(delta: float) -> void:
	activeFloat()
	passiveFloat(delta)
	movementComponent.characterMove(delta, moveSpeed, jumpForce)

#handles function
func _physics_process(delta: float) -> void:
	characterMove(delta)
	saw()
	shootLaser()
