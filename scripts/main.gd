extends Node3D

class_name Main

@export var snack_truck: SnackTruck
@export var game_ui: GameUI
@export var spawner: EnemySpawner
@export var burgers_data: Array[BurgerData]
@export var ingredients_data: Array[Ingredient]
var _current_burger:Array[Ingredient]
var _clients:Array[Enemy] = []
var _money:int = 0

func _ready() -> void:
	snack_truck.reputation_changed.connect(game_ui.on_reputation_changed)
	game_ui.init_buttons_ingredients(ingredients_data)
	for button in game_ui.ingredients_buttons:
		var ingredient:Ingredient = button.get_meta("ingredient")
		button.pressed.connect(create_burger.bind(ingredient))

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
	return
	if _clients.size() > 0:
		var client: Enemy = _clients.front()
		if client:
			if client.give_food():
				_clients.pop_front()
