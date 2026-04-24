class_name CameraSwitcher
extends Camera3D

@export var camera_kitchen: Camera3D
@export var camera_furnitures: Camera3D
@export var smooth_speed: float = 5.0
var camera_target: Camera3D

func _process(delta: float):
	if not camera_target:
		return

	global_position = global_position.lerp(camera_target.global_position, smooth_speed * delta)
	var target_rotation = camera_target.global_transform.basis.get_rotation_quaternion()
	var current_rotation = global_transform.basis.get_rotation_quaternion()
	
	var next_rotation = current_rotation.slerp(target_rotation, smooth_speed * delta)
	global_transform.basis = Basis(next_rotation)

func set_camera_kitchen():
	camera_target = camera_kitchen

func set_camera_furnitures():
	camera_target = camera_furnitures
