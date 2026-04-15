@tool
extends Resource

class_name IngredientData

@export var name: String
@export var icon: Texture2D
@export var material: Material
@export var model_3d: PackedScene:
	set(value):
		model_3d = validate_scene(value)
@export var price: float
@export var provide_ingredient:IngredientData

func validate_scene(packed_scene: PackedScene) -> PackedScene:
	if packed_scene == null: return null
	var instance: Node = packed_scene.instantiate()
	var is_validate: bool = instance is Ingredient
	instance.free()
	if not is_validate:
		push_warning("[ IngredientData ] model_3d should be herite from <Ingredient> class")
	return packed_scene if is_validate else null
