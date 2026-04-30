extends Node3D

var _current_furniture:FurnitureGridData
var _current_furniture_instance: Furniture3D
var _grid: GridSystem
var _tile_position: Vector2
var _currents_furnitures_availbles: Array[FurnitureData]
var _furnitures: Array[FurnitureGridData]
var _game_data: GameData

func initialize(grid: GridSystem, game_data: GameData):
	_current_furniture = null
	_current_furniture_instance = null
	_furnitures = game_data.furnitures
	_grid = grid
	_game_data = game_data
	
func _process(_delta: float) -> void:
	if _current_furniture_instance:
		
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
			if hit.collider is Node:
				var tile := hit.collider as Node
				if tile.has_meta("tile"):
					var tile_3D := tile as Node3D
					var meta_data := tile_3D.get_meta("tile") as Vector3
					_tile_position = Vector2(meta_data.x, meta_data.z)
					_current_furniture_instance.global_position = tile_3D.global_position
					
func _unhandled_input(event: InputEvent) -> void:
	if is_instance_valid(_current_furniture_instance):
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if _grid.add_obstacles(_current_furniture_instance.blocks_to_2D_positions(_tile_position)):
					AudioManager.play_sfx_random(["sfx-furniture-1","sfx-furniture-2"])
					_current_furniture_instance.reparent(_grid)
					_current_furniture = null
					_current_furniture_instance = null
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				_current_furniture_instance.queue_free()
				_current_furniture = null
				_current_furniture_instance = null
				
func furniture_selected(furniture:FurnitureGridData):
	if MoneyManager.buy_furniture(furniture):
		_current_furniture = furniture
	if is_instance_valid(_current_furniture_instance):
		_current_furniture_instance.queue_free()
	if _current_furniture != null:
		_current_furniture_instance = _current_furniture.prefab.instantiate()
		add_child(_current_furniture_instance)

func shuffle_selection_furnitures() -> Array[FurnitureGridData]:
	var furnitures: Array[FurnitureGridData] = []
	for elt in _game_data.furnitures_selection:
		furnitures.append(_furnitures.pick_random())
	return furnitures
