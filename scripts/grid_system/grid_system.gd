@tool
class_name GridSystem
extends Node3D

@export_tool_button("Generate Grid", "Callable") var button_generate_grid = init_grid
@export var node_tiles: Node3D

@export_group("Settings")
@export var grid_size := Vector2(10, 10)
@export var cell_size := 1.0

@export_group("Prefabs")
@export var prefab_til: PackedScene
@export var prefab_hungry_client: PackedScene

@export_group("Navigation Target")
@export var anchor_spawn: Node3D:
	set(value):
		anchor_spawn = value
		set_position_anchor(anchor_spawn, tile_spawn)
@export var anchor_exit: Node3D:
	set(value):
		anchor_exit = value
		set_position_anchor(anchor_exit, tile_exit)
@export var tile_spawn: Node3D:
	set(value):
		tile_spawn = value
		set_position_anchor(anchor_spawn, tile_spawn)
@export var tile_exit: Node3D:
	set(value):
		tile_exit = value
		set_position_anchor(anchor_exit, tile_exit)

var astar = AStar2D.new()
var _parent_tiles: Node3D

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_setup_astar_logic()

func init_grid():
	_clear_tiles()
	_setup_visual_grid()
	_setup_astar_logic()

func spawn_client_at_spawn() -> HungryClient:
	var s_pos = world_to_grid(tile_spawn.global_position)
	var e_pos = world_to_grid(tile_exit.global_position)
	return spawn_client(s_pos, e_pos)

func set_position_anchor(anchor: Node3D, tile: Node3D):
	if anchor and tile and tile.is_inside_tree() and anchor.is_inside_tree():
		anchor.global_position = tile.global_position

func world_to_grid(world_pos: Vector3) -> Vector2:
	var local_pos = to_local(world_pos)
	return Vector2(
		round(local_pos.x / cell_size),
		round(local_pos.z / cell_size)
	)

func grid_to_world(grid_pos: Vector2) -> Vector3:
	var local_pos = Vector3(grid_pos.x * cell_size, 0, grid_pos.y * cell_size)
	return to_global(local_pos)

func _get_unique_id(pos: Vector2) -> int:
	return int(pos.x + (pos.y * grid_size.x))

func _is_within_bounds(pos: Vector2) -> bool:
	return pos.x >= 0 and pos.x < grid_size.x and pos.y >= 0 and pos.y < grid_size.y
	
func _clear_tiles():
	var p = node_tiles if node_tiles else _parent_tiles
	if p:
		for child in p.get_children():
			child.queue_free()

func _setup_visual_grid():
	var parent: Node3D = node_tiles
	if parent == null:
		if _parent_tiles == null:
			parent = Node3D.new()
			parent.name = "Tiles"
			add_child(parent)
			parent.owner = self
			_parent_tiles = parent
		else:
			parent = _parent_tiles
	
	for x in grid_size.x:
		for y in grid_size.y:
			if prefab_til:
				var tile = prefab_til.instantiate()
				parent.add_child(tile)
				tile.owner = self
				tile.name = "Tile_%d_%d" % [x, y]
				tile.position = Vector3(x * cell_size, 0, y * cell_size)
				tile.set_meta("tile", tile.position)

func _setup_astar_logic():
	astar.clear()
	for x in grid_size.x:
		for y in grid_size.y:
			var grid_pos = Vector2(x, y)
			astar.add_point(_get_unique_id(grid_pos), grid_pos)
	_connect_points()

func _connect_points():
	for x in grid_size.x:
		for y in grid_size.y:
			var pos = Vector2(x, y)
			var id = _get_unique_id(pos)
			var neighbors = [Vector2(x+1,y), Vector2(x-1,y), Vector2(x,y+1), Vector2(x,y-1)]
			for n_pos in neighbors:
				if _is_within_bounds(n_pos):
					astar.connect_points(id, _get_unique_id(n_pos))

func spawn_client(grid_spawn: Vector2, grid_exit: Vector2) -> HungryClient:
	var instance = prefab_hungry_client.instantiate()
	add_child(instance)
	instance.owner = self
	instance.global_position = grid_to_world(grid_spawn)
	
	var target_world = grid_to_world(grid_exit)
	var path = get_path_world(instance.global_position, target_world)
	
	if instance.has_method("follow_path"):
		instance.follow_path(path)
	return instance

func get_path_world(start_v3: Vector3, end_v3: Vector3) -> PackedVector3Array:
	var s_grid = world_to_grid(start_v3)
	var e_grid = world_to_grid(end_v3)
	
	var s_id = _get_unique_id(s_grid)
	var e_id = _get_unique_id(e_grid)
	
	var path_v3 = PackedVector3Array()
	
	if astar.has_point(s_id) and astar.has_point(e_id):
		var path_v2 = astar.get_point_path(s_id, e_id)
		for p_grid in path_v2:
			path_v3.append(grid_to_world(p_grid))
	else:
		push_warning("AStar: Point de départ ou d'arrivée hors grille. IDs: ", s_id, " ", e_id)
		
	return path_v3

func add_obstacle(grid_pos: Vector2) -> bool:
	if grid_pos == world_to_grid(tile_spawn.global_position): return false
	if grid_pos == world_to_grid(tile_exit.global_position): return false
	if _is_within_bounds(grid_pos):
		var id = _get_unique_id(grid_pos)
		if astar.is_point_disabled(id):
			return false
		astar.set_point_disabled(id, true)
		return true
	else:
		push_warning("Tentative d'ajouter un obstacle hors limites: ", grid_pos)
	return false
