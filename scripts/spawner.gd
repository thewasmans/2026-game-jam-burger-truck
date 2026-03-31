extends Node3D

class_name EnemySpawner

@export var enemy_scene: PackedScene
@export var spawn_area: BoxShape3D

var timer: Timer

func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = 1.0
	timer.timeout.connect(spawn_enemy)
	add_child(timer)
	timer.start()

func spawn_enemy() -> void:
	if enemy_scene == null:
		return

	var enemy: Node3D = enemy_scene.instantiate()
	var spawn_position: Vector3 = get_random_spawn_position()
	enemy.global_transform.origin = spawn_position
	get_parent().add_child(enemy)

func get_random_spawn_position() -> Vector3:
	var spawn_area_size: Vector3 = spawn_area.size
	var x: float = randf_range(-spawn_area_size.x / 2, spawn_area_size.x / 2)
	var z: float = randf_range(-spawn_area_size.z / 2, spawn_area_size.z / 2)
	return global_transform.origin + Vector3(x, 0, z)
