extends Node

signal money_initialized
signal money_changed

var _money: float = 0

func initialize(default_amount_money:float):
	_money = default_amount_money
	money_initialized.emit()
	money_changed.emit()

func _process(_delta: float) -> void:
	_money += _delta
	money_changed.emit()

func buy_ingredient(ingredient: IngredientData) -> bool:
	if _money - ingredient.price < 0:
		return false
	_money -= ingredient.price
	money_changed.emit()
	return true
	
func buy_furniture(furniture: FurnitureData) -> bool:
	if _money - furniture.price < 0:
		return false
	_money -= furniture.price
	money_changed.emit()
	return true

func add_money(price: float):
	_money += price
	money_changed.emit()
