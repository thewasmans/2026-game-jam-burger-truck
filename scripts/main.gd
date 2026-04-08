extends Node3D

class_name Main

signal money_changed

class Plate:
	var _ingredients:Array[Ingredient] = []
	var _anchor:Node3D
	
	func _init(anchor:Node3D) -> void:
		_anchor = anchor	
		
	func add_ingredient(ingredient:Ingredient):
		var instance: Node3D = ingredient.model_3d.instantiate()
		_ingredients.append(ingredient)
		instance.position += Vector3.UP * _ingredients.size() * .25
		instance.scale = Vector3.ONE * .25
		_anchor.add_child(instance)
	
	func clear():
		for child in _anchor.get_children():
			child.queue_free()
		_ingredients = []

@export var snack_truck: SnackTruck
@export var game_ui: GameUI
@export var spawner: HungryClientSpawner
@export var burgers_data: Array[BurgerData]
@export var ingredients_data: Array[Ingredient]
@export var anchor_plates: Array[Node3D]
@export var anchor_plates_clients: Array[Node3D]
@export var plate_selector: Node3D
@export var vfx_burger_disappear: GPUParticles3D
@export var default_amount_money: float = 10.0
@export var furnitures:Array[Furniture]
@export var navigation:NavigationRegion3D

var _plates_availalble:Dictionary[Node3D, HungryClient] = {}
var _waiting_queue: Array[HungryClient] = []
var _clients: Array[HungryClient] = []
var _money: float = 0
var _plates: Array[Plate]
var _current_index_plate: int
var _current_furniture:Furniture
var _current_furniture_instance: Node3D
var current_plate:Plate:
	get:
		return _plates[_current_index_plate]
var current_burger:Array[Ingredient]:
	get:
		return current_plate._ingredients

func _ready() -> void:
	_current_furniture = null
	snack_truck.reputation_changed.connect(game_ui.on_reputation_changed)
	snack_truck.ingredient_plate_assigned.connect(lol)
	game_ui.init_buttons_ingredients(ingredients_data)
	game_ui.init_buttons_furnitures(furnitures)
	game_ui.select_plate_changed.connect(plate_selected_changed)
	game_ui.deleted_current_plate.connect(flush_current_plate)
	game_ui.furniture_selected.connect(furniture_selected)
	for button in game_ui.ingredients_buttons:
		var ingredient:Ingredient = button.get_meta("ingredient")
		button.pressed.connect(add_ingredient_on_plate.bind(ingredient))
	for anchor in anchor_plates:
		_plates.append(Plate.new(anchor))
		
	for anchor in anchor_plates_clients:
		_plates_availalble[anchor] = null
		
	_money = default_amount_money
	game_ui.set_money_value(default_amount_money)
	plate_selected_changed(0)

func furniture_selected(furniture:Furniture):
	_current_furniture = furniture
	if is_instance_valid(_current_furniture_instance):
		_current_furniture_instance.queue_free()
	if _current_furniture != null:
		_current_furniture_instance = _current_furniture.model_3d.instantiate()
		add_child(_current_furniture_instance)

func _process(_delta: float) -> void:
	_money += _delta
	game_ui.set_money_value(_money)
	if is_instance_valid(_current_furniture_instance):
		var camera: Camera3D = get_viewport().get_camera_3d()
		if camera:
			var mouse_pos: Vector2 = get_viewport().get_mouse_position()
			var ray_origin: Vector3 = camera.project_ray_origin(mouse_pos)
			var ray_dir: Vector3 = camera.project_ray_normal(mouse_pos)
			var plane: Plane = Plane(Vector3.UP, 0)
			var intersection: Variant = plane.intersects_ray(ray_origin, ray_dir)
			if intersection != null:
				_current_furniture_instance.global_position = intersection

func _unhandled_input(event: InputEvent) -> void:
	if is_instance_valid(_current_furniture_instance):
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				_current_furniture_instance.reparent(navigation)
				navigation.bake_navigation_mesh()
				_current_furniture = null
				_current_furniture_instance = null
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				_current_furniture_instance.queue_free()
				_current_furniture = null
				_current_furniture_instance = null
	
func flush_current_plate():
	current_plate.clear()

func on_child_entered_tree(node: Node) -> void:
	if node is HungryClient:
		var client: HungryClient = node as HungryClient
		if burgers_data.size() > 0:
			var burger_data = burgers_data.pick_random()
			client.set_burger(burger_data)
		client.leaving_hungry.connect(on_enemy_leaving_hungry.bind(client))
		client.waiting_food.connect(check_all_burgers)
		client.waiting_food.connect(on_client_waiting_food.bind(client))
		_clients.append(client)
		client.leaved.connect(free_client.bind(client))

func free_client(client:HungryClient):
	client.queue_free()

func on_enemy_leaving_hungry(client:HungryClient) -> void:
	_clients.erase(client)
	_waiting_queue.erase(client)
	release_client_plate(client)
	snack_truck.take_damage(1)

func on_client_waiting_food(client: HungryClient) -> void:
	_waiting_queue.append(client)
	assign_clients_to_plates()
	check_all_burgers()

func assign_clients_to_plates() -> void:
	for anchor: Node3D in anchor_plates_clients:
		if _plates_availalble[anchor] == null and _waiting_queue.size() > 0:
			var next_client: HungryClient = _waiting_queue.pop_front()
			_plates_availalble[anchor] = next_client
			next_client.global_position = anchor.global_position

func release_client_plate(client: HungryClient) -> void:
	for anchor: Node3D in _plates_availalble.keys():
		if _plates_availalble[anchor] == client:
			_plates_availalble[anchor] = null
			break
	assign_clients_to_plates()
	
func lol(box, ingredient:Ingredient):
	add_ingredient_on_plate(ingredient)

func add_ingredient_on_plate(ingredient:Ingredient):
	if buy_ingredient(ingredient):
		current_plate.add_ingredient(ingredient)
		var client := burger_match_with_client(current_burger)
		if client:
			feed_client(client, current_plate)

func buy_ingredient(ingredient) -> bool:
	if _money - ingredient.price < 0:
		return false
	_money -= ingredient.price
	game_ui.set_money_value(_money)
	money_changed.emit()
	return true
	
func plate_selected_changed(side:int):
	_current_index_plate = clamp( _current_index_plate + side, 0, anchor_plates.size() - 1)
	plate_selector.global_position = current_plate._anchor.global_position
	
func check_all_burgers() -> void:
	for plate: Plate in _plates:
		var client: HungryClient = burger_match_with_client(plate._ingredients)
		if client:
			feed_client(client, plate)
			
func feed_client(client:HungryClient, plate:Plate):
	vfx_burger_disappear.emitting = true
	vfx_burger_disappear.global_position = plate._anchor.global_position
	client.give_food(plate._ingredients)
	_money += client._burger_request.price
	game_ui.set_money_value(_money)
	plate.clear()
	_clients.erase(client)
	_waiting_queue.erase(client)
	release_client_plate(client)

func burger_match_with_client(burger: Array[Ingredient]) -> HungryClient:
	for client: HungryClient in _clients:
		if client.is_waiting and client in _plates_availalble.values():
			var request_ingredients: Array[Ingredient] = client._burger_request.ingredients
			var is_match: bool = true
			
			if request_ingredients.size() != burger.size():
				is_match = false
			else:
				for i: int in range(burger.size()):
					if request_ingredients[i] != burger[i]:
						is_match = false
						break
						
			if is_match:
				return client
			
	return null
