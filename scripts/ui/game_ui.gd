extends Control

class_name GameUI

signal furniture_selected(furniture:FurnitureData)
signal button_start_clicked

@export var money_label: Label
@export var theme_ingredients: Theme
@export var container_furnitures: GridContainer
@export var container_menu: FoldableContainer
@export var board: BoardUI
@export var sart_menu: Control
@export var button_start: Button
@export var button_mute: Button
@export var label_clients: Label
var ingredients_buttons:Array[Button]

func _ready() -> void:
	money_label.text = "0 $"
	MoneyManager.money_changed.connect(func(): set_money_value(MoneyManager._money))

func init_buttons_furnitures(furnitures:Array[FurnitureData]):
	for furniture in furnitures:
		var button := Button.new()
		button.icon = furniture.icon
		button.text = furniture.name + "\n" + str(furniture.price) + "$"
		button.custom_minimum_size = Vector2(200, 200)
		button.theme = theme_ingredients
		button.pressed.connect(func(): 
			furniture_selected.emit(furniture)
			container_menu.folded = true
			)
		container_furnitures.add_child(button)

func on_reputation_changed(new_reputation: int) -> void:
	board.set_reputation(new_reputation/10.0)

func _on_button_start_pressed() -> void:
	sart_menu.hide()
	button_start_clicked.emit()

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
		
func set_wave_information(wave:WavesPresetData, number_wave: int):
	label_clients.text = "WAVE " + str(number_wave ) + " - " + str(wave.clients.size()) + " CLIENTS WILL COMING"
	animate_label(label_clients)
	
func animate_label(label: Label):
	var tween = create_tween()
	label.pivot_offset = label.size / 2
	label.scale = Vector2.ONE
	label.modulate = Color.WHITE
	tween.parallel().tween_property(label, "scale", Vector2(2.3, 2.3), 0.1)
	tween.parallel().tween_property(label, "modulate", Color.YELLOW, 0.1)
	tween.tween_property(label, "scale", Vector2.ONE, 0.15)
	tween.parallel().tween_property(label, "modulate", Color.WHITE, 0.15)
