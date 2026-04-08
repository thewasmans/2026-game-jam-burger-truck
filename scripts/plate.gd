extends Object
class_name Plate

var _ingredients:Array[Ingredient] = []
var _anchor:Node3D

func _init(anchor:Node3D) -> void:
	_anchor = anchor	
	
func add_ingredient(ingredient:Ingredient):
	var instance: Node3D = ingredient.model_3d.instantiate()
	_ingredients.append(ingredient)
	instance.position += Vector3.UP * _ingredients.size() * .25
	instance.scale = Vector3.ONE * .25
	_anchor.add_child(instance)
	print("_anchor ", _anchor)

func clear():
	for child in _anchor.get_children():
		child.queue_free()
	_ingredients = []
