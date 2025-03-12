extends RigidBody3D

@export var speed : float = 5.0

func bulletDecay():
	queue_free()

func _physics_process(delta: float) -> void:
	move_and_collide(-transform.basis.z * delta * speed)


func _on_hitbox_component_body_entered(body: Node3D) -> void:
	if body.is_in_group("ground"):
		queue_free()
