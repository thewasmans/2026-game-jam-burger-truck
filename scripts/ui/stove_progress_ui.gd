class_name ProgressCoocking
extends ProgressBar

@export var _camera: Camera3D
var _target: Node3D = null
var _raw = Color(0.82, 0.23, 0.18)
var _cooked = Color(0.20, 0.09, 0.02)

func set_target(node: Node3D):
	_target = node

func set_progress(progress: float):
	progress = clamp(progress, 0.0, 1.0)
	
	value = progress * 100.0
	modulate = _raw.lerp(_cooked, progress)
	
func _process(_delta):
	if not _target:
		return
	
	var pos_3d = _target.global_transform.origin
	pos_3d.y += 1.0
	
	var screen_pos = _camera.unproject_position(pos_3d)
	position = screen_pos - size / 2
