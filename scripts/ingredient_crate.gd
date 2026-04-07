class_name IngredientCrate
extends Node3D

@export var node_hover_feedback:Node3D
@export var speed_animation:float = .35 
@export var scale_animation:float = 1.25
@export var ingredient:Ingredient
@export var anchor_spawn:Node3D
var _ingredient_spawned:bool

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

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not _ingredient_spawned:
				var instance: Node3D = ingredient.model_3d.instantiate()
				instance.scale = Vector3.ONE * .25
				anchor_spawn.add_child(instance)
				_ingredient_spawned = true
			else:
				print("grab ingredient")
