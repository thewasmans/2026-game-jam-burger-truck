extends Control

class_name GameUI

signal furniture_selected(furniture:FurnitureData)

@export var reputation_slider: HSlider
@export var money_label:Label
@export var theme_ingredients:Theme
@export var container_furnitures:GridContainer
var ingredients_buttons:Array[Button]

func _ready() -> void:
	money_label.text = "0 $"
	MoneyManager.money_changed.connect(func(): set_money_value(MoneyManager._money))

func init_buttons_furnitures(furnitures:Array[FurnitureData]):
	for furniture in furnitures:
		var button := Button.new()
		button.icon = furniture.icon
		button.text = furniture.name + " " + str(furniture.price) + "$"
		button.custom_minimum_size = Vector2(200, 200)
		button.theme = theme_ingredients
		button.pressed.connect(func(): furniture_selected.emit(furniture))
		container_furnitures.add_child(button)

func on_reputation_changed(new_reputation: int) -> void:
	reputation_slider.value = new_reputation

func add_ingredient(ingredient:IngredientData):
	var ingredient_texture := TextureRect.new()
	ingredient_texture.texture = ingredient.icon
	ingredient_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ingredient_texture.custom_minimum_size = Vector2(200, 200)

func set_money_value(value:float):
	money_label.text = str(floor(value)) + "$"
