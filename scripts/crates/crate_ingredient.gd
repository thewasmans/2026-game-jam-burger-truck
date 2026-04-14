@tool
class_name CrateIngredient
extends CrateInterract

@export var ingredient:IngredientData:
	set(value):
		ingredient = value
		if ingredient and ingredient.material and box_ingredient:
			box_ingredient.set_surface_override_material(0, ingredient.material)
@export var box_ingredient:MeshInstance3D

func instantiate_ingredient() -> Node3D:
	var instance: Node3D = ingredient.model_3d.instantiate()
	instance.scale = Vector3.ONE * .25
	anchor_spawn.add_child(instance)
	instance.set_meta("data", ingredient)
	return instance
