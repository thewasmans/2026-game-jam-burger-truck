class_name CratePlate
extends CrateInterract

var _ingredients:Array[IngredientData]
var _burger_node: Node3D

func _ready() -> void:
	super._ready()
	_burger_node = Node3D.new()
	anchor_spawn.add_child(_burger_node)

func add_ingredient(ingredient:IngredientData):
	var instance: Node3D = ingredient.model_3d.instantiate()
	_ingredients.append(ingredient)
	instance.position += Vector3.UP * _ingredients.size() * .10
	instance.rotate_y(randf() * TAU)
	instance.scale = Vector3.ONE
	_burger_node.add_child(instance)

func clear():
	for child in _burger_node.get_children():
		child.queue_free()
	_ingredients = []
	_burger_node.position = Vector3.ZERO
