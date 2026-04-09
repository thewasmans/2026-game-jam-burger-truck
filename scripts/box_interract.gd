class_name BoxInterract
extends Node3D

signal box_selected()

@export var node_hover_feedback:Node3D
@export var speed_animation:float = .35 
@export var scale_animation:float = 1.5
@export var ingredient:IngredientData
@export var anchor_spawn:Node3D
var _plate:Plate

func _ready() -> void:
	$Area3D.mouse_entered.connect(_on_area_3d_mouse_entered)
	$Area3D.mouse_exited.connect(_on_area_3d_mouse_exited)
	$Area3D.input_event.connect(_on_area_3d_input_event)

func _on_area_3d_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property(node_hover_feedback, "scale", Vector3.ONE * scale_animation, speed_animation).set_trans(Tween.TRANS_ELASTIC)

func _on_area_3d_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(node_hover_feedback, "scale", Vector3.ONE, speed_animation).set_trans(Tween.TRANS_ELASTIC)

func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			box_selected.emit()
