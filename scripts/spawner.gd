extends Node3D

class_name HungryClientSpawner

signal client_spawned(client:HungryClient)

@export var enemy_scene: PackedScene
@export var front_truck_target: MeshInstance3D 
@export var out_screen_target: MeshInstance3D
@export var minimal_spawn_time: float = 4.0
@export var maximal_spawn_time: float = 8.0
@export var radius_spawn: float = 2.0

@export var difficulty_step: float = 0.5
@export var minimum_limit: float = 5.0

var timer: Timer
var difficulty_timer: Timer

var spawn_time := RandomNumberGenerator.new()
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
	
	difficulty_timer = Timer.new()
	difficulty_timer.wait_time = 60.0
	difficulty_timer.timeout.connect(increase_difficulty)
	add_child(difficulty_timer)
	difficulty_timer.start()

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


func increase_difficulty() -> void:
	minimal_spawn_time -= difficulty_step
	maximal_spawn_time -= difficulty_step
	
	minimal_spawn_time = max(minimum_limit, minimal_spawn_time)
	maximal_spawn_time = max(minimal_spawn_time, maximal_spawn_time)


func get_random_spawn_position() -> Vector3:
	var radius = randf() * radius_spawn
	var angle = randf() * TAU
	var x: float = cos(angle) * radius
	var z: float = sin(angle) * radius
	return global_transform.origin + Vector3(x, 0, z)
