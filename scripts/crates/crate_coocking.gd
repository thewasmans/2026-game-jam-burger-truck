class_name CrateCoocking
extends CrateTool

signal ingredient_coocked()

@export var ui:ProgressCoocking

var _raw_steack:SteakCoocking
var _coocking_started: bool
var _value_progress: float

func _process(delta: float) -> void:
	if not _coocking_started: return
	
	if _value_progress >= 1.0:
		AudioManager.stop_sfx("sfx-cooking-steak-loop")
		AudioManager.play_sfx("sfx-overcooking-steak-loop")
		_value_progress = 1.0 * .1
		_coocking_started = false
		_spawn_coocked_ingredient()
		ingredient_transformed = true
		ingredient_coocked.emit()
	else:
		_value_progress += delta
		_raw_steack.set_progress(_value_progress)
		ui.set_progress(_value_progress)
		
func _spawn_coocked_ingredient():
	var provide_ingredient := Ingredient.new()
	provide_ingredient.ingredient_data = _ingredient.ingredient_data.provide_ingredient
	provide_ingredient.instance = provide_ingredient.ingredient_data.model_3d.instantiate()
	anchor_spawn.add_child(provide_ingredient.instance)
	_ingredient.instance.queue_free()
	_ingredient.free()
	_ingredient = provide_ingredient
		
func assign_ingredient(ingredient:Ingredient) -> bool:
	var assigned = super.assign_ingredient(ingredient)
	if assigned:
		_value_progress = 0
		_coocking_started = true
		AudioManager.play_sfx("sfx-cooking-steak-loop")
		if ingredient.instance is SteakCoocking:
			_raw_steack = ingredient.instance
	return assigned
