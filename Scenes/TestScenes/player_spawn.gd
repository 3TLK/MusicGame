extends Node3D

@onready var WalkmanPicked : PackedScene = preload("res://Characters/Walkman/Walkman.tscn")
@onready var CDPlayerPicked : PackedScene = preload("res://Characters/CDPlayer/CDPlayer.tscn")
@onready var EnemyTemplatePicked : PackedScene = preload("res://Enemies/EnemyTemplate/EnemyTemplate.tscn")

var currentPlayer : CharacterBody3D = null
var currentEnemy : CharacterBody3D = null
var spawnEnemy : bool
var randSeed : int

func walkmanSpawn() -> void:
	currentPlayer = WalkmanPicked.instantiate()

func cdPlayerSpawn() -> void:
	currentPlayer = CDPlayerPicked.instantiate()

func setSeed():
	if ($Camera2D/Container/VBoxContainer/HBoxContainer2/VBoxContainer/LineEdit.text).length() == 8:
		randSeed = int($Camera2D/Container/VBoxContainer/HBoxContainer2/VBoxContainer/LineEdit.text)
		seed(randSeed)
		print(randi_range(1, 1000))

func enemySpawn() -> void:
	spawnEnemy = true
	currentEnemy = EnemyTemplatePicked.instantiate()
	currentEnemy.selfBehavior = $Camera2D/Container/HBoxContainer/VBoxContainer/EnemyType.text

func spawnPlayer() -> void:
	if spawnEnemy:
		add_sibling(currentEnemy)
		currentEnemy.global_position = $"enemy spawn".global_position
	if currentPlayer != null && ($Camera2D/Container/VBoxContainer/HBoxContainer2/VBoxContainer/LineEdit.text).length() == 8:
		$Camera2D/Container.visible = false
		$Camera2D.enabled = false
		add_sibling(currentPlayer)
		currentPlayer.global_position = global_position
