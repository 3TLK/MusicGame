extends Node3D

@onready var WalkmanPicked : PackedScene = preload("res://Characters/Walkman/Walkman.tscn")
@onready var CDPlayerPicked : PackedScene = preload("res://Characters/CDPlayer/CDPlayer.tscn")
@onready var EnemyTemplatePicked : PackedScene = preload("res://Enemies/EnemyTemplate/EnemyTemplate.tscn")

var currentPlayer : CharacterBody3D = null
var currentEnemy : CharacterBody3D = null
var spawnEnemy : bool

func walkmanSpawn() -> void:
	currentPlayer = WalkmanPicked.instantiate()

func cdPlayerSpawn() -> void:
	currentPlayer = CDPlayerPicked.instantiate()

func enemySpawn() -> void:
	spawnEnemy = true
	currentEnemy = EnemyTemplatePicked.instantiate()

func spawnPlayer() -> void:
	if spawnEnemy:
		add_sibling(currentEnemy)
		currentEnemy.global_position = $"enemy spawn".global_position
	if currentPlayer != null:
		$Camera2D/Container.visible = false
		$Camera2D.enabled = false
		add_sibling(currentPlayer)
		currentPlayer.global_position = global_position
