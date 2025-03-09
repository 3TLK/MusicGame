extends RayCast3D
class_name GrappleComponent

@export var parent : CharacterBody3D

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
@onready var tape : Node3D = $Tape

func grappleLaunched() -> void:
	if is_colliding():
		grappledOn = get_collision_point()
		launched = true
		tape.visible = true

func grappleRetracted() -> void:
	launched = false
	tape.visible = false

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
	if Input.is_action_just_pressed("RMB"):
		grappleLaunched()
		
	if Input.is_action_just_released("RMB"):
		grappleRetracted()
	
	if launched:
		handleGrapple(delta, restLength, stiffness, damp, appliedMult)
		updateTape()

func updateTape() -> void:
	var distance : float = global_position.distance_to(grappledOn)
	tape.look_at(grappledOn)
	tape.scale = Vector3(1, 1, distance)
