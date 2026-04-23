class_name CrateTool
extends CrateInterract

@export var ingredient_data:Array[IngredientData]
var _ingredient: Ingredient
var ingredient_transformed: bool

func assign_ingredient(ingredient:Ingredient) -> bool:
	if not can_used_ingredient(ingredient):
		print("CANT USE THIS TOOL WITH THE INGREDIENT")
		return false
	_ingredient = ingredient
	ingredient_transformed = false
	ingredient.instance.reparent(anchor_spawn)
	ingredient.instance.position = Vector3.ZERO
	return true

func can_used_ingredient(ingredient: Ingredient):
	for data in ingredient_data:
		if ingredient.ingredient_data == data:
			return true
	return false
