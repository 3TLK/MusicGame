extends CharacterBody3D

@export_category("Components")
@export var healthComponent : HealthComponent
@export var hitboxComponent : HitboxComponent

@export_category("Camera Pivots")
@export var pivotY : Node3D
@export var pivotX : Node3D

@export_category("Character Movement")
@export var moveSpeed : float = 7
@export var jumpForce : float = 5
@export var gravity : float = 9.8

@export_category("Weapon Details")
@export var spreadRange : int = 3
@export var numberOfPellets : int = 5
@export var rayCast : RayCast3D

var inputDirection : Vector2
var direction : Vector3

var cameraLock : int = -1

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
			pivotX.rotation.x = clamp(pivotX.rotation.x, deg_to_rad(-60), deg_to_rad(60))


#handles shotgun shooting and knockback
func shotgunShoot():
	#handles shotgun shooting
	if Input.is_action_just_pressed("LMB"):
		rayCast.enabled = true
		for i in range(numberOfPellets):
			pitch = randi_range(-spreadRange, spreadRange)
			yaw = randi_range(-spreadRange, spreadRange)
			randomSpread = Vector3(pitch, yaw, 0)
			rayCast.rotation_degrees = randomSpread
			rayCast.force_raycast_update()
		rayCast.enabled = false

#Handling player Movement
func characterMove(delta: float) -> void:
	if is_on_floor():
		if Input.is_action_just_pressed("Space"):
			velocity.y = jumpForce
	else:
		velocity.y -= gravity * delta
	
	inputDirection = Input.get_vector("A", "D", "W", "S")
	direction = (pivotY.transform.basis * Vector3(inputDirection.x, 0, inputDirection.y)).normalized()
	if direction:
		velocity.x = direction.x * moveSpeed
		velocity.z = direction.z * moveSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, 1)
		velocity.z = move_toward(velocity.z, 0, 1)
	
	move_and_slide()

func _physics_process(delta: float) -> void:
	characterMove(delta)
	shotgunShoot()
