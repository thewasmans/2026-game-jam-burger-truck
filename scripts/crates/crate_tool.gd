class_name CrateTool
extends CrateInterract

signal tool_used()

@export var raw_ingredient_data:RawIngredientData
@export var anchors_spawn:Node3D

func use_tool(raw_ingredient:RawIngredient):
	var ingredients := raw_ingredient.raw_ingredient_data.provides_ingredients
	for i in ingredients.size():
		var ingredient := ingredients[i]
		var instance: Node3D = ingredient.model_3d.instantiate()
		anchors_spawn.add_child(instance)
		instance.position = (Vector3.LEFT * (i - ingredients.size() / 2.0))
	tool_used.emit()
