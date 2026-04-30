class_name ClientOrderUI
extends Control

@export var waiting: ProgressBar
@export var ingredients_texture: Array[TextureRect]
var _burger_data: BurgerData
	
func set_waiting(value:float):
	waiting.value = value
	
	var t = value / waiting.max_value
	var color = Color(0.705, 0.0, 0.068, 1.0).lerp(Color(0.443, 0.858, 0.001, 1.0), t)
	var style = waiting.get_theme_stylebox("fill")
	if style:
		style = style.duplicate()
		waiting.add_theme_stylebox_override("fill", style)
		
		if style is StyleBoxFlat:
			style.bg_color = color

func set_burger_data(burger_data:BurgerData):
	_burger_data = burger_data
	reset_textures_ingredients()

func reset_textures_ingredients():
	for texture in ingredients_texture:
		texture.texture = null

func set_textures_ingredients(burger_data: BurgerData):
	if burger_data.ingredients.size() >= ingredients_texture.size():
		push_error("[ ClientOrderUI ] Burger Data have to mush ingredient")
		return
	for i in burger_data.ingredients.size():
		ingredients_texture[i].texture = burger_data.ingredients[i].icon
