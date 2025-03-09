extends Node
class_name PlayerMovementComponent

@export var parent : CharacterBody3D

var inputDirection : Vector2
var direction : Vector3

func characterMove(delta : float, moveSpeed : float, jumpForce : float) -> void:
	if parent.is_on_floor():
		parent.decel = parent.defaultdecel
		if Input.is_action_just_pressed("Space"):
			parent.velocity.y = jumpForce
	else:
		parent.decel = 0.5
		parent.velocity.y -= parent.gravity * delta
	
	inputDirection = Input.get_vector("A", "D", "W", "S")
	direction = (parent.pivotY.transform.basis * Vector3(inputDirection.x, 0, inputDirection.y)).normalized()
	if inputDirection.length() != 0:
		parent.velocity.x = lerpf(parent.velocity.x, direction.x * moveSpeed, parent.accel * delta)
		parent.velocity.z = lerpf(parent.velocity.z, direction.z * moveSpeed, parent.accel * delta)
	else:
		parent.velocity.x = lerpf(parent.velocity.x, 0.0, parent.decel * delta)
		parent.velocity.z = lerpf(parent.velocity.z, 0.0, parent.decel * delta)
	
	parent.move_and_slide()
