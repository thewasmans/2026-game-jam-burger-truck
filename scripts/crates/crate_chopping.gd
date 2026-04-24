class_name CrateChopping
extends CrateTool

var _sliced_step: int

func assign_ingredient(ingredient:Ingredient) -> bool:
	_sliced_step = 0
	return super.assign_ingredient(ingredient)

func use_tool():
	_sliced_step += 1
	print("_sliced_step ", _sliced_step)
	if _sliced_step >= 5:
		print("sliced ",)
		var provide_ingredient := Ingredient.new()
		provide_ingredient.ingredient_data = _ingredient.ingredient_data.provide_ingredient
		provide_ingredient.instance = provide_ingredient.ingredient_data.model_3d.instantiate()
		anchor_spawn.add_child(provide_ingredient.instance)
		_ingredient.instance.queue_free()
		_ingredient.free()
		_ingredient = provide_ingredient
