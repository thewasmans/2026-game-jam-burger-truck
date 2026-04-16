extends Node

signal money_initialized
signal money_changed

var _money: float = 0
var initialized: bool = false

func initialize(default_amount_money:float):
	_money = default_amount_money
	money_initialized.emit()
	money_changed.emit()
	initialized = true

func _process(_delta: float) -> void:
	if not initialized: return
	_money += _delta
	money_changed.emit()

func buy_ingredient(ingredient) -> bool:
	if _money - ingredient.price < 0:
		return false
	_money -= ingredient.price
	money_changed.emit()
	return true

func add_money(price: float):
	_money += price
	money_changed.emit()
