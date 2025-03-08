extends Control
class_name WalkmanHUD

var pressPlayOnCooldown : bool
var pressPlayCooldownProgress : float

@export_category("Press Play")
@export var pressPlayProgressBar : TextureProgressBar
@export var pressPlayCooldownTimer : Timer

func startPressPlayCooldown(Cooldown : float) -> void:
	pressPlayOnCooldown = true
	pressPlayCooldownTimer.start(Cooldown)

func endPressPlayCooldown() -> void:
	pressPlayOnCooldown = false
	pressPlayProgressBar.value = 0
