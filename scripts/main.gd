extends Node3D

class_name Main

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
@export var plate_selector: Node3D
var _clients: Array[HungryClient] = []
var _money: int = 0
var _plates: Array[Plate]
var _current_index_plate: int
var current_plate:Plate:
	get:
		return _plates[_current_index_plate]
var current_burger:Array[Ingredient]:
	get:
		return current_plate._ingredients

func _ready() -> void:
	snack_truck.reputation_changed.connect(game_ui.on_reputation_changed)
	game_ui.init_buttons_ingredients(ingredients_data)
	game_ui.select_plate_changed.connect(plate_selected_changed)
	for button in game_ui.ingredients_buttons:
		var ingredient:Ingredient = button.get_meta("ingredient")
		button.pressed.connect(add_ingredient_on_plate.bind(ingredient))
	for anchor in anchor_plates:
		_plates.append(Plate.new(anchor))
	plate_selected_changed(0)

func on_child_entered_tree(node: Node) -> void:
	if node is HungryClient:
		var client: HungryClient = node as HungryClient
		if burgers_data.size() > 0:
			var burger_data = burgers_data.pick_random()
			client.set_burger(burger_data)
		client.leaving_hungry.connect(on_enemy_leaving_hungry.bind(client))
		client.waiting_food.connect(check_all_burgers)
		_clients.append(client)
		client.leaved.connect(free_client.bind(client))

func free_client(client:HungryClient):
	client.queue_free()

func on_enemy_leaving_hungry(client:HungryClient) -> void:
	_clients.erase(client)
	snack_truck.take_damage(1)

func add_ingredient_on_plate(ingredient:Ingredient):
	game_ui.add_ingredient(ingredient)
	current_plate.add_ingredient(ingredient)
	var client := burger_match_with_client(current_burger)
	if client:
		feed_client(client, current_plate)
	
func plate_selected_changed(side:int):
	_current_index_plate = clamp( _current_index_plate + side, 0, anchor_plates.size() - 1)
	plate_selector.global_position = current_plate._anchor.global_position
	
func check_all_burgers() -> void:
	for plate: Plate in _plates:
		var client: HungryClient = burger_match_with_client(plate._ingredients)
		if client:
			feed_client(client, plate)
			
func feed_client(client:HungryClient, plate:Plate):
			client.give_food(plate._ingredients)
			_money += client._burger_request.price
			game_ui.set_money_value(_money)
			plate.clear()
			_clients.erase(client)

func burger_match_with_client(burger: Array[Ingredient]) -> HungryClient:
	for client: HungryClient in _clients:
		if client.is_waiting:
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
