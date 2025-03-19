extends RayCast3D
class_name GrappleComponent

@export var parent : CharacterBody3D
@export var HUD : WalkmanHUD

var launched : bool
var hooked : bool
var grappledOn : Vector3
var targetDirection : Vector3
var force : Vector3
var grappleForce : Vector3
var damping : Vector3
var velocityDot : float
var targetDistance : float
var displacement : float
var grappleForceMagnitude : float
var grappleCooldown : float = 1.5
@onready var tape : Node3D = $Tape
@onready var offset : Vector3 = Vector3(0.71, -0.3, 0.4)

func grappleLaunched() -> void:
	if is_colliding():
		grappledOn = get_collision_point()
		hooked = true
		launched = true
		tape.visible = true

func grappleRetracted() -> void:
	if hooked:
		HUD.startGrappleCooldown(grappleCooldown)
		HUD.grappleProgressbar.visible = true
		HUD.pressPlayProgressBar.value = 0
		launched = false
		tape.visible = false
		hooked = false

func handleGrapple(delta : float, restLength : float, stiffness : float, damp : float, appliedMult : float) -> void:
	targetDirection = parent.global_position.direction_to(grappledOn)
	targetDistance = parent.global_position.distance_to(grappledOn)
	
	displacement = targetDistance - restLength
	
	if displacement > 0:
		grappleForceMagnitude = (stiffness * appliedMult) * displacement
		grappleForce = targetDirection * grappleForceMagnitude
		
		velocityDot = parent.velocity.dot(targetDirection)
		damping = -damp * velocityDot * targetDirection
		
		force = grappleForce + damping
	
	parent.velocity += force * delta

func tapeGrapple(delta : float, restLength : float, stiffness : float, damp : float, appliedMult : float) -> void:
	if Input.is_action_just_pressed("RMB") && !HUD.grappleOnCooldown:
		grappleLaunched()
		
	if Input.is_action_just_released("RMB") && !HUD.grappleOnCooldown:
		grappleRetracted()

	if launched && !HUD.grappleOnCooldown:
		handleGrapple(delta, restLength, stiffness, damp, appliedMult)
		updateTape()
	elif HUD.grappleOnCooldown:
		if HUD.grappleProgressbar.value >= 100.0:
			HUD.grappleProgressbar.visible = false
		elif HUD.grappleOnCooldown:
			HUD.grappleProgressbar.value = ((grappleCooldown - HUD.grappleCooldownTimer.time_left) / grappleCooldown) * 100
	

func updateTape() -> void:
	var distance : float = (global_position).distance_to(grappledOn)
	tape.look_at(grappledOn)
	tape.scale = Vector3(1, 1, distance)
