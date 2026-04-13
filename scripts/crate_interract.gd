class_name CrateInterract
extends Node

signal crate_selected()

@export var node_hover_feedback:Node3D
@export var speed_animation:float = .35 
@export var scale_animation:float = 1.25
@export var anchor_spawn:Node3D

func _ready() -> void:
	$Area3D.mouse_entered.connect(_on_area_3d_mouse_entered)
	$Area3D.mouse_exited.connect(_on_area_3d_mouse_exited)
	$Area3D.input_event.connect(_on_area_3d_input_event)

func _on_area_3d_mouse_entered() -> void:
	create_tween().tween_property(node_hover_feedback, "scale", Vector3.ONE * scale_animation, speed_animation).set_trans(Tween.TRANS_ELASTIC)

func _on_area_3d_mouse_exited() -> void:
	create_tween().tween_property(node_hover_feedback, "scale", Vector3.ONE, speed_animation).set_trans(Tween.TRANS_ELASTIC)

func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			crate_selected.emit()
