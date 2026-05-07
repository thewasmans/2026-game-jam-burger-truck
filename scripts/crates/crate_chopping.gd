class_name CrateChopping
extends CrateTool

var _sliced_step: int

@export var chopping_vfx: Dictionary[IngredientData, GPUParticles3D]

func assign_ingredient(ingredient:Ingredient) -> bool:
	_sliced_step = 0
	return super.assign_ingredient(ingredient)

func use_tool():
	_sliced_step += 1
	AudioManager.play_sfx_random(["sfx-chopping-1","sfx-chopping-2"])
	var tween = create_tween()
	var original_scale = node_hover_feedback.scale
	tween.tween_property(node_hover_feedback, "scale", original_scale * 1.25, .05).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(node_hover_feedback, "scale", original_scale, .05).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_ELASTIC)
	play_cut_vfx()
	if _sliced_step >= 5:
		var provide_ingredient := Ingredient.new()
		provide_ingredient.ingredient_data = _ingredient.ingredient_data.provide_ingredient
		provide_ingredient.instance = provide_ingredient.ingredient_data.model_3d.instantiate()
		anchor_spawn.add_child(provide_ingredient.instance)
		_ingredient.instance.queue_free()
		_ingredient.free()
		_ingredient = provide_ingredient
		ingredient_transformed = true

func play_cut_vfx():

	var data: IngredientData = _ingredient.ingredient_data

	var particles: GPUParticles3D = chopping_vfx[data]

	particles.global_position = anchor_spawn.global_position

	particles.restart()
	particles.emitting = true
