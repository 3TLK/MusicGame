extends Control
class_name CDPlayerHUD

@export_category("Ammo")
@export_subgroup("Ammo")
@export var ammoLabel : Label
@export var ammoProgress : TextureProgressBar

@export var parent : CharacterBody3D

func updateAmmoDisplay(newAmmoCount : int) -> void:
	ammoLabel.text = str(newAmmoCount)
	if newAmmoCount > 0:
		ammoProgress.value = newAmmoCount*2
