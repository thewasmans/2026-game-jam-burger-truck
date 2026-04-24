extends Control

@onready var progress_bar = $ProgressBar
@onready var frame = $TextureRect

@export var _frames:= {
	1: preload("res://contents/ui/icons/kitchen/sharpness_5_ui.png"), 
	0.75: preload("res://contents/ui/icons/kitchen/sharpness_4_ui.png"), 
	0.5: preload("res://contents/ui/icons/kitchen/sharpness_3_ui.png"), 
	0.25: preload("res://contents/ui/icons/kitchen/sharpness_2_ui.png"), 
	0.0: preload("res://contents/ui/icons/kitchen/sharpness_1_ui.png")
}

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
