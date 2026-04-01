extends Node3D

class_name Main

@export var snack_truck: SnackTruck
@export var game_ui: GameUI
@export var spawner: EnemySpawner
@export var burgers_data: Array[BurgerData]
var _clients:Array[Enemy] = []

func _ready() -> void:
	snack_truck.reputation_changed.connect(game_ui.on_reputation_changed)
	game_ui.button_create_burger.pressed.connect(create_burger)

func on_child_entered_tree(node: Node) -> void:
	if node is Enemy:
		var client: Enemy = node as Enemy
		if burgers_data.size() > 0:
			var burger_data = burgers_data.pick_random()
			client.set_burger(burger_data)
		client.leaving_hungry.connect(on_enemy_leaving_hungry.bind(client))
		client.leaving_satiated.connect(on_enemy_leaving_satiated)
		_clients.append(client)
		client.leaved.connect(free_client.bind(client))

func free_client(client:Enemy):
	client.queue_free()

func on_enemy_leaving_hungry(client:Enemy) -> void:
	_clients.erase(client)
	snack_truck.take_damage(1)

func on_enemy_leaving_satiated():
	print("TODDO : INCREASE MONEY")

func create_burger():
	if _clients.size() > 0:
		var client: Enemy = _clients.front()
		if client:
			if client.give_food():
				_clients.pop_front()
