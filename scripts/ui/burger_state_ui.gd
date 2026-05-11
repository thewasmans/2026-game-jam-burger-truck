class_name BurgerStateUI
extends Control

@export var textures_ingredient: Array[TextureRect]
@export var label_more: Label
@export var style: StyleBoxFlat

func set_ingredients(ingredients: Array[IngredientData]):
	label_more.visible = ingredients.size() > 7
	style.bg_color = Color.RED if label_more.visible else Color.WHITE
	
	for i in textures_ingredient.size():
		var texture := textures_ingredient[i]
		texture.visible = i < ingredients.size()
		if i < ingredients.size():
			texture.texture = ingredients[i].icon
