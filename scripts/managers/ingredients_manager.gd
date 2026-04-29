extends Node3D

var _current_ingredient: Ingredient = null
var _crate_drag: CrateInterract = null
var _is_dragging: bool
var _camera: Camera3D

func _ready() -> void:
	_camera = get_viewport().get_camera_3d()

func _input(event: InputEvent) -> void:
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
		_crate_drag = null
	 
	if _crate_drag is CrateIngredient:
		_current_ingredient = _crate_drag.instantiate_ingredient()
		print("Spawn Ingredient")
	
	elif _crate_drag is CrateTool and _crate_drag.ingredient_transformed:
		_current_ingredient = _crate_drag._ingredient
		print("Grab Ingredient")

func _on_drag_dropped():
	var crate := get_crate_targeted()
	if not _crate_drag:
		return
		
	if crate is CrateTool:
		if _current_ingredient:
			if _crate_drag == crate:
				print("Ingredient return back to tool")
			else:
				print("Assign ingredient to tool")
				if crate.assign_ingredient(_current_ingredient):
					_current_ingredient = null
				else:
					free_current_ingredient()
	if crate is CrateIngredient:
		print("Release ingredient")
		free_current_ingredient()
	if crate is CratePlate:
		if _current_ingredient == null: 
			return
		print("Add ingredient to plate")
		crate.add_ingredient(_current_ingredient.ingredient_data)
		free_current_ingredient()
	
	if not crate and get_ground():
		print("Release food on the ground")
		free_current_ingredient()

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

func free_current_ingredient():
	_current_ingredient.instance.queue_free()
	_current_ingredient.free()
	_current_ingredient = null
