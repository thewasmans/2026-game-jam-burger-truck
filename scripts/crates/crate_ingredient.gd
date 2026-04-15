@tool
class_name CrateIngredient
extends CrateInterract

@export var ingredient:IngredientData:
	set(value):
		ingredient = value
		if ingredient and ingredient.material and mesh_instance_crate:
			mesh_instance_crate.set_surface_override_material(0, ingredient.material)
@export var mesh_instance_crate:MeshInstance3D

func instantiate_ingredient() -> Ingredient:
	var instance: Ingredient = ingredient.model_3d.instantiate()
	instance.scale = Vector3.ONE * .25
	anchor_spawn.add_child(instance)
	instance.set_meta("data", ingredient)
	return instance
