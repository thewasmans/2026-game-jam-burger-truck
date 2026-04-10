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
	#game_ui.set_money_value(_money)

func buy_ingredient(ingredient) -> bool:
	if _money - ingredient.price < 0:
		return false
	_money -= ingredient.price
	#game_ui.set_money_value(_money)
	money_changed.emit()
	return true

func add_money(price: float):
	_money += price
	money_changed.emit()
