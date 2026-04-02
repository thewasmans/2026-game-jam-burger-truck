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

@export var snack_truck: SnackTruck
@export var game_ui: GameUI
@export var spawner: EnemySpawner
@export var burgers_data: Array[BurgerData]
@export var ingredients_data: Array[Ingredient]
@export var anchor_plates: Array[Node3D]
@export var plate_selector: Node3D
var _current_burger: Array[Ingredient]
var _clients: Array[Enemy] = []
var _money: int = 0
var _plates: Array[Plate]
var _current_index_plate: int
var current_plate:Plate:
	get:
		return _plates[_current_index_plate]

func _ready() -> void:
	snack_truck.reputation_changed.connect(game_ui.on_reputation_changed)
	game_ui.init_buttons_ingredients(ingredients_data)
	game_ui.select_plate_changed.connect(plate_selected_changed)
	for button in game_ui.ingredients_buttons:
		var ingredient:Ingredient = button.get_meta("ingredient")
		button.pressed.connect(create_burger.bind(ingredient))
	for anchor in anchor_plates:
		_plates.append(Plate.new(anchor))
	plate_selected_changed(0)

func on_child_entered_tree(node: Node) -> void:
	if node is Enemy:
		var client: Enemy = node as Enemy
		if burgers_data.size() > 0:
			var burger_data = burgers_data.pick_random()
			client.set_burger(burger_data)
		client.leaving_hungry.connect(on_enemy_leaving_hungry.bind(client))
		client.leaving_satiated.connect(on_enemy_leaving_satiated.bind(client))
		_clients.append(client)
		client.leaved.connect(free_client.bind(client))

func free_client(client:Enemy):
	client.queue_free()

func on_enemy_leaving_hungry(client:Enemy) -> void:
	_clients.erase(client)
	snack_truck.take_damage(1)

func on_enemy_leaving_satiated(client:Enemy):
	_money += 0
	game_ui.set_money_value(client._burger_request.price)

func create_burger(ingredient:Ingredient):
	_current_burger.append(ingredient)
	game_ui.add_ingredient(ingredient)
	current_plate.add_ingredient(ingredient)

func plate_selected_changed(side:int):
	_current_index_plate = clamp( _current_index_plate + side, 0, anchor_plates.size() - 1)
	plate_selector.global_position = current_plate._anchor.global_position
