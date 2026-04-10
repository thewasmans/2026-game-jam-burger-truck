extends Node3D

class_name Main

@export var kitchen: Kitchen
@export var game_ui: GameUI
@export var spawner: HungryClientSpawner
@export var burgers_data: Array[BurgerData]
@export var ingredients_data: Array[IngredientData]
@export var anchor_plates_clients: Array[Node3D]
@export var plate_selector: Node3D
@export var vfx_burger_disappear: GPUParticles3D
@export var default_amount_money: float = 10.0
@export var furnitures:Array[FurnitureData]
@export var navigation:NavigationRegion3D
@export var placement_zone: Area3D

var _plates_availalble:Dictionary[Node3D, HungryClient] = {}
var _waiting_queue: Array[HungryClient] = []
var _clients: Array[HungryClient] = []
var _plates: Array[Plate]
var current_plate:Plate
var current_burger:Array[IngredientData]:
	get:
		return current_plate._ingredients
var anchor_plates: Array:
	get:
		var box = kitchen.plates_box.map(func(elt:BoxInterract): return elt.anchor_spawn)
		return box

func _ready() -> void:
	kitchen.reputation_changed.connect(game_ui.on_reputation_changed)
	kitchen.ingredient_plate_assigned.connect(_on_ingredient_plate_assigned)
	game_ui.init_buttons_furnitures(furnitures)
	game_ui.furniture_selected.connect(FurnituresManager.furniture_selected)
	for button in game_ui.ingredients_buttons:
		var ingredient:IngredientData = button.get_meta("ingredient")
		button.pressed.connect(add_ingredient_on_plate.bind(ingredient))
		
	for box in kitchen.plates_box:
		var plate = Plate.new(box.anchor_spawn)
		box._plate = plate
		_plates.append(plate)
		
	for anchor in anchor_plates_clients:
		_plates_availalble[anchor] = null
		
	MoneyManager.initialize(default_amount_money)
	FurnituresManager.initialize(navigation, placement_zone)

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
	kitchen.take_damage(1)

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
	
func _on_ingredient_plate_assigned(box: BoxInterract, ingredient: IngredientData):
	current_plate = box._plate
	add_ingredient_on_plate(ingredient)

func add_ingredient_on_plate(ingredient: IngredientData):
	if MoneyManager.buy_ingredient(ingredient):
		current_plate.add_ingredient(ingredient)
		var client := burger_match_with_client(current_burger)
		if client:
			feed_client(client, current_plate)
	
func check_all_burgers() -> void:
	for plate: Plate in _plates:
		var client: HungryClient = burger_match_with_client(plate._ingredients)
		if client:
			feed_client(client, plate)
			
func feed_client(client:HungryClient, plate:Plate):
	vfx_burger_disappear.emitting = true
	vfx_burger_disappear.global_position = plate._anchor.global_position
	client.give_food(plate._ingredients)
	MoneyManager.add_money(client._burger_request.price)
	#game_ui.set_money_value(_money)
	plate.clear()
	_clients.erase(client)
	_waiting_queue.erase(client)
	release_client_plate(client)

func burger_match_with_client(burger: Array[IngredientData]) -> HungryClient:
	for client: HungryClient in _clients:
		if client.is_waiting and client in _plates_availalble.values():
			var request_ingredients: Array[IngredientData] = client._burger_request.ingredients
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
