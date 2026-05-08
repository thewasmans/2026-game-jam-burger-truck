extends Node3D

class_name Main

@export var kitchen: Kitchen
@export var game_ui: GameUI
@export var spawner: HungryClientSpawner
@export var grid: GridSystem
@export var game_data:GameData
@export var board_ui:BoardUI
@export var sounds: Dictionary[String, AudioStream]
@export var stream_player: AudioStreamPlayer
@export var camera_switcher: CameraSwitcher
var current_wave_burgers: Array[BurgerData] = []
var burgers_data:
	get:
		return game_data.burgers_data
var reroll_price: int

func _ready() -> void:
	kitchen.reputation_changed.connect(game_ui.on_reputation_changed)
	kitchen.ingredient_plate_assigned.connect(_on_ingredient_plate_assigned)
	kitchen.reputation_reached_zero.connect(_reputation_reached_zero)
	game_ui.furniture_selected.connect(FurnituresManager.furniture_selected)
	spawner.next_wave_started.connect(func(data, number):
		IngredientsManager.set_enable_kitchen(true)
		FurnituresManager.reset_current_furniture_placed()
		current_wave_burgers = data.burgers
		game_ui.set_visible_furnitures_menu(false)
		camera_switcher.set_camera_kitchen()
		grid.set_visible_grid(false)
		game_ui.set_wave_information(data, number))
	spawner.waiting_next_wave.connect(func():
		reroll_price = game_data.reroll_price
		game_ui.re_roll_button.text = "Roll Furniture " + str(game_data.reroll_price) + "$"
		IngredientsManager.set_enable_kitchen(false)
		kitchen.free_current_ingredient()
		var furnitures := FurnituresManager.shuffle_selection_furnitures()
		game_ui.reset_orders()
		game_ui.set_buttons_furnitures(furnitures)
		camera_switcher.set_camera_furnitures()
		grid.set_visible_grid(true)
		IngredientsManager.free_current_ingredient()
		game_ui.set_visible_furnitures_menu(true))
	spawner.client_spawned.connect(client_spawned)
	camera_switcher.set_camera_kitchen()
	game_ui.next_wave_button.pressed.connect(func(): spawner.next_wave())
	
	MoneyManager.initialize(game_data.initial_amount_money, game_data.speed_money_increment)
	FurnituresManager.initialize(grid, game_data)
	ClientsManager.initialize()
	AudioManager.initialize(sounds, stream_player)
	game_ui.button_start_clicked.connect(start_game)
	get_tree().paused = true
	AudioManager.play_music("main-music")
	MoneyManager.furniture_bought.connect(func (_furniture: FurnitureGridData):
		if game_ui._button_furniture_selected:
			game_ui._button_furniture_selected.disabled = true)
	game_ui.re_roll_button.pressed.connect(func():
		if MoneyManager.can_buy(reroll_price):
			var furnitures := FurnituresManager.shuffle_selection_furnitures()
			game_ui.set_buttons_furnitures(furnitures)
			MoneyManager.buy(reroll_price)
			reroll_price = reroll_price + game_data.reroll_price_added_next
			game_ui.re_roll_button.text = "Roll Furniture " + str(reroll_price) + "$"
	)

func _on_ingredient_plate_assigned(crate: CratePlate, ingredient: IngredientData):
	add_ingredient_on_plate(ingredient, crate)
	
func _reputation_reached_zero():
	get_tree().paused = true
	game_ui.show_end_score_menu(board_ui.format_time(board_ui.timer), str(ClientsManager.clients_feeded))

func client_spawned(client: HungryClient):
	if burgers_data.size() > 0:
		var burger_data = current_wave_burgers.pick_random()
		client.set_burger(burger_data)
		var order := game_ui.add_order(client)
		client.set_order_ui(order)
	client.leaving_hungry.connect(kitchen.on_enemy_leaving_hungry.bind(client))
	client.waiting_food.connect(func():
		kitchen.on_client_waiting_food(client)
		check_all_burgers())
	ClientsManager._clients.append(client)
	client.leaved.connect(free_client.bind(client))

func start_game():
	get_tree().paused = false

func free_client(client:HungryClient):
	game_ui.release_order(client)
	spawner.remove_client(client)
	client.queue_free()

func add_ingredient_on_plate(_ingredient: IngredientData, plate:CratePlate):
	AudioManager.play_sfx("sfx-plate")
	var client = ClientsManager.burger_match_with_client(plate._ingredients, kitchen._plates_availalble)
	if client:
		ClientsManager.feed_client(client, plate)
		game_ui.release_order(client)
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
	kitchen.vfx_ingredient_dismiss.emitting = true
	kitchen.vfx_ingredient_dismiss.global_position = plate.anchor_spawn.global_position
