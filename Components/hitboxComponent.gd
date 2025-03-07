extends Area3D
class_name HitboxComponent

@export var healthComponent : HealthComponent

func damage(attack):
	if healthComponent:
		healthComponent.damage(attack)
