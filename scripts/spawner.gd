extends Node3D

class_name EnemySpawner

signal client_spawned(client:Enemy)

@export var enemy_scene: PackedScene
@export var spawn_area: BoxShape3D
@export var front_truck_target: MeshInstance3D 
@export var out_screen_target: MeshInstance3D 

var timer: Timer

func _ready() -> void:
	front_truck_target.hide()
	out_screen_target.hide()
	timer = Timer.new()
	timer.wait_time = 2.0
	timer.timeout.connect(spawn_enemy)
	add_child(timer)
	timer.start()

func spawn_enemy() -> void:
	if enemy_scene == null:
		return

	var enemy: Enemy = enemy_scene.instantiate()
	enemy.target_position = front_truck_target.global_position
	enemy.target_leaving = out_screen_target.global_position
	var spawn_position: Vector3 = get_random_spawn_position()
	get_parent().add_child(enemy)
	enemy.global_transform.origin = spawn_position
	client_spawned.emit(enemy)

func get_random_spawn_position() -> Vector3:
	var spawn_area_size: Vector3 = spawn_area.size
	var x: float = randf_range(-spawn_area_size.x / 2, spawn_area_size.x / 2)
	var z: float = randf_range(-spawn_area_size.z / 2, spawn_area_size.z / 2)
	return global_transform.origin + Vector3(x, 0, z)
