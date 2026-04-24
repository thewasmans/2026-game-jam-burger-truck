class_name ProgressCoocking
extends ProgressBar

var _target: Node3D = null
var _raw = Color(0.82, 0.23, 0.18)
var _cooked = Color(0.20, 0.09, 0.02)

func set_target(node: Node3D):
	_target = node

func set_progress(progress: float):
	progress = clamp(progress, 0.0, 1.0)
	
	value = progress
	modulate = _raw.lerp(_cooked, progress)
