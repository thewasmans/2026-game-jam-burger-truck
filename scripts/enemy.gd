extends CharacterBody3D

class_name Enemy

signal leaving_truck

enum State { MOVING_TO_TRUCK, WAITING, LEAVING }

@export var speed: float = 5.0
@export var target_position: Vector3
@export var target_leaving: Vector3
@export var client_request_ui: ClientRequestUI

var current_state: State = State.MOVING_TO_TRUCK
var wait_timer: Timer

func _ready() -> void:
	wait_timer = Timer.new()
	wait_timer.wait_time = 3.0
	wait_timer.one_shot = true
	wait_timer.timeout.connect(_on_wait_timer_timeout)
	add_child(wait_timer)
	client_request_ui.set_request(str(randf()))

func _physics_process(_delta: float) -> void:
	match current_state:
		State.MOVING_TO_TRUCK:
			var direction: Vector3 = (target_position - global_transform.origin).normalized()

			if global_transform.origin.distance_to(target_position) > 1:
				velocity = direction * speed
			else:
				velocity = Vector3.ZERO
				current_state = State.WAITING
				wait_timer.start()
		
		State.WAITING:
			pass
			
		State.LEAVING:
			var direction: Vector3 = (target_leaving - global_transform.origin).normalized()
			if global_transform.origin.distance_to(target_leaving) > 1:
				velocity = direction * speed
			else:
				queue_free()

	move_and_slide()

func _on_wait_timer_timeout() -> void:
	current_state = State.LEAVING
	leaving_truck.emit()
