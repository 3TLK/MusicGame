extends CharacterBody3D

@export_category("Components")
@export var healthComponent : HealthComponent
@export var hitboxComponent : HitboxComponent

@export_category("Camera Pivots")
@export var pivotY : Node3D
@export var pivotX : Node3D

@export_category("Character Movement")
@export var moveSpeed : float = 5.0
@export var accel : float = 5.0
@export var decel : float = 8.0
@export var jumpForce : float = 5.0
@export var gravity : float = 9.8

var defaultdecel : float = 8.0
var defaultaccel : float = 5.0

var inputDirection : Vector2
var direction : Vector3

var cameraLock : int = -1

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

func characterMove(delta: float) -> void:
	
	if is_on_floor():
		if Input.is_action_just_pressed("Space"):
			velocity.y = jumpForce
	else:
		velocity.y -= gravity * delta
	
	inputDirection = Input.get_vector("A", "D", "W", "S")
	direction = (pivotY.transform.basis * Vector3(inputDirection.x, 0, inputDirection.y)).normalized()
	if inputDirection.length() != 0:
		velocity.x = lerpf(velocity.x, direction.x * moveSpeed, accel * delta)
		velocity.z = lerpf(velocity.z, direction.z * moveSpeed, accel * delta)
	else:
		velocity.x = lerpf(velocity.x, 0.0, decel * delta)
		velocity.z = lerpf(velocity.z, 0.0, decel * delta)
	
	move_and_slide()

func _physics_process(delta: float) -> void:
	characterMove(delta)
