class_name EnvTurnSun
extends Node

@export var sun: Light3D
@export var speed: float = 1.0

func _process(delta: float) -> void:
	sun.rotate_y(delta * speed)
