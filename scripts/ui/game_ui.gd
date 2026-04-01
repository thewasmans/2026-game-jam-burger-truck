extends Control

class_name GameUI

@export var reputation_slider: HSlider
@export var button:Button

func on_reputation_changed(new_reputation: int) -> void:
	reputation_slider.value = new_reputation
