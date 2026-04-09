extends Node3D
class_name AnchorHide

@export var anchor_pole: MeshInstance3D 
@export var anchor_sphere: MeshInstance3D 

func _ready() -> void:
	anchor_pole.hide()
	anchor_sphere.hide()
