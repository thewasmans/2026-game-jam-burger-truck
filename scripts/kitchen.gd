extends Node3D

class_name Kitchen

signal reputation_changed(new_reputation: int)
signal ingredient_plate_assigned(crate:CratePlate, ingredient:IngredientData)
signal crate_ingredient_clicked(crate:CrateIngredient)
signal reputation_reached_zero()

@export var ingredient_crates: Array[CrateIngredient]
@export var plates_crates: Array[CratePlate]
@export var tool_crates: Array[CrateTool]
@export var crate_trash: CrateInterract
@export var anchor_plates_clients: Array[Node3D]
@export var camera:Camera3D
@export var vfx_ingredient_dismiss: GPUParticles3D
@export var game_data: GameData

var MAX_REPUTATION: int = 10
var current_reputation: int = MAX_REPUTATION
var _current_ingredient: Ingredient = null
var _plates_availalble:Dictionary[Node3D, HungryClient] = {}
var _current_ingredient_should_release: bool = false

func _ready() -> void:
	reputation_changed.emit(current_reputation)
	IngredientsManager._vfx_ingredient_dismiss = vfx_ingredient_dismiss
	
	for crate in plates_crates:
		crate.crate_selected.connect(_on_crate_plate_selected.bind(crate))
		
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
	if _current_ingredient_should_release:
		_current_ingredient_should_release = false
		vfx_ingredient_dismiss.emitting = true
		vfx_ingredient_dismiss.global_position = _current_ingredient.instance.global_position
		free_current_ingredient()
		
func _input(event: InputEvent) -> void:
	if 	event is InputEventMouseButton and\
		event.button_index == MouseButton.MOUSE_BUTTON_LEFT and\
		event.is_released() and\
		_current_ingredient != null:
			_current_ingredient_should_release = true

func _on_crate_ingredient_selected(crate: CrateIngredient):
	if _current_ingredient == null:
		if MoneyManager.buy_ingredient(crate.ingredient_data):
			_current_ingredient = crate.instantiate_ingredient()
			
			crate_ingredient_clicked.emit(crate)
		
func _on_crate_plate_selected(crate_plate: CratePlate):
	ingredient_plate_assigned.emit(crate_plate, null)
		
func _on_trash_selected():
	if IngredientsManager._current_ingredient:
		IngredientsManager.play_vfx_disapear_ingredient()
		IngredientsManager.free_current_ingredient()
		AudioManager.play_sfx_random(["sfx-trash-1","sfx-trash-2"])

func _on_crate_tool_pressed(crate_tool: CrateTool):
	if crate_tool._ingredient and not crate_tool.ingredient_transformed:
		crate_tool.use_tool()
		if crate_tool is CrateChopping:
			if crate_tool._sliced_step >= game_data.max_steps_sclices:
				crate_tool.ingredient_transformed = true
		
func _on_crate_tool_selected(crate_tool: CrateTool):
	if _current_ingredient:
		if _current_ingredient.ingredient_data.provide_ingredient != null:
			_current_ingredient_should_release = false
			if crate_tool.assign_ingredient(_current_ingredient):
				_current_ingredient = null
	
func assign_clients_to_plates() -> void:
	for anchor: Node3D in anchor_plates_clients:
		var size = ClientsManager._waiting_queue.size()
		if _plates_availalble[anchor] == null and ClientsManager._waiting_queue.size() > 0:
			var next_client: HungryClient = ClientsManager._waiting_queue.pop_front()
			_plates_availalble[anchor] = next_client
			next_client.assign_to_plate(anchor.global_position)

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
		reputation_reached_zero.emit()

func free_current_ingredient():
	if _current_ingredient:
		_current_ingredient.instance.queue_free()
		_current_ingredient.free()
		_current_ingredient = null
