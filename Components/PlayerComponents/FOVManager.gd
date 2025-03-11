extends Node
class_name FOVManager

@export var camera : Camera3D

var targetFOV : float = 90

func changeFOV(delta : float):
	if camera.fov != targetFOV:
		camera.fov = lerp(camera.fov, targetFOV, 10 * delta)
