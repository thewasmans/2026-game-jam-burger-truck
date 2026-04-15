class_name CrateTool
extends CrateInterract

@export var ingredient_data:IngredientData
var _ingredient: Ingredient

func use_tool(ingredient:Ingredient):
	if ingredient.ingredient_data != ingredient_data:
		print("CANT USE THIS TOOL WITH THE INGREDIENT")
		return
	var provide_ingredient := Ingredient.new()
	provide_ingredient.ingredient_data = ingredient.ingredient_data.provide_ingredient
	provide_ingredient.instance = provide_ingredient.ingredient_data.model_3d.instantiate()
	anchor_spawn.add_child(provide_ingredient.instance)
	_ingredient = provide_ingredient
