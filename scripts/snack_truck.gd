extends StaticBody3D

class_name SnackTruck

signal reputation_changed(new_reputation: int)

const MAX_REPUTATION: int = 10
var current_reputation: int = MAX_REPUTATION

func take_damage(amount: int) -> void:
	current_reputation -= amount
	reputation_changed.emit(current_reputation)
	if current_reputation <= 0:
		get_tree().reload_current_scene()

func _ready() -> void:
	reputation_changed.emit(current_reputation)
