extends Control
class_name WalkmanHUD

var pressPlayOnCooldown : bool
var pressPlayCooldownProgress : float

var grappleOnCooldown : bool
var grappleProgress : float

@export var grappleColliding : GrappleComponent 

@export_category("Press Play")
@export var pressPlayProgressBar : TextureProgressBar
@export var pressPlayCooldownTimer : Timer

@export_category("Grapple")
@export var grappleProgressbar : TextureProgressBar
@export var grappleCooldownTimer : Timer

func grappleIsColliding():
	if grappleColliding.is_colliding() && !grappleColliding.launched:
		$CrossHair.color = "yellow"
	elif grappleColliding.launched:
		$CrossHair.color = "green"
	else:
		$CrossHair.color = "white"

func startGrappleCooldown(Cooldown : float) -> void:
	grappleOnCooldown = true
	grappleCooldownTimer.start(Cooldown)

func endGrappleCooldown() -> void:
	grappleOnCooldown = false
	grappleProgressbar.value = 0

func startPressPlayCooldown(Cooldown : float) -> void:
	pressPlayOnCooldown = true
	pressPlayCooldownTimer.start(Cooldown)

func endPressPlayCooldown() -> void:
	pressPlayOnCooldown = false
	pressPlayProgressBar.value = 0
