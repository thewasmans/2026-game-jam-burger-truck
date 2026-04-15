class_name CrateTool
extends CrateInterract

signal tool_used()

@export var ingredient_data:IngredientData
@export var anchors_spawn:Node3D

func use_tool(ingredient:IngredientData):
	var provide_ingredient := ingredient.provide_ingredient
	var instance: Ingredient = provide_ingredient.model_3d.instantiate()
	anchors_spawn.add_child(instance)
	tool_used.emit()
