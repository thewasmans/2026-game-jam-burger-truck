extends Node3D

class_name HungryClientSpawner

signal client_spawned(client:HungryClient)
signal next_wave_started(current_preset_wave:WavesPresetData, number_wave: int)
signal waiting_next_wave()

@export var enemy_scene: PackedScene
@export var front_truck_target: MeshInstance3D 
@export var out_screen_target: MeshInstance3D
@export var minimal_spawn_time: float = 4.0
@export var maximal_spawn_time: float = 8.0
@onready var spawn_location: PathFollow3D = $SpawnPath/SpawnLocation
@export var difficulty_step: float = 0.5
@export var minimum_limit: float = 5.0
@export var timer_next_wave: Timer
@export var game_data: GameData

var spawn_time := RandomNumberGenerator.new()
var time: float

var _hungries_clients: Array[HungryClient] = []
var _index_current_wave: int = 0
var _current_preset_wave: WavesPresetData
var _client_waiting_to_spawn: Array[ClientData]
var number_wave: int = 0

func _ready() -> void:
	randomize()
	front_truck_target.hide()
	out_screen_target.hide()
	
	timer_next_wave.timeout.connect(next_wave)
	timer_next_wave.wait_time = game_data.waiting_next_wave
	
	await get_tree().create_timer(.1).timeout
	next_wave()
	
func _process(delta: float) -> void:
	time += delta
	for client in _client_waiting_to_spawn.duplicate():
		if time >= client.time_spawn:
			_client_waiting_to_spawn.erase(client)
			spawn_client(client)
	var i = 0
	while i < _hungries_clients.size():
		if _hungries_clients[i] == null:
			_hungries_clients.remove_at(i)
		else:
			i+=1
			
	if _client_waiting_to_spawn.size() == 0 and _hungries_clients.size() == 0 and timer_next_wave.is_stopped():
		start_wait_next_wave()

func next_wave():
	number_wave += 1
	_index_current_wave = (_index_current_wave + 1) % game_data.waves.size()
	_current_preset_wave = game_data.waves[_index_current_wave].waves_presets.pick_random()
	_client_waiting_to_spawn = _current_preset_wave.clients.duplicate()
	time = 0
	next_wave_started.emit(_current_preset_wave, number_wave)
	
func spawn_client(_client: ClientData) -> void:
	if enemy_scene == null:
		return
	var instance: HungryClient = enemy_scene.instantiate()
	instance.agent.target_position = front_truck_target.global_position
	instance.target_position = front_truck_target.global_position
	instance.target_leaving = out_screen_target.global_position
	
	var spawn_position: Vector3 = get_random_spawn_position()
	
	get_parent().add_child(instance)
	instance.global_transform.origin = spawn_position
	
	client_spawned.emit(instance)
	_hungries_clients.append(instance)

func get_random_spawn_position() -> Vector3:
	spawn_location.progress_ratio = randf()
	
	return spawn_location.global_position
	
func start_wait_next_wave():
	waiting_next_wave.emit()
	timer_next_wave.start()
