extends Control

class_name GameUI

@export var reputation_slider: HSlider
@export var button_create_burger:Button
@export var container_buttons_ingredients:Container
@export var container_ingredients_current_burger:Container
@export var theme_ingredients:Theme
var ingredients_buttons:Array[Button]

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
	container_ingredients_current_burger.add_child(ingredient_texture)
