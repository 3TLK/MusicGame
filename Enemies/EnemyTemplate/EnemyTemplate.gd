extends CharacterBody3D
class_name EnemyTemplate

@export_category("Components")
@export var enemyBehavior : EnemyBehaviorComponent

@export_category("Enemy Pivots")
@export var pivotY : Node3D

@export_category("Enemy Movement")
@export var moveSpeed : float = 2
@export var gravity : float = 9.8
@export var accel : float = 5
@export var decel : float = 8

@export_category("EnemyType")
@export var selfBehavior : String


var defaultaccel : float = 5
var defaultdecel : float = 8

func _physics_process(delta: float) -> void:
	enemyBehavior.enemyBehavior(selfBehavior, delta, moveSpeed, 10.0)
