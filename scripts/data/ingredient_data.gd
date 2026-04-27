@tool
extends Resource

class_name IngredientData

@export var name: String
@export var icon: Texture2D
@export var material: Material
@export var model_3d: PackedScene
@export var price: float
@export var provide_ingredient:IngredientData
@export var cut_vfx: PackedScene
