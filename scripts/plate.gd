extends Object
class_name Plate

var _ingredients:Array[IngredientData] = []
var _anchor:Node3D

func _init(anchor:Node3D) -> void:
	_anchor = anchor	
	
func add_ingredient(ingredient:IngredientData):
	var instance: Node3D = ingredient.model_3d.instantiate()
	_ingredients.append(ingredient)
	instance.position += Vector3.UP * _ingredients.size() * .10
	instance.scale = Vector3.ONE * .25
	_anchor.add_child(instance)

func clear():
	for child in _anchor.get_children():
		child.queue_free()
	_ingredients = []
