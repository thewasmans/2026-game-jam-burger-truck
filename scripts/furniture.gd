class_name Furniture3D
extends Node3D

@export var blocks: Array[Node3D]
@export var material_wrong_placement: StandardMaterial3D
@export var material_good_placement: StandardMaterial3D
@export var meshs_feedback_placement: Array[MeshInstance3D]

func _ready() -> void:
	disable_placement_feedback()

func blocks_to_2D_positions(tile_position: Vector2) -> Array[Vector2]:
	var positions: Array[Vector2] = []
	for block in blocks:
		positions.append(tile_position + Vector2(block.position.x, block.position.z))
	return positions

func set_enable_wrong_placement():
	for mesh in meshs_feedback_placement:
		mesh.visible = true
		mesh.material_override = material_wrong_placement
	var tween = create_tween()
	var alpha = material_wrong_placement.albedo_color.a
	tween.tween_property(material_wrong_placement, "albedo_color:a", 0.0, 0.1)
	tween.tween_property(material_wrong_placement, "albedo_color:a", alpha, 0.1)
	await get_tree().create_timer(.2).timeout
	disable_placement_feedback()
	
func set_enable_good_placement():
	for mesh in meshs_feedback_placement:
		mesh.visible = true
		mesh.material_override = material_good_placement
		
func disable_placement_feedback():
	for mesh in meshs_feedback_placement:
		mesh.visible = false
	
