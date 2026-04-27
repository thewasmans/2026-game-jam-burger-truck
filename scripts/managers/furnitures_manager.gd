extends Node3D

var _current_furniture:FurnitureGridData
var _current_furniture_instance: Node3D
var _grid: GridSystem
var _tile_position: Vector2

func initialize(grid: GridSystem):
	_current_furniture = null
	_current_furniture_instance = null
	_grid = grid

func _process(_delta: float) -> void:
	if _current_furniture_instance:
		var space_state = get_world_3d().direct_space_state
		var mouse_pos = get_viewport().get_mouse_position()

		var camera = get_viewport().get_camera_3d()
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 1000

		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.collide_with_areas = true
		var result = space_state.intersect_ray(query)
		
		if result:
			var tile := result.collider as Node
			if tile:
				if tile.has_meta("tile"):
					var tile_3D := tile as Node3D
					var meta_data := tile_3D.get_meta("tile") as Vector3
					_tile_position = Vector2(meta_data.x, meta_data.z)
					_current_furniture_instance.global_position = tile_3D.global_position

func furniture_selected(furniture:FurnitureGridData):
	if MoneyManager.buy_furniture(furniture):
		_current_furniture = furniture
	if is_instance_valid(_current_furniture_instance):
		_current_furniture_instance.queue_free()
	if _current_furniture != null:
		_current_furniture_instance = _current_furniture.prefab.instantiate()
		add_child(_current_furniture_instance)

func _unhandled_input(event: InputEvent) -> void:
	if is_instance_valid(_current_furniture_instance):
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if _grid.add_obstacle(_tile_position):
					_current_furniture_instance.reparent(_grid)
					_current_furniture = null
					_current_furniture_instance = null
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				_current_furniture_instance.queue_free()
				_current_furniture = null
				_current_furniture_instance = null
