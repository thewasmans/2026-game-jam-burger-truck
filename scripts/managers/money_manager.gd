extends Node

signal money_initialized
signal money_changed

var _money: float = 0
var _factor_increment: float

func initialize(default_amount_money: float, factor_increment: float = 1.0):
	_money = default_amount_money
	_factor_increment = factor_increment
	money_initialized.emit()
	money_changed.emit()

func _process(_delta: float) -> void:
	_money += _delta * _factor_increment
	money_changed.emit()

func buy_ingredient(ingredient: IngredientData) -> bool:
	if _money - ingredient.price < 0:
		return false
	AudioManager.play_sfx("sfx-money")
	_money -= ingredient.price
	money_changed.emit()
	return true
	
func buy_furniture(furniture: FurnitureData) -> bool:
	if _money - furniture.price < 0:
		return false
	AudioManager.play_sfx("sfx-money")
	_money -= furniture.price
	money_changed.emit()
	return true

func add_money(price: float):
	_money += price
	money_changed.emit()
