@tool
class_name CrateIngredient
extends CrateInterract

@export var ingredient:IngredientData:
	set(value):
		ingredient = value
		if ingredient and ingredient.material and box_ingredient:
			box_ingredient.set_surface_override_material(0, ingredient.material)
@export var box_ingredient:MeshInstance3D
