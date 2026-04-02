extends Control

class_name GameUI

signal select_plate_changed(side:int)

@export var reputation_slider: HSlider
@export var container_buttons_ingredients:Container
@export var money_label:Label
@export var theme_ingredients:Theme
@export var button_left:Button
@export var button_right:Button
var ingredients_buttons:Array[Button]

func _ready() -> void:
	money_label.text = "0 $"
	button_left.pressed.connect(select_plate.bind(-1))
	button_right.pressed.connect(select_plate.bind(1))

func init_buttons_ingredients(ingredients:Array[Ingredient]):
	for ingredient in ingredients:
		var button = Button.new()
		button.icon = ingredient.icon
		button.theme = theme_ingredients
		container_buttons_ingredients.add_child(button)
		button.set_meta("ingredient", ingredient)
		ingredients_buttons.append(button)

func on_reputation_changed(new_reputation: int) -> void:
	reputation_slider.value = new_reputation

func add_ingredient(ingredient:Ingredient):
	var ingredient_texture := TextureRect.new()
	ingredient_texture.texture = ingredient.icon
	ingredient_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ingredient_texture.custom_minimum_size = Vector2(100, 100)

func set_money_value(value:int):
	money_label.text = str(value) + "$"

func select_plate(side:int):
	select_plate_changed.emit(side)
