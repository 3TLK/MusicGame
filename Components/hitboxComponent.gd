extends Area3D

@export var healthComponent : HealthComponent

func damage(attack):
	if healthComponent:
		healthComponent.damage(attack)
