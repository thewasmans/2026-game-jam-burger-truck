class_name GameData
extends Resource

@export var burgers_data: Array[BurgerData]
@export var ingredients_data: Array[IngredientData]
@export var speed_money_increment: float = 1.0
@export_custom(PROPERTY_HINT_NONE, "suffix:Steps") var max_steps_sclices: int = 5
@export_group("Furnitures")
@export var furnitures:Array[FurnitureGridData]
@export_custom(PROPERTY_HINT_NONE, "suffix:Furnitures") var furnitures_selection: int = 3
@export_custom(PROPERTY_HINT_NONE, "suffix:Furnitures") var furnitures_placement: int = 1
@export_group("Waves")
@export var waves: Array[WavesData]
@export var default_client: ClientData
@export var waiting_next_wave: float = 5.0
