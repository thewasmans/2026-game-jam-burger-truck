class_name Furniture3D
extends Node3D

@export var blocks: Array[MeshInstance3D]
@export var material_wrong_placement: StandardMaterial3D
@export var material_good_placement: StandardMaterial3D
var _alpha: float

func _ready() -> void:
	_alpha = material_wrong_placement.albedo_color.a
	disable_placement_feedback()

func blocks_to_2D_positions(tile_position: Vector2) -> Array[Vector2]:
	var positions: Array[Vector2] = []
	for block in blocks:
		positions.append(tile_position + Vector2(block.position.x, block.position.z))
	return positions

func set_enable_wrong_placement():
	print("lol")
	for mesh in blocks:
		mesh.visible = true
		mesh.material_override = material_wrong_placement
	var tween = create_tween()
	material_wrong_placement.albedo_color.a = _alpha
	tween.tween_property(material_wrong_placement, "albedo_color:a", 0.0, 0.2)
	tween.tween_property(material_wrong_placement, "albedo_color:a", _alpha, 0.2)
	await get_tree().create_timer(.4).timeout
	disable_placement_feedback()
	
func set_enable_good_placement():
	for mesh in blocks:
		mesh.visible = true
		mesh.material_override = material_good_placement
	var tween = create_tween()
	material_good_placement.albedo_color.a = _alpha
	tween.tween_property(material_good_placement, "albedo_color:a", 0.0, 0.45)
	tween.tween_property(material_good_placement, "albedo_color:a", _alpha, 0.45)
	await get_tree().create_timer(1.0).timeout
	disable_placement_feedback()
		
func disable_placement_feedback():
	for mesh in blocks:
		mesh.visible = false
	
