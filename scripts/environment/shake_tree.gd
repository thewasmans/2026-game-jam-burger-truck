class_name TreeInteractor
extends Area3D

@export var _visual_node: Node3D
@export var _shake_intensity: float = 0.1
@export var _shake_duration: float = 0.4
@export var _leaf_particles: LeafParticleSystem

var _tween: Tween
@onready var original_rotation: Vector3 = _visual_node.rotation

func _ready() -> void:
	input_event.connect(_input_event)

func _input_event(_camera: Camera3D, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_play_shake_animation()

func _play_shake_animation() -> void:
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	
	var target_left: Vector3 = original_rotation + Vector3(0, 0, _shake_intensity)
	var target_right: Vector3 = original_rotation + Vector3(0, 0, -_shake_intensity)
	
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_ease(Tween.EASE_IN_OUT)
	
	_tween.tween_property(_visual_node, "rotation", target_left, _shake_duration / 4.0)
	_tween.tween_property(_visual_node, "rotation", target_right, _shake_duration / 2.0)
	_tween.tween_property(_visual_node, "rotation", original_rotation, _shake_duration / 4.0)
	_leaf_particles.play()
