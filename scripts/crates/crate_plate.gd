class_name CratePlate
extends CrateInterract

var _ingredients:Array[IngredientData]

func add_ingredient(ingredient:IngredientData):
	var instance: Node3D = ingredient.model_3d.instantiate()
	_ingredients.append(ingredient)
	instance.position += Vector3.UP * _ingredients.size() * .10
	instance.scale = Vector3.ONE
	anchor_spawn.add_child(instance)

func clear():
	for child in anchor_spawn.get_children():
		child.queue_free()
	_ingredients = []
