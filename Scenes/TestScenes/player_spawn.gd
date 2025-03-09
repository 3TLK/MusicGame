extends Node3D

@onready var WalkmanPicked : PackedScene = preload("res://Characters/Walkman/Walkman.tscn")
@onready var CDPlayerPicked : PackedScene = preload("res://Characters/CDPlayer/CDPlayer.tscn")

var currentPlayer : CharacterBody3D = null

func walkmanSpawn() -> void:
	currentPlayer = WalkmanPicked.instantiate()

func cdPlayerSpawn() -> void:
	currentPlayer = CDPlayerPicked.instantiate()

func spawnPlayer() -> void:
	if currentPlayer != null:
		$Camera2D/Container.visible = false
		$Camera2D.enabled = false
		add_sibling(currentPlayer)
		currentPlayer.global_position = global_position
