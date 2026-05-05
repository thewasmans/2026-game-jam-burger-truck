extends Node3D

var _current_ingredient: Ingredient = null
var _current_plate: CratePlate = null
var _crate_drag: CrateInterract = null
var _is_dragging: bool
var _camera: Camera3D
var _vfx_ingredient_dismiss: GPUParticles3D
var _enable_interract: bool
var input_released: bool

func _ready() -> void:
	input_released = true
	_enable_interract = true
	_camera = get_viewport().get_camera_3d()

func _input(event: InputEvent) -> void:
	if not _enable_interract:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_is_dragging = false           
			else:
				if _is_dragging:
					_on_drag_dropped()
				else:
					_on_pressed()
			
		_is_dragging = false

	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if not _is_dragging:
			_is_dragging = true
			_on_drag_started()

func _on_pressed():
	var crate := get_crate_targeted()
	_crate_drag = null
	
	if crate is CrateChopping and not crate.ingredient_transformed and crate._ingredient:
		print("Use chopping")
		crate.use_tool()

func _on_drag_started():
	_crate_drag = get_crate_targeted()
	
	if _crate_drag is CratePlate:
		if _crate_drag._ingredients.size() > 0 :
			_current_plate = _crate_drag
	 
	if _crate_drag is CrateIngredient:
		_current_ingredient = _crate_drag.instantiate_ingredient()
		AudioManager.play_sfx("sfx-crate")
	
	elif _crate_drag is CrateTool and _crate_drag.ingredient_transformed:
		_current_ingredient = _crate_drag._ingredient
		AudioManager.stop_sfx("sfx-overcooking-steak-loop")
	elif _crate_drag is CrateCoocking:
		_crate_drag = null
	elif _crate_drag is CrateChopping:
		_crate_drag = null

func _on_drag_dropped():
	var crate := get_crate_targeted()
	if not _crate_drag:
		return
		
	if crate is CrateTool:
		if _current_ingredient:
			if _crate_drag == crate:
				_current_ingredient.instance.position = Vector3.ZERO
				_current_ingredient = null
			else:
				if crate.assign_ingredient(_current_ingredient):
					_current_ingredient = null
				else:
					play_vfx_disapear_ingredient()
					reset_crate_tool()
					free_current_ingredient()
	if crate is CrateIngredient and _current_ingredient:
		play_vfx_disapear_ingredient()
		free_current_ingredient()
	if crate is CratePlate:
		if _current_ingredient == null: 
			return
		crate.add_ingredient(_current_ingredient.ingredient_data)
		free_current_ingredient()
	
	if not crate and get_ground() and _current_ingredient:
		play_vfx_disapear_ingredient()
		reset_crate_tool()
		free_current_ingredient()
		
	if _current_plate and crate is CrateTrash:
		_current_plate.clear()

func get_ground() -> Kitchen:
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_3d()
	
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000

	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	
	var all_results = []
	var exceptions = []

	while true:
		query.exclude = exceptions
		var result = space_state.intersect_ray(query)
		
		if result:
			all_results.append(result)
			exceptions.append(result.rid)
		else:
			break
			
	for hit: Dictionary in all_results:
		if hit.collider is Kitchen:
			return hit.collider
	return null

func get_crate_targeted() -> CrateInterract:
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_3d()
	
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000

	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	
	var all_results = []
	var exceptions = []

	while true:
		query.exclude = exceptions
		var result = space_state.intersect_ray(query)
		
		if result:
			all_results.append(result)
			exceptions.append(result.rid)
		else:
			break
			
	for hit: Dictionary in all_results:
		if hit.collider is CrateInterract:
			return hit.collider
	return null
			
func _process(_delta: float) -> void:
	if _current_ingredient:
		var mouse_pos: Vector2 = get_viewport().get_mouse_position()
		var ray_origin: Vector3 = _camera.project_ray_origin(mouse_pos)
		var ray_direction: Vector3 = _camera.project_ray_normal(mouse_pos)
		var world_plane: Plane = Plane(Vector3.UP, 1.7)
		var intersection = world_plane.intersects_ray(ray_origin, ray_direction)
		_current_ingredient.instance.global_position = intersection
	elif _current_plate:
		if _is_dragging:
			pass
		else:
			var mouse_pos: Vector2 = get_viewport().get_mouse_position()
			var ray_origin: Vector3 = _camera.project_ray_origin(mouse_pos)
			var ray_direction: Vector3 = _camera.project_ray_normal(mouse_pos)
			var world_plane: Plane = Plane(Vector3.UP, 1.7)
			var intersection = world_plane.intersects_ray(ray_origin, ray_direction)
			_current_plate._burger_node.global_position = intersection

func reset_crate_tool():
	if _crate_drag is CrateTool:
		_crate_drag.ingredient_transformed = false
		_crate_drag._ingredient = null

func free_current_ingredient():
	_current_ingredient.instance.queue_free()
	_current_ingredient.free()
	_current_ingredient = null
	
func play_vfx_disapear_ingredient():
	_vfx_ingredient_dismiss.restart()
	_vfx_ingredient_dismiss.emitting = true
	_vfx_ingredient_dismiss.global_position = _current_ingredient.instance.global_position

func set_enable_kitchen(enable: bool):
	_enable_interract = enable
