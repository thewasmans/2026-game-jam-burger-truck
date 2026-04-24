class_name GridSystem
extends Node3D

@export var grid_size := Vector2(10, 10)
@export var prefab_til: PackedScene
@export var prefab_unit: PackedScene
@export var cell_size := 1.0

var astar = AStar2D.new()

func _ready():
	_setup_grid()
	_connect_points()
	await get_tree().create_timer(2.0).timeout
	spawn_unit_at_edge(Vector2(5, 5))

func _get_unique_id(pos: Vector2) -> int:
	return int(pos.x + (pos.y * grid_size.x))

func _is_within_bounds(pos: Vector2) -> bool:
	return pos.x >= 0 and pos.x < grid_size.x and pos.y >= 0 and pos.y < grid_size.y

func _setup_grid():
	for x in grid_size.x:
		for y in grid_size.y:
			var grid_pos = Vector2(x, y)
			astar.add_point(_get_unique_id(grid_pos), grid_pos)
			if prefab_til:
				var tile = prefab_til.instantiate()
				add_child(tile)
				tile.position = Vector3(x * cell_size, 0, y * cell_size)

func _connect_points():
	for x in grid_size.x:
		for y in grid_size.y:
			var pos = Vector2(x, y)
			var id = _get_unique_id(pos)
			var neighbors = [Vector2(x+1,y), Vector2(x-1,y), Vector2(x,y+1), Vector2(x,y-1)]
			for n_pos in neighbors:
				if _is_within_bounds(n_pos):
					astar.connect_points(id, _get_unique_id(n_pos))

func _get_random_edge_pos() -> Vector2:
	var edge = randi() % 4
	match edge:
		0: return Vector2(randi() % int(grid_size.x), 0)
		1: return Vector2(randi() % int(grid_size.x), int(grid_size.y) - 1)
		2: return Vector2(0, randi() % int(grid_size.y))
		_: return Vector2(int(grid_size.x) - 1, randi() % int(grid_size.y))

func spawn_unit_at_edge(target_grid_pos: Vector2):
	var edge_pos = _get_random_edge_pos()
	if prefab_unit:
		var unit = prefab_unit.instantiate()
		add_child(unit)
		unit.position = Vector3(edge_pos.x * cell_size, 0, edge_pos.y * cell_size)
		
		var path = get_path_world(unit.position, Vector3(target_grid_pos.x * cell_size, 0, target_grid_pos.y * cell_size))
		
		if unit.has_method("follow_path"):
			unit.follow_path(path)

func get_path_world(start_v3: Vector3, end_v3: Vector3) -> PackedVector3Array:
	var s_id = _get_unique_id(Vector2(round(start_v3.x / cell_size), round(start_v3.z / cell_size)))
	var e_id = _get_unique_id(Vector2(round(end_v3.x / cell_size), round(end_v3.z / cell_size)))
	var path_v3 = PackedVector3Array()
	if astar.has_point(s_id) and astar.has_point(e_id):
		var path_v2 = astar.get_point_path(s_id, e_id)
		for p in path_v2:
			path_v3.append(Vector3(p.x * cell_size, 0, p.y * cell_size))
	return path_v3
