extends Node3D

class_name HungryClientSpawner

signal client_spawned(client:HungryClient)
signal next_wave_started(current_preset_wave:WavesPresetData, number_wave: int)
signal waiting_next_wave()

@export var enemy_scene: PackedScene
@export var front_truck_target: MeshInstance3D 
@export var out_screen_target: MeshInstance3D
@export var hungry_client_spawner: Node3D
@export var minimal_spawn_time: float = 4.0
@export var maximal_spawn_time: float = 8.0
@onready var spawn_location: PathFollow3D = $SpawnPath/SpawnLocation
@export var difficulty_step: float = 0.5
@export var minimum_limit: float = 5.0
@export var timer_next_wave: Timer
@export var game_data: GameData
@export var grid_system: GridSystem
@export var hungry_client_speed_increment: float = 1.0
@export var hungry_client_patience_decrease: float = 5.0
@export var minimum_client_patience: float = 10.0

var spawn_time := RandomNumberGenerator.new()
var time: float

var _hungries_clients: Array[HungryClient] = []
var _index_current_wave: int = -1
var _current_preset_wave: WavesPresetData
var _client_waiting_to_spawn: Array[ClientData]
var number_wave: int = 0
var furniture_phase: bool
var current_speed_bonus: float = 0.0
var current_patience_decrease: float = 0.0

func _ready() -> void:
	randomize()
	front_truck_target.hide()
	out_screen_target.hide()
	hungry_client_spawner.hide()
	
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
			
	if _client_waiting_to_spawn.size() == 0 and _hungries_clients.size() == 0 and timer_next_wave.is_stopped() and not furniture_phase:
		start_wait_next_wave()

func next_wave():
	furniture_phase = false
	number_wave += 1
	if number_wave > 1 and (number_wave - 1) % game_data.waves.size() == 0:
		current_speed_bonus += hungry_client_speed_increment
		current_patience_decrease += hungry_client_patience_decrease
	_index_current_wave = (_index_current_wave + 1) % game_data.waves.size()
	_current_preset_wave = game_data.waves[_index_current_wave].waves_presets.pick_random()
	_client_waiting_to_spawn = _current_preset_wave.clients.duplicate()
	time = 0
	next_wave_started.emit(_current_preset_wave, number_wave)

func remove_client(client: HungryClient):
	_hungries_clients.erase(client)
	
func spawn_client(_client: ClientData) -> void:
	if enemy_scene == null:
		return
	var instance: HungryClient = grid_system.spawn_client_at_spawn()
	
	instance.speed += current_speed_bonus
	
	instance.wait_time = max(minimum_client_patience,instance.wait_time - current_patience_decrease)
	
	_hungries_clients.append(instance)
	client_spawned.emit(instance)

func get_random_spawn_position() -> Vector3:
	spawn_location.progress_ratio = randf()
	
	return spawn_location.global_position
	
func start_wait_next_wave():
	waiting_next_wave.emit()
	furniture_phase = true
	#timer_next_wave.start()
