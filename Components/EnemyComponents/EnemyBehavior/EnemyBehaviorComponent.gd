extends Node
class_name EnemyBehaviorComponent

@onready var bulletScene : PackedScene = preload("res://Enemies/EnemyTemplate/Bullet/Bullet.tscn")

var bullet : RigidBody3D

@export var parent : CharacterBody3D
@export var shootCooldown : Timer

var direction : Vector3

var playerInRange : bool
var canShoot : bool = true

var playerPosition : Vector3

func isPlayerInRange(detectionRange : float) -> void:
	playerPosition = Vector3(global.playerPosition.x,(global.playerPosition.y - (global.playerPosition.y - parent.global_position.y)), global.playerPosition.z)
	if parent.global_position.distance_to(playerPosition) < detectionRange:
		parent.pivotY.look_at(global.playerPosition)
		playerInRange = true
	else:
		playerInRange = false

func move(delta : float, moveSpeed : float, detectionRange : float, coward : int) -> void:
	isPlayerInRange(detectionRange)
	if parent.is_on_floor():
		parent.decel = parent.defaultdecel
	else:
		parent.decel = 0.5
		parent.velocity.y -= parent.gravity * delta
	
	direction = (parent.pivotY.transform.basis * Vector3(0, 0, coward)).normalized()
	if playerInRange:
		parent.velocity.x = lerpf(parent.velocity.x, direction.x * moveSpeed, parent.accel * delta)
		parent.velocity.z = lerpf(parent.velocity.z, direction.z * moveSpeed, parent.accel * delta)
	else:
		parent.velocity.x = lerpf(parent.velocity.x, 0.0, parent.decel * delta)
		parent.velocity.z = lerpf(parent.velocity.z, 0.0, parent.decel * delta)
	
	parent.move_and_slide()

func shootReady():
	canShoot = true

func rangeShoot(detectionRange : float) -> void:
	isPlayerInRange(detectionRange)
	if playerInRange && canShoot:
		canShoot = false
		$shootCooldown.start()
		bullet = bulletScene.instantiate()
		parent.add_sibling(bullet)
		bullet.rotation = parent.pivotY.global_rotation
		bullet.global_position = parent.global_position

func enemyBehavior(behavior : String, delta : float, moveSpeed : float, detectionRange : float) -> void:
	match behavior:
		"Melee":
			move(delta, moveSpeed, detectionRange, -1)
		"Range":
			move(delta, moveSpeed, detectionRange, 1)
			rangeShoot(detectionRange * 2)
