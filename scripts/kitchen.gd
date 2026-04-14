extends Node3D

class_name Kitchen

signal reputation_changed(new_reputation: int)
signal ingredient_plate_assigned(crate:CratePlate, ingredient:IngredientData)

@export var ingredient_crates: Array[CrateIngredient]
@export var plates_crates: Array[CratePlate]
@export var crate_trash: BoxInterract
@export var anchor_plates_clients: Array[Node3D]
@export var camera:Camera3D
@export var distance:float

var MAX_REPUTATION: int = 10
var current_reputation: int = MAX_REPUTATION
var _current_ingredient: Node3D = null
var _plates_availalble:Dictionary[Node3D, HungryClient] = {}

func _ready() -> void:
	reputation_changed.emit(current_reputation)
	
	for crate in ingredient_crates:
		crate.crate_selected.connect(_on_box_ingredient_selected.bind(crate))
		
	for crate in plates_crates:
		crate.crate_selected.connect(_on_crate_plate_selected.bind(crate))
		#crate._plate = Plate.new(box.anchor_spawn)
		#_plates.append(box._plate)
		
	for anchor in anchor_plates_clients:
		_plates_availalble[anchor] = null
		
	crate_trash.box_selected.connect(_on_trash_selected)
		
func _process(_delta: float) -> void:
	if _current_ingredient:
		var mouse_pos: Vector2 = get_viewport().get_mouse_position()
		var ray_origin: Vector3 = camera.project_ray_origin(mouse_pos)
		var ray_direction: Vector3 = camera.project_ray_normal(mouse_pos)
		var world_plane: Plane = Plane(Vector3.UP, 1.7)
		var intersection = world_plane.intersects_ray(ray_origin, ray_direction)
		_current_ingredient.global_position = intersection
		
func take_damage(amount: int) -> void:
	current_reputation -= amount
	reputation_changed.emit(current_reputation)
	if current_reputation <= 0:
		get_tree().reload_current_scene()
		
func _on_box_ingredient_selected(crate:CrateIngredient):
	if _current_ingredient == null:
		_current_ingredient = instantiate_ingredient(crate)
		
func _on_crate_plate_selected(crate:CratePlate):
	if _current_ingredient:
		var data = _current_ingredient.get_meta("data")
		_current_ingredient.queue_free()
		_current_ingredient = null
		ingredient_plate_assigned.emit(crate, data)

func instantiate_ingredient(crate:CrateIngredient) -> Node3D:
	if _current_ingredient != null: return null
	var instance: Node3D = crate.ingredient.model_3d.instantiate()
	instance.scale = Vector3.ONE * .25
	crate.anchor_spawn.add_child(instance)
	instance.set_meta("data", crate.ingredient)
	return instance
	
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

func _on_trash_selected():
	_current_ingredient.queue_free()
	_current_ingredient = null
