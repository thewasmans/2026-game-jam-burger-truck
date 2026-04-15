extends CharacterBody3D

class_name HungryClient

signal leaving_hungry
signal leaving_satiated
signal waiting_food
signal leaved

enum State { MOVING_TO_TRUCK, WAITING, LEAVING }

@export var speed: float = 4.0
@export var target_position: Vector3
@export var target_leaving: Vector3
@export var client_request_ui: ClientRequestUI
@export var hover_node: Node3D
@export var wait_time: Vector2 = Vector2(12, 18)
@export var anchor_burger: Node3D
@export var collision: CollisionShape3D
@export var agent: NavigationAgent3D

var current_state: State = State.MOVING_TO_TRUCK
var wait_timer: Timer

var _burger_request:BurgerData
var _is_hungry: bool
var _is_leaved: bool
var value_waiting: float = -1
var is_waiting:
	get:
		return current_state == State.WAITING
var _original_scale:Vector3

func _ready() -> void:
	_is_hungry = true
	wait_timer = Timer.new()
	wait_timer.wait_time = randf_range(wait_time.x, wait_time.y)
	client_request_ui.waiting.max_value = wait_timer.wait_time
	client_request_ui.waiting.value = wait_timer.wait_time
	wait_timer.one_shot = true
	wait_timer.timeout.connect(_on_wait_timer_timeout)
	add_child(wait_timer)
	_original_scale = anchor_burger.scale
	
func _physics_process(delta: float) -> void:
	if _is_leaved:
		return 
	match current_state:
		State.MOVING_TO_TRUCK:
			if agent.is_navigation_finished():
				velocity = Vector3.ZERO
				current_state = State.WAITING
				wait_timer.start()
			else:
				var current_agent_position: Vector3 = global_position
				var next_path_position: Vector3 = agent.get_next_path_position()
				
				velocity = current_agent_position.direction_to(next_path_position) * speed
		
		State.WAITING:
			collision.disabled = true
			if value_waiting >= 0:
				value_waiting += delta
				client_request_ui.set_waiting(wait_timer.wait_time - value_waiting)
			else:
				waiting_food.emit()
				value_waiting = 0
			
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

func _on_area_3d_mouse_entered() -> void:
	for i in anchor_burger.get_child(0).get_child_count():
		var child: Node3D = anchor_burger.get_child(0).get_child(i)
		create_tween()\
			.tween_property(child, "position", child.position + Vector3.UP * i * .5, .15)\
			.set_ease(Tween.EASE_IN_OUT)\
			.set_trans(Tween.TRANS_ELASTIC)

func _on_area_3d_mouse_exited() -> void:
	for i in anchor_burger.get_child(0).get_child_count():
		var child: Node3D = anchor_burger.get_child(0).get_child(i)
		create_tween()\
			.tween_property(child, "position", Vector3.UP * i * .35, .15)\
			.set_ease(Tween.EASE_IN_OUT)\
			.set_trans(Tween.TRANS_ELASTIC)

func set_burger(burger_data:BurgerData):
	_burger_request = burger_data
	var burger_node = Node3D.new()
	burger_node.scale *= .25
	anchor_burger.add_child(burger_node)
	for ingredient in burger_data.ingredients:
		var instance: Node3D = ingredient.model_3d.instantiate()
		instance.position += Vector3.UP * burger_node.get_child_count() * .35
		instance.rotate_x(-PI * .1)
		burger_node.add_child(instance)

func give_food(_burger:Array[IngredientData])-> bool:
	if current_state == State.WAITING:
		_is_hungry = false
		wait_timer.stop()
		current_state = State.LEAVING
		anchor_burger.hide()
		return true
	return false
