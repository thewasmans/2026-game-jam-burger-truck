extends Control

class_name GameUI

@export var reputation_slider: HSlider
@export var button_create_burger:Button
@export var container:Container

func init_buttons_ingredients(ingredients:Array[Ingredient]):
	for ingredient in ingredients:
		var button = Button.new()
		button.icon = ingredient.icon
		button.add_theme_constant_override('icon_max_width', 100)
		container.add_child(button)

func on_reputation_changed(new_reputation: int) -> void:
	reputation_slider.value = new_reputation
