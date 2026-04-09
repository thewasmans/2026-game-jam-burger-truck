extends Node3D
class_name AnchorHide

@export var meshes: Array[MeshInstance3D]

func _ready() -> void:
	for mesh in meshes:
		if mesh:
			mesh.hide()
