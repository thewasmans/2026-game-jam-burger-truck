extends Node3D

class_name Kitchen

signal reputation_changed(new_reputation: int)
signal ingredient_plate_assigned(crate:CratePlate, ingredient:IngredientData)
signal crate_ingredient_clicked(crate:CrateIngredient)

@export var ingredient_crates: Array[CrateIngredient]
@export var plates_crates: Array[CratePlate]
@export var tool_crates: Array[CrateTool]
@export var crate_trash: CrateInterract
@export var anchor_plates_clients: Array[Node3D]
@export var camera:Camera3D

var MAX_REPUTATION: int = 10
var current_reputation: int = MAX_REPUTATION
var _current_ingredient: Ingredient = null
var _plates_availalble:Dictionary[Node3D, HungryClient] = {}

func _ready() -> void:
	reputation_changed.emit(current_reputation)
	
	for crate in ingredient_crates:
		crate.crate_selected.connect(_on_crate_ingredient_selected.bind(crate))
		
	for crate in plates_crates:
		crate.crate_selected.connect(_on_crate_plate_selected.bind(crate))
		
	for crate in tool_crates:
		crate.crate_selected.connect(_on_crate_tool_selected.bind(crate))
		
	for anchor in anchor_plates_clients:
		_plates_availalble[anchor] = null
		
	crate_trash.crate_selected.connect(_on_trash_selected)
		
func _process(_delta: float) -> void:
	if _current_ingredient:
		var mouse_pos: Vector2 = get_viewport().get_mouse_position()
		var ray_origin: Vector3 = camera.project_ray_origin(mouse_pos)
		var ray_direction: Vector3 = camera.project_ray_normal(mouse_pos)
		var world_plane: Plane = Plane(Vector3.UP, 1.7)
		var intersection = world_plane.intersects_ray(ray_origin, ray_direction)
		_current_ingredient.instance.global_position = intersection
		
func _on_crate_ingredient_selected(crate: CrateIngredient):
	if _current_ingredient == null:
		_current_ingredient = crate.instantiate_ingredient()
		crate_ingredient_clicked.emit(crate)
		
func _on_crate_plate_selected(crate_plate: CratePlate):
	if _current_ingredient:
		var data = get_current_ingredient_data()
		ingredient_plate_assigned.emit(crate_plate, data)
		
func _on_trash_selected():
	free_current_ingredient()
	
func _on_crate_tool_selected(crate_tool: CrateTool):
	if _current_ingredient:
		if _current_ingredient.ingredient_data.provide_ingredient != null:
			if crate_tool.use_tool(_current_ingredient):
				free_current_ingredient()
	else:
		_current_ingredient = crate_tool._ingredient
	
func assign_clients_to_plates() -> void:
	for anchor: Node3D in anchor_plates_clients:
		var size = ClientsManager._waiting_queue.size()
		if _plates_availalble[anchor] == null and ClientsManager._waiting_queue.size() > 0:
			var next_client: HungryClient = ClientsManager._waiting_queue.pop_front()
			_plates_availalble[anchor] = next_client
			next_client.global_position = anchor.global_position

func release_client_plate(client: HungryClient) -> void:
	for anchor: Node3D in _plates_availalble.keys():
		if _plates_availalble[anchor] == client:
			_plates_availalble[anchor] = null
			break
	assign_clients_to_plates()

func on_enemy_leaving_hungry(client:HungryClient) -> void:
	ClientsManager.release_client(client)
	release_client_plate(client)
	take_damage(1)

func on_client_waiting_food(client: HungryClient) -> void:
	ClientsManager._waiting_queue.append(client)
	assign_clients_to_plates()

func get_current_ingredient_data() -> IngredientData:
	var data := _current_ingredient.ingredient_data
	free_current_ingredient()
	return data

		
func take_damage(amount: int) -> void:
	current_reputation -= amount
	reputation_changed.emit(current_reputation)
	if current_reputation <= 0:
		get_tree().reload_current_scene()
		

func free_current_ingredient():
	_current_ingredient.instance.queue_free()
	_current_ingredient.free()
	_current_ingredient = null
