class_name ClientRequestUI
extends Control

@export var label:Label
@export var waiting:Slider
@export var ingredients_container:FlowContainer

func add_ingredients(ingredient:Ingredient):
	var ingredient_icon := TextureRect.new()
	ingredient_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ingredient_icon.texture = ingredient.icon
	ingredient_icon.custom_minimum_size = Vector2(200, 200)
	ingredients_container.add_child(ingredient_icon)
	
func set_burger(burger_data:BurgerData):
	for elt in ingredients_container.get_children():
		elt.queue_free()
	label.text = burger_data.name
	for ingredient in burger_data.ingredients:
		add_ingredients(ingredient)
	
func set_waiting(value:float):
	waiting.value = value
