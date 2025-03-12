extends Node
class_name EnemyMoveComponent

@export var parent : CharacterBody3D

var direction : Vector3

var playerInRange : bool

func isPlayerInRange(detectionRange : float) -> void:
	if parent.global_position.distance_to(global.playerPosition) < detectionRange:
		playerInRange = true
		parent.pivotY.look_at(global.playerPosition)
		print(parent.pivotY.rotation)
	else:
		playerInRange = false

func characterMove(delta : float, moveSpeed : float, detectionRange : float) -> void:
	isPlayerInRange(detectionRange)
	if parent.is_on_floor():
		parent.decel = parent.defaultdecel
	else:
		parent.decel = 0.5
		parent.velocity.y -= parent.gravity * delta
	
	direction = (parent.pivotY.transform.basis * Vector3(0, 0, -1)).normalized()
	if playerInRange && playerInRange:
		parent.velocity.x = lerpf(parent.velocity.x, direction.x * moveSpeed, parent.accel * delta)
		parent.velocity.z = lerpf(parent.velocity.z, direction.z * moveSpeed, parent.accel * delta)
	else:
		parent.velocity.x = lerpf(parent.velocity.x, 0.0, parent.decel * delta)
		parent.velocity.z = lerpf(parent.velocity.z, 0.0, parent.decel * delta)
	
	parent.move_and_slide()
