extends Node3D
class_name AnchorHide

@export var meshes: Array[MeshInstance3D]
@export var debug_view: bool

func _ready() -> void:
	if debug_view : return
	for mesh in meshes:
		if mesh:
			mesh.hide()
