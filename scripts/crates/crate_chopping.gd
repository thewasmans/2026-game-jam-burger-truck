class_name CrateChopping
extends CrateTool

var _sliced_step: int

func assign_ingredient(ingredient:Ingredient) -> bool:
	_sliced_step = 0
	return super.assign_ingredient(ingredient)

func use_tool():
	_sliced_step += 1
	print("_sliced_step ", _sliced_step)
	play_cut_vfx()
	if _sliced_step >= 5:
		print("sliced ",)
		var provide_ingredient := Ingredient.new()
		provide_ingredient.ingredient_data = _ingredient.ingredient_data.provide_ingredient
		provide_ingredient.instance = provide_ingredient.ingredient_data.model_3d.instantiate()
		anchor_spawn.add_child(provide_ingredient.instance)
		_ingredient.instance.queue_free()
		_ingredient.free()
		_ingredient = provide_ingredient

func play_cut_vfx():
	if _ingredient == null:
		return

	var vfx_scene := _ingredient.ingredient_data.cut_vfx
	if vfx_scene == null:
		return

	var vfx_root := vfx_scene.instantiate()
	get_tree().current_scene.add_child(vfx_root)

	vfx_root.global_position = anchor_spawn.global_position

	var particles := vfx_root.get_node_or_null("GPUParticles3D")

	if particles:
		particles.emitting = true
	else:
		push_error("No GPUParticles3D found in VFX scene")
