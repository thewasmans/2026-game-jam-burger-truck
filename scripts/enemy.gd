extends CharacterBody3D

class_name Enemy

enum State { MOVING_TO_TRUCK, WAITING, LEAVING }

@export var speed: float = 5.0
@export var target_position: Vector3
@export var target_leaving: Vector3

var current_state: State = State.MOVING_TO_TRUCK
var wait_timer: Timer

func _ready() -> void:
	wait_timer = Timer.new()
	wait_timer.wait_time = 3.0 # Wait for 3 seconds
	wait_timer.one_shot = true
	wait_timer.timeout.connect(_on_wait_timer_timeout)
	add_child(wait_timer)

func _physics_process(delta: float) -> void:
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
			velocity = Vector3.RIGHT * speed
			if global_transform.origin.x > 20:
				queue_free()

	move_and_slide()

func _on_wait_timer_timeout() -> void:
	current_state = State.LEAVING
