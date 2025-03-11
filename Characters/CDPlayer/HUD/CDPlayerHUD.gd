extends Control
class_name CDPlayerHUD

@export var ammoLabel : Label

func updateAmmoDisplay(newAmmoCount : int) -> void:
	ammoLabel.text = str(newAmmoCount)
