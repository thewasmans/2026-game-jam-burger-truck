class_name CrateCoocking
extends CrateTool

signal ingredient_coocked()

@export var shader_coocking:ShaderMaterial
@export var ui:ProgressCoocking

var _coocking_started: bool
var _value_progress: float

func _process(delta: float) -> void:
	if not _coocking_started: return
	if _value_progress >= 1.0:
		_value_progress = 1.0
		_coocking_started = false
		ingredient_coocked.emit()
	else:
		_value_progress += delta
		shader_coocking.set_shader_parameter("value", _value_progress)
		ui.set_progress(_value_progress)
		
func assign_ingredient(ingredient:Ingredient) -> bool:
	_value_progress = 0
	_coocking_started = true
	var assigned = super.assign_ingredient(ingredient)
	if assigned:
		var ins = _ingredient.instance
		print(ins)
	return assigned
