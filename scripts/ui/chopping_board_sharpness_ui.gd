extends Control

@onready var progress_bar = $ProgressBar
@onready var frame = $TextureRect

@export var _frames: Dictionary[float, Resource]

func update_visuals():
	var ratio = progress_bar.value / progress_bar.max_value
	
	var keys = _frames.keys()
	keys.sort()
	keys.reverse()
	
	for key in keys:
		if ratio >= key:
			frame.texture = _frames[key]
			break

	var danger_start = 0.3
	var t = (danger_start - ratio)/danger_start
	t = clamp(t, 0.0, 1.0)
	
	var color = Color.LAWN_GREEN.lerp(Color.DARK_RED, t)
	progress_bar.modulate = color
