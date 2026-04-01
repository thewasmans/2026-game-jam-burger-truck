extends CharacterBody3D

class_name Enemy

signal leaving_hungry
signal leaving_satiated
signal waiting_food
signal leaved

enum State { MOVING_TO_TRUCK, WAITING, LEAVING }

@export var speed: float = 5.0
@export var target_position: Vector3
@export var target_leaving: Vector3
@export var client_request_ui: ClientRequestUI

var current_state: State = State.MOVING_TO_TRUCK
var wait_timer: Timer

var _is_hungry: bool
var _is_leaved: bool
var value_waiting: float

func _ready() -> void:
	_is_hungry = true
	wait_timer = Timer.new()
	wait_timer.wait_time = 3.0
	wait_timer.one_shot = true
	wait_timer.timeout.connect(_on_wait_timer_timeout)
	add_child(wait_timer)
	client_request_ui.set_request("FOOD")

func _physics_process(delta: float) -> void:
	if _is_leaved:
		return 
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
			if value_waiting >= 0:
				value_waiting += delta
				client_request_ui.set_waiting(wait_timer.wait_time - value_waiting)
			else:
				waiting_food.emit()
			
		State.LEAVING:
			var direction: Vector3 = (target_leaving - global_transform.origin).normalized()
			if global_transform.origin.distance_to(target_leaving) > 1:
				velocity = direction * speed
			else:
				_is_leaved = true
				hide()
				leaved.emit()
	move_and_slide()

func _on_wait_timer_timeout() -> void:
	current_state = State.LEAVING
	if _is_hungry:
		leaving_hungry.emit()
	else:
		leaving_satiated.emit()
	
func give_food()-> bool:
	if current_state == State.WAITING:
		_is_hungry = false
		wait_timer.stop()
		current_state = State.LEAVING
		return true
	return false
	
