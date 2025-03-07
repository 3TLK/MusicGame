extends Node
class_name HealthComponent

@export var maxHealth : float = 100.0
var currentHealth : float

func _ready() -> void:
	currentHealth = maxHealth

func damage(attack):
	currentHealth -= attack
	
	if currentHealth <= 0:
		print("I AM DEAD :O")
