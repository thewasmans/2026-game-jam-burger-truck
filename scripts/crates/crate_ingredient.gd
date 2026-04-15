@tool
class_name CrateIngredient
extends CrateInterract

@export var ingredient_data:IngredientData:
	set(value):
		ingredient_data = value
		if ingredient_data and ingredient_data.material and mesh_instance_crate:
			mesh_instance_crate.set_surface_override_material(0, ingredient_data.material)
@export var mesh_instance_crate:MeshInstance3D

func instantiate_ingredient() -> Ingredient:
	var ingredient := Ingredient.new()
	ingredient.ingredient_data = ingredient_data
	ingredient.instance = ingredient_data.model_3d.instantiate()
	ingredient.instance.scale = Vector3.ONE * .25
	anchor_spawn.add_child(ingredient.instance)
	return ingredient
