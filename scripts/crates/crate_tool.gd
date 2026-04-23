class_name CrateTool
extends CrateInterract

@export var ingredient_data:Array[IngredientData]
var _ingredient: Ingredient

func assign_ingredient(ingredient:Ingredient) -> bool:
	if not can_used_ingredient(ingredient):
		print("CANT USE THIS TOOL WITH THE INGREDIENT")
		return false
	var provide_ingredient := Ingredient.new()
	provide_ingredient.ingredient_data = ingredient.ingredient_data.provide_ingredient
	provide_ingredient.instance = provide_ingredient.ingredient_data.model_3d.instantiate()
	anchor_spawn.add_child(provide_ingredient.instance)
	_ingredient = provide_ingredient
	return true

func can_used_ingredient(ingredient: Ingredient):
	for data in ingredient_data:
		if ingredient.ingredient_data == data:
			return true
	return false
