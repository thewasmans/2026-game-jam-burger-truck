extends Node3D

class_name Main

@export var kitchen: Kitchen
@export var game_ui: GameUI
@export var spawner: HungryClientSpawner
@export var vfx_burger_disappear: GPUParticles3D
@export var default_amount_money: float = 10.0
@export var furnitures:Array[FurnitureData]
@export var navigation:NavigationRegion3D
@export var placement_zone: Area3D
@export var game_data:GameData
@export var board_ui:BoardUI

var burgers_data:
	get:
		return game_data.burgers_data

func _ready() -> void:
	kitchen.reputation_changed.connect(game_ui.on_reputation_changed)
	kitchen.ingredient_plate_assigned.connect(_on_ingredient_plate_assigned)
	game_ui.init_buttons_furnitures(furnitures)
	game_ui.furniture_selected.connect(FurnituresManager.furniture_selected)
	game_ui.button_start_clicked.connect(start_game)

func _on_ingredient_plate_assigned(crate: CratePlate, ingredient: IngredientData):
	add_ingredient_on_plate(ingredient, crate)

func on_child_entered_tree(node: Node) -> void:
	if node is HungryClient:
		var client: HungryClient = node as HungryClient
		if burgers_data.size() > 0:
			var burger_data = burgers_data.pick_random()
			client.set_burger(burger_data)
		client.leaving_hungry.connect(kitchen.on_enemy_leaving_hungry.bind(client))
		client.waiting_food.connect(func():
			kitchen.on_client_waiting_food(client)
			check_all_burgers())
		ClientsManager._clients.append(client)
		client.leaved.connect(free_client.bind(client))

func start_game():
	board_ui.initialize()
	MoneyManager.initialize(default_amount_money)
	FurnituresManager.initialize(navigation, placement_zone)
	ClientsManager.initialize()
	spawner.initialize()
	

func free_client(client:HungryClient):
	client.queue_free()

func add_ingredient_on_plate(ingredient: IngredientData, plate:CratePlate):
	#if MoneyManager.buy_ingredient(ingredient):
	plate.add_ingredient(ingredient)
	var client = ClientsManager.burger_match_with_client(plate._ingredients, kitchen._plates_availalble)
	if client:
		ClientsManager.feed_client(client, plate)
		kitchen.release_client_plate(client)
		play_vfx(plate)
			
func check_all_burgers() -> void:
	for plate: CratePlate in kitchen.plates_crates:
		var client: HungryClient = ClientsManager.burger_match_with_client(plate._ingredients, kitchen._plates_availalble)
		if client:
			ClientsManager.feed_client(client, plate)
			kitchen.release_client_plate(client)
			play_vfx(plate)
			
func play_vfx(plate:CratePlate):
	vfx_burger_disappear.emitting = true
	vfx_burger_disappear.global_position = plate.anchor_spawn.global_position
