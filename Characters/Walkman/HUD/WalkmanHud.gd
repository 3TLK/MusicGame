extends Control
class_name WalkmanHUD

var pressPlayOnCooldown : bool
var pressPlayCooldownProgress : float

@export var grappleColliding : GrappleComponent 

@export_category("Press Play")
@export var pressPlayProgressBar : TextureProgressBar
@export var pressPlayCooldownTimer : Timer

func grappleIsColliding():
	if grappleColliding.is_colliding() && !grappleColliding.launched:
		$Polygon2D.color = "yellow"
	elif grappleColliding.launched:
		$Polygon2D.color = "green"
	else:
		$Polygon2D.color = "white"

func startPressPlayCooldown(Cooldown : float) -> void:
	pressPlayOnCooldown = true
	pressPlayCooldownTimer.start(Cooldown)

func endPressPlayCooldown() -> void:
	pressPlayOnCooldown = false
	pressPlayProgressBar.value = 0
