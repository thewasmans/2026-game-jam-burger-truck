extends StaticBody3D

class_name Kitchen

signal reputation_changed(new_reputation: int)
signal ingredient_plate_assigned(box:BoxInterract, ingredient:IngredientData)

@export var ingredient_box: Array[BoxInterract]
@export var plates_box: Array[BoxInterract]
@export var camera:Camera3D
@export var distance:float

var MAX_REPUTATION: int = 10
var current_reputation: int = MAX_REPUTATION
var _current_ingredient: Node3D = null
var _plates_availalble:Dictionary[Node3D, HungryClient] = {}
var _plates: Array[Plate]

func _ready() -> void:
	reputation_changed.emit(current_reputation)
	for box in ingredient_box:
		box.box_selected.connect(_on_box_ingredient_selected.bind(box))
		
	for box in plates_box:
		box.box_selected.connect(_on_box_plate_selected.bind(box))

func take_damage(amount: int) -> void:
	current_reputation -= amount
	reputation_changed.emit(current_reputation)
	if current_reputation <= 0:
		get_tree().reload_current_scene()
		
func _on_box_ingredient_selected(box:BoxInterract):
	if _current_ingredient == null:
		_current_ingredient = instantiate_ingredient(box)
		
func _on_box_plate_selected(box:BoxInterract):
	if _current_ingredient:
		var data = _current_ingredient.get_meta("data")
		_current_ingredient.queue_free()
		_current_ingredient = null
		ingredient_plate_assigned.emit(box, data)

func instantiate_ingredient(crate:BoxInterract) -> Node3D:
	var instance: Node3D = crate.ingredient.model_3d.instantiate()
	instance.scale = Vector3.ONE * .25
	crate.anchor_spawn.add_child(instance)
	instance.set_meta("data", crate.ingredient)
	return instance

func _process(_delta: float) -> void:
	if _current_ingredient:
		var mouse_pos: Vector2 = get_viewport().get_mouse_position()
		var ray_origin: Vector3 = camera.project_ray_origin(mouse_pos)
		var ray_direction: Vector3 = camera.project_ray_normal(mouse_pos)
		var world_plane: Plane = Plane(Vector3.UP, 1.7)
		var intersection = world_plane.intersects_ray(ray_origin, ray_direction)
		_current_ingredient.global_position = intersection
