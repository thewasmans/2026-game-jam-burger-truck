extends Node3D

class_name HungryClientSpawner

signal client_spawned(client:HungryClient)

@export var enemy_scene: PackedScene
@export var spawn_area: BoxShape3D
@export var front_truck_target: MeshInstance3D 
@export var out_screen_target: MeshInstance3D 
var spawn_time := RandomNumberGenerator.new()
@export var minimal_spawn_time: float = 4.0
@export var maximal_spawn_time: float = 8.0

var timer: Timer
var _hungries_clients: Array[HungryClient] = []

func _ready() -> void:
	randomize()
	var spawn_time_random = randf_range(minimal_spawn_time, maximal_spawn_time)
	front_truck_target.hide()
	out_screen_target.hide()
	timer = Timer.new()
	timer.wait_time = spawn_time_random
	timer.timeout.connect(spawn_enemy)
	add_child(timer)
	timer.start()

	await get_tree().create_timer(.01).timeout
	spawn_enemy()

func spawn_enemy() -> void:
	if enemy_scene == null:
		return

	var client: HungryClient = enemy_scene.instantiate()
	client.agent.target_position = front_truck_target.global_position
	client.target_position = front_truck_target.global_position
	client.target_leaving = out_screen_target.global_position
	var spawn_position: Vector3 = get_random_spawn_position()
	get_parent().add_child(client)
	client.global_transform.origin = spawn_position
	client_spawned.emit(client)
	_hungries_clients.append(client)
	
	timer.wait_time = randf_range(minimal_spawn_time, maximal_spawn_time)
	

func get_random_spawn_position() -> Vector3:
	var spawn_area_size: Vector3 = spawn_area.size
	var x: float = randf_range(-spawn_area_size.x / 2, spawn_area_size.x / 2)
	var z: float = randf_range(-spawn_area_size.z / 2, spawn_area_size.z / 2)
	return global_transform.origin + Vector3(x, 0, z)
