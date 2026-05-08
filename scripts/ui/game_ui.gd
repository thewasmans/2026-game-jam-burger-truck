extends Control

class_name GameUI

signal furniture_selected(furniture:FurnitureData)
signal button_start_clicked

@export var money_label: Label
@export var theme_ingredients: Theme
@export var container_furnitures: GridContainer
@export var container_menu: FoldableContainer
@export var board: BoardUI
@export var start_menu: Control
@export var end_menu: Control
@export var mini_map: Control
@export var button_start: Button
@export var button_return_to_start: Button
@export var button_mute: Button
@export var label_clients: Label
@export var label_score: Label
@export var order_ui_prefab: PackedScene
@export var container_orders: Control
@export var label_remaining: Label
@export var next_wave_button: Button
@export var re_roll_button: Button
var ingredients_buttons:Array[Button]
var _clients_orders: Dictionary[HungryClient, ClientOrderUI]
var _button_furniture_selected: Button

func _ready() -> void:
	money_label.text = "0 $"
	start_menu.visible = true
	end_menu.visible = false
	reset_orders()
	MoneyManager.money_changed.connect(func(): set_money_value(MoneyManager._money))
	set_visible_furnitures_menu(false)
	re_roll_button.visible = false

func set_buttons_furnitures(furnitures:Array[FurnitureGridData]):
	for child in container_furnitures.get_children():
		child.queue_free()
	for furniture in furnitures:
		var button := Button.new()
		button.icon = furniture.icon
		button.text = furniture.name + "\n" + str(furniture.price) + "$"
		button.custom_minimum_size = Vector2(200, 200)
		button.theme = theme_ingredients
		button.pressed.connect(func(): 
			furniture_selected.emit(furniture)
			container_menu.folded = true
			_button_furniture_selected = button
			)
		container_furnitures.add_child(button)

func on_reputation_changed(new_reputation: int) -> void:
	board.set_reputation(new_reputation/10.0)

func _on_button_start_pressed() -> void:
	start_menu.hide()
	button_start_clicked.emit()

func _on_button_return_pressed() -> void:
	get_tree().reload_current_scene()

func add_ingredient(ingredient:IngredientData):
	var ingredient_texture := TextureRect.new()
	ingredient_texture.texture = ingredient.icon
	ingredient_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ingredient_texture.custom_minimum_size = Vector2(150, 150)

func set_money_value(value:float):
	money_label.text = str(floor(value)) + "$"

func _on_button_mute_audio_pressed():
	if AudioManager.muted:
		AudioManager.resume_all_sounds()
		button_mute.text = "Mute audio"
	else:
		AudioManager.mute_all_sounds()
		button_mute.text = "Resume Audio"
	
func _on_next_wave_button_pressed() -> void:
	pass # Replace with function body.
	
func set_wave_information(_wave:WavesPresetData, number_wave: int):
	label_clients.text = "WAVE " + str(number_wave )
	animate_label(label_clients)
	
func animate_label(label: Label):
	var tween = create_tween()
	label.pivot_offset = label.size / 2
	label.scale = Vector2.ONE
	label.modulate = Color.WHITE
	tween.parallel().tween_property(label, "scale", Vector2(1.4, 1.4), 0.1)
	tween.parallel().tween_property(label, "modulate", Color.YELLOW, 0.1)
	tween.tween_property(label, "scale", Vector2.ONE, 0.15)
	tween.parallel().tween_property(label, "modulate", Color.WHITE, 0.15)

func set_visible_furnitures_menu(visibility: bool):
	mini_map.visible = not visibility
	container_menu.visible = visibility
	next_wave_button.visible = visibility
	re_roll_button.visible = visibility
	if visibility:
		label_clients.text += " - Finished"

func show_end_score_menu(time: String = "XX:XX:XX", score: String = "XX"):
	end_menu.visible = true
	label_score.text = "GAME TERMINATE\n\nSCORE\n%s\n%s CLIENTS SERVED" % [time, score]
	
func add_order(client: HungryClient) -> ClientOrderUI:
	var instance: ClientOrderUI = order_ui_prefab.instantiate()
	_clients_orders[client] = instance
	instance.set_burger_data(client._burger_request)
	container_orders.add_child(instance)
	return instance

func release_order(client: HungryClient):
	if _clients_orders.has(client):
		_clients_orders[client].queue_free()
		_clients_orders.erase(client)
	
func reset_orders():
	for order: Control in _clients_orders.values():
		order.queue_free()
	_clients_orders = {}
	label_remaining.visible = false
