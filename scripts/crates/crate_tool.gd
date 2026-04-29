class_name CrateTool
extends CrateInterract

@export var ingredient_data:Array[IngredientData]
var _ingredient: Ingredient
var ingredient_transformed: bool

func assign_ingredient(ingredient:Ingredient) -> bool:
	if not can_used_ingredient(ingredient):
		return false
	_ingredient = ingredient
	ingredient_transformed = false
	ingredient.instance.reparent(anchor_spawn)
	ingredient.instance.position = Vector3.ZERO
	return true

func can_used_ingredient(ingredient: Ingredient):
	for data in ingredient_data:
		if ingredient.ingredient_data == data and _ingredient == null:
			return true
	return false
	
func use_tool():
	pass
